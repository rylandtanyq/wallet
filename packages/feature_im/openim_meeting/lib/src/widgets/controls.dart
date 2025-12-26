import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/src/repository/repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import '../pages/meeting/meeting_logic.dart';
import '../repository/meeting.pb.dart';
import '../repository/pb_extension.dart';
import 'appbar.dart';
import 'meeting_close_sheet.dart';
import 'meeting_detail_sheet.dart';
import 'meeting_members.dart';
import 'meeting_settings_sheet.dart';
import 'participant_info.dart';
import 'toolsbar.dart';

class ControlsView extends StatefulWidget {
  const ControlsView(this.room, this.participant,
      {Key? key,
      required this.child,
      required this.meetingInfoChangedSubject,
      required this.participantsSubject,
      this.onClose,
      this.onMinimize,
      this.onInviteMembers,
      this.startTimerCompleter,
      this.enableFullScreen = false})
      : super(key: key);
  final Room room;
  final LocalParticipant participant;
  final Widget child;
  final BehaviorSubject<MeetingInfoSetting> meetingInfoChangedSubject;
  final BehaviorSubject<List<ParticipantTrack>> participantsSubject;

  final Function(bool humanOperation)? onClose;
  final Function()? onMinimize;
  final Function()? onInviteMembers;
  final Completer<bool>? startTimerCompleter;
  final bool enableFullScreen;

  @override
  State<ControlsView> createState() => _ControlsViewState();
}

class _ControlsViewState extends State<ControlsView> {
  LocalParticipant get _participant => widget.participant;
  MeetingInfoSetting? _meetingInfo;
  Timer? _callingTimer;
  int _duration = 0;
  bool _enabledSpeaker = true;

  // Use this object to prevent concurrent access to data
  final _lockVideo = Lock();
  final _lockAudio = Lock();
  final _lockScreenShare = Lock();
  final _lockSpeaker = Lock();

  late StreamSubscription _meetingInfoChangedSub;
  StreamSubscription? _deviceChangeSub;

  bool get _isHost => _meetingInfo?.hostUserID == _participant.identity;

  MeetingSetting? get setting => _meetingInfo?.setting;

  bool get _disabledMicrophone =>
      !_participant.isMicrophoneEnabled() && setting?.canParticipantsUnmuteMicrophone == false && !_isHost;

  bool get _disabledCamera =>
      (!_participant.isCameraEnabled() && setting?.canParticipantsEnableCamera == false && !_isHost) ||
      _participant.isScreenShareEnabled();

  bool get _disabledScreenShare => setting?.canParticipantsShareScreen == false && !_isHost;

  int get membersCount => widget.room.remoteParticipants.length + 1;

  final _micTurnOffRing = 'assets/audio/meeting_mic_turn_off.wav';
  final _micTurnOnRing = 'assets/audio/meeting_mic_turn_on.wav';

  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    () async {
      if (Platform.isAndroid) {
        const audioAttributes = AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.notification,
        );

        await _audioPlayer.setAndroidAudioAttributes(audioAttributes);
        rtc.Helper.setAndroidAudioConfiguration(AndroidAudioConfiguration.communication);
      }

      _audioPlayer.setVolume(1.0);
    }();
    _meetingInfoChangedSub = widget.meetingInfoChangedSubject.listen(_onChangedMeetingInfo);
    widget.startTimerCompleter?.future.then((value) => _startCallingTimer());
    _deviceChangeSub = Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    Hardware.instance.enumerateDevices().then(_loadDevices);

    _enableSpeakerphone(_enabledSpeaker);

    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    _stopBackgroundService();
    _meetingInfoChangedSub.cancel();
    _deviceChangeSub?.cancel();
    _callingTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _setAudioOutputDevice();
  }

  Future _setAudioOutputDevice() async {
    final outs = await Hardware.instance.audioOutputs();

    // If there is a Bluetooth headset, when the speaker is turned on, the Bluetooth headset is not recognized.
    if (lkPlatformIs(PlatformType.android)) {
      if (_enabledSpeaker) {
        await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
      } else {
        await rtc.Helper.setSpeakerphoneOn(false);
      }
    }

    final dev = Hardware.instance.selectedAudioOutput;
    Logger.print('outs: $outs - selected: $dev');

    final ins = await Hardware.instance.audioInputs();
    final bluetooth = ins.firstWhereOrNull((e) => e.deviceId.toLowerCase().contains('bluetooth'));

    if (bluetooth != null) {
      await Hardware.instance.selectAudioInput(bluetooth);
    } else {
      await Hardware.instance.selectAudioInput(ins.first);
    }

    Logger.print('ints: $ins - selected: ${bluetooth ?? ins.first}');
  }

  void _startCallingTimer() {
    _callingTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;
        setState(() {
          ++_duration;
        });
      },
    );
  }

  void _onChangedMeetingInfo(MeetingInfoSetting meetingInfo) {
    if (!mounted) return;

    if (!meetingInfo.setting.canParticipantsShareScreen) {
      _disableScreenShare();
    }

    setState(() {
      _meetingInfo = meetingInfo;
    });
  }

  _toggleAudio([bool playSound = true]) async {
    await _lockAudio.synchronized(() async {
      if (_participant.isMicrophoneEnabled()) {
        if (playSound) {
          await _audioPlayer.setVolume(1.0);
          await _audioPlayer.setAsset(_micTurnOffRing, package: 'openim_common');
          await _audioPlayer.play();
        }
        await _participant.setMicrophoneEnabled(false);
      } else {
        if (playSound) {
          await _audioPlayer.setVolume(0.3);
          await _audioPlayer.setAsset(_micTurnOnRing, package: 'openim_common');
          await _audioPlayer.play();
        }
        await _participant.setMicrophoneEnabled(true);
      }
    });
  }

  _toggleVideo({bool forceDisable = false}) async {
    await _lockVideo.synchronized(() async {
      if (forceDisable) {
        await _participant.setCameraEnabled(false);
      } else {
        if (_participant.isCameraEnabled()) {
          await _participant.setCameraEnabled(false);
        } else {
          await _participant.setCameraEnabled(true);
        }
      }
    });
  }

  _toggleScreenShare() async {
    await _lockScreenShare.synchronized(() async {
      if (_participant.isScreenShareEnabled()) {
        await _disableScreenShare();
      } else {
        final result = await _enableScreenShare();

        if (result) {
          setState(() {
            _disabledCamera;
          });
        }
      }
    });
  }

  _stopBackgroundService() {
    if (FlutterBackground.isBackgroundExecutionEnabled) {
      FlutterBackground.disableBackgroundExecution();
    }
  }

  Future<bool> _enableScreenShare() async {
    _toggleVideo(forceDisable: true);

    if (lkPlatformIs(PlatformType.android)) {
      final result = await Helper.requestCapturePermission();
      if (!result) {
        return false;
      }

      await IMUtils.requestBackgroundPermission(title: StrRes.screenShare, text: StrRes.screenShareHint);
    }

    try {
      if (lkPlatformIs(PlatformType.iOS)) {
        var track = await LocalVideoTrack.createScreenShareTrack(
          const ScreenShareCaptureOptions(
              useiOSBroadcastExtension: true, maxFrameRate: 15.0, params: VideoParametersPresets.screenShareH720FPS15),
        );
        await _participant.publishVideoTrack(track);

        return true;
      }
      await _participant.setScreenShareEnabled(true, captureScreenAudio: true);

      return true;
    } catch (_) {
      return false;
    }
  }

  _disableScreenShare() async {
    if (!_participant.isScreenShareEnabled()) {
      return;
    }
    await _participant.setScreenShareEnabled(false);
    if (Platform.isAndroid) {
      // Android specific
      try {
        //   await FlutterBackground.disableBackgroundExecution();
      } catch (error, s) {
        Logger.print('error disabling screen share: $error  $s');
      }
    }
  }

  Future<void> _enableSpeakerphone(bool enabled) async {
    Logger.print('enableSpeakerphone: $enabled');
    await widget.room.setSpeakerOn(enabled, forceSpeakerOutput: false);
  }

  _onTapSpeaker([bool? enable]) async {
    await _lockSpeaker.synchronized(() async {
      _enabledSpeaker = enable ?? !_enabledSpeaker;
      _enableSpeakerphone(_enabledSpeaker);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Visibility(
              visible: !widget.enableFullScreen,
              child: MeetingAppBar(
                title: _meetingInfo?.meetingName,
                time: IMUtils.seconds2HMS(_duration),
                openSpeakerphone: _enabledSpeaker,
                onMinimize: widget.onMinimize,
                onEndMeeting: _openCloseMeetingSheet,
                onTapSpeakerphone: Hardware.instance.canSwitchSpeakerphone ? _onTapSpeaker : null,
                onViewMeetingDetail: _viewMeetingDetail,
              )),
          Expanded(child: widget.child),
          Visibility(
              visible: !widget.enableFullScreen,
              child: ToolsBar(
                openedCamera: _participant.isCameraEnabled(),
                openedMicrophone: _participant.isMicrophoneEnabled(),
                openedScreenShare: _participant.isScreenShareEnabled(),
                enabledMicrophone: !_disabledMicrophone,
                enabledCamera: !_disabledCamera,
                enabledScreenShare: !_disabledScreenShare,
                onTapCamera: _toggleVideo,
                onTapMicrophone: _toggleAudio,
                onTapScreenShare: _toggleScreenShare,
                onTapSettings: _openSettingsSheet,
                onTapMemberList: _openMembersSheet,
                membersCount: membersCount,
                isHost: _isHost,
              )),
        ],
      ),
    );
  }

  _openMembersSheet() {
    OverlayWidget().showBottomSheet(
      context: context,
      child: (AnimationController? controller) => MeetingMembersSheetView(
        controller: controller,
        participantsSubject: widget.participantsSubject,
        meetingInfoChangedSubject: widget.meetingInfoChangedSubject,
        onInvite: widget.onInviteMembers,
        isHost: _isHost,
      ),
    );
  }

  _openSettingsSheet() {
    if (null == _meetingInfo) return;
    OverlayWidget().showBottomSheet(
      context: context,
      child: (AnimationController? controller) => MeetingSettingsSheetView(
        controller: controller,
        allowParticipantUnmute: setting!.canParticipantsUnmuteMicrophone,
        allowParticipantVideo: setting!.canParticipantsEnableCamera,
        onlyHostCanInvite: false,
        onlyHostCanShareScreen: !setting!.canParticipantsShareScreen,
        joinMeetingDefaultMute: setting!.disableMicrophoneOnJoin,
        onConfirm: _confirmSettings,
      ),
    );
  }

  _openCloseMeetingSheet() {
    OverlayWidget().showBottomSheet(
      context: context,
      child: (AnimationController? controller) => MeetingCloseSheetView(
        controller: controller,
        isHost: _isHost,
        onDismiss: () async {
          try {
            await MeetingRepository().endMeeting(_meetingInfo!.meetingID, DataSp.userID!);
            Get.find<MeetingLogic>().removeLocalFinishedMeeting(_meetingInfo!.meetingID);

            widget.onClose?.call(true);
          } catch (e) {
            widget.onClose?.call(true);
          }
        },
        onLeave: () async {
          try {
            await MeetingRepository().leaveMeeting(_meetingInfo!.meetingID, DataSp.userID!);
            widget.onClose?.call(true);
          } catch (e) {
            widget.onClose?.call(true);
          }
        },
      ),
    );
  }

  _confirmSettings(Map map) {
    LoadingView.singleton.wrap(asyncFunction: () async {
      final update = UpdateMeetingRequest(
        meetingID: _meetingInfo!.meetingID,
        canParticipantsShareScreen: (!map['onlyHostShareScreen']),
        canParticipantsEnableCamera: (map['participantCanEnableVideo'] as bool),
        canParticipantsUnmuteMicrophone: (map['participantCanUnmuteSelf'] as bool),
        disableMicrophoneOnJoin: (map['joinDisableMicrophone'] as bool),
      );

      MeetingRepository().updateMeetingSetting(update);
    });
  }

  _viewMeetingDetail() {
    OverlayWidget().showBottomSheet(
      context: context,
      child: (AnimationController? controller) => MeetingDetailSheetView(
        info: _meetingInfo!,
        hostNickname: '',
      ),
    );
  }
}
