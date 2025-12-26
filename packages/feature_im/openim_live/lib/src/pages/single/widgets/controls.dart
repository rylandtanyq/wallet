import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/src/widgets/live_button.dart';
import 'package:synchronized/synchronized.dart';

import '../../../live_client.dart';
import '../../../widgets/loading_view.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

class ControlsView extends StatefulWidget {
  const ControlsView({
    Key? key,
    this.initState = CallState.call,
    this.callType = CallType.video,
    required this.callStateStream,
    required this.roomDidUpdateStream,
    this.userInfo,
    this.onMinimize,
    this.onCallingDuration,
    this.onEnabledMicrophone,
    this.onEnabledSpeaker,
    this.onCancel,
    this.onHangUp,
    this.onPickUp,
    this.onReject,
    this.onChangedCallState,
  }) : super(key: key);
  final Stream<Room> roomDidUpdateStream;
  final Stream<CallState> callStateStream;
  final CallState initState;
  final CallType callType;
  final UserInfo? userInfo;
  final Function()? onMinimize;
  final Function(int duration)? onCallingDuration;
  final Function(bool enabled)? onEnabledMicrophone;
  final Function(bool enabled)? onEnabledSpeaker;
  final Future Function()? onPickUp;
  final Function()? onCancel;
  final Function()? onReject;
  final Function(bool isPositive)? onHangUp;
  final Function(CallState state)? onChangedCallState;

  @override
  State<ControlsView> createState() => _ControlsViewState();
}

class _ControlsViewState extends State<ControlsView> {
  late CallState _callState;
  Timer? _callingTimer;
  int _callingDuration = 0;
  String _callingDurationStr = "00:00";

  //
  CameraPosition position = CameraPosition.front;

  StreamSubscription<CallState>? _callStateChangedSub;
  StreamSubscription? _deviceChangeSub;
  StreamSubscription<Room>? _roomDidUpdateSub;

  Room? _room;
  LocalParticipant? _participant;

  /// 默认启用麦克风
  bool _enabledMicrophone = true;

  /// 默认开启扬声器
  bool _enabledSpeaker = false;

  final _lockAudio = Lock();
  final _lockSpeaker = Lock();

  bool _pickuping = false;

  @override
  void dispose() {
    _callStateChangedSub?.cancel();
    _roomDidUpdateSub?.cancel();
    _callingTimer?.cancel();
    _deviceChangeSub?.cancel();
    _participant?.removeListener(_onChange);
    super.dispose();
  }

  @override
  void initState() {
    _onChangedCallState(widget.initState);
    _callStateChangedSub = widget.callStateStream.listen(_onChangedCallState);
    _roomDidUpdateSub = widget.roomDidUpdateStream.listen(_roomDidUpdate);
    _deviceChangeSub = Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    Hardware.instance.enumerateDevices().then(_loadDevices);
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  _roomDidUpdate(Room room) {
    _room ??= room;
    if (room.localParticipant != null && _participant == null) {
      _participant = room.localParticipant;
      _participant?.addListener(_onChange);
    }
  }

  _onChangedCallState(CallState state) {
    if (!mounted) return;
    widget.onChangedCallState?.call(state);
    setState(() {
      _callState = state;
      if (_callState == CallState.calling) {
        _startCallingTimer();
      }
    });
  }

  void _startCallingTimer() {
    _callingTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _callingDurationStr = IMUtils.seconds2HMS(++_callingDuration);
        widget.onCallingDuration?.call(_callingDuration);
      });
    });
  }

  void _onChange() {
    // trigger refresh
    setState(() {});
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

  Future _toggleAudio() async {
    await _lockAudio.synchronized(() async {
      _enabledMicrophone = !_enabledMicrophone;
      widget.onEnabledMicrophone?.call(_enabledMicrophone);
      if (_enabledMicrophone) {
        await _enableAudio();
      } else {
        await _disableAudio();
      }
    });
  }

  Future<void> _enableSpeakerphone(bool enabled) async {
    Logger.print('enableSpeakerphone: $enabled');
    await _room?.setSpeakerOn(enabled, forceSpeakerOutput: false);
  }

  void _toggleSpeaker() async {
    await _lockSpeaker.synchronized(() async {
      _enabledSpeaker = !_enabledSpeaker;
      widget.onEnabledSpeaker?.call(_enabledSpeaker);
      _enableSpeakerphone(_enabledSpeaker);
      setState(() {});
    });
  }

  Future<void> _disableAudio() async {
    await _participant?.setMicrophoneEnabled(false);
  }

  Future<void> _enableAudio() async {
    await _participant?.setMicrophoneEnabled(true);
  }

  Future<void> _disableVideo() async {
    await _participant?.setCameraEnabled(false);
  }

  Future<void> _enableVideo() async {
    await _participant?.setCameraEnabled(true, cameraCaptureOptions: CameraCaptureOptions(cameraPosition: position));
  }

  void _toggleCamera() async {
    final track = _participant?.videoTrackPublications.firstOrNull?.track;
    if (track == null) return;
    rtc.Helper.switchCamera(track.mediaStreamTrack);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 16.w,
              top: 7.h,
              child: ImageRes.liveClose.toImage
                ..width = 30.w
                ..height = 30.h
                ..onTap = widget.onMinimize,
            ),
            if (null != _participant)
              Positioned(
                right: 16.w,
                top: 7.h,
                child: Visibility(
                  visible: isVideo,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (_participant!.isCameraEnabled() ? ImageRes.liveCameraOff : ImageRes.liveCameraOn).toImage
                        ..width = 30.w
                        ..height = 30.h
                        ..onTap = (_participant!.isCameraEnabled() ? _disableVideo : _enableVideo),
                      16.horizontalSpace,
                      ImageRes.liveSwitchCamera.toImage
                        ..width = 30.w
                        ..height = 30.h
                        ..onTap = _toggleCamera,
                    ],
                  ),
                ),
              ),
            if (null != widget.userInfo)
              Positioned(
                top: 166.h,
                width: 1.sw,
                child: _userInfoView,
              ),
            Positioned(
              bottom: 32.h,
              width: 1.sw,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buttonGroup,
              ),
            ),
            Positioned(
              bottom: 156.h,
              width: 1.sw,
              child: Center(child: _videoCallingDurationView),
            ),
          ],
        ),
      );

  List<Widget> get _buttonGroup {
    if (_callState == CallState.call || _callState == CallState.connecting && widget.initState == CallState.call) {
      return [
        LiveButton.microphone(on: _enabledMicrophone, onTap: _toggleAudio),
        LiveButton.cancel(onTap: widget.onCancel),
        LiveButton.speaker(
          on: _enabledSpeaker,
          onTap: Hardware.instance.canSwitchSpeakerphone ? _toggleSpeaker : null,
        ),
      ];
    } else if (_callState == CallState.beCalled ||
        _callState == CallState.connecting && widget.initState == CallState.beCalled) {
      return [
        LiveButton.reject(onTap: widget.onReject),
        LiveButton.pickUp(
          loading: _pickuping,
          onTap: () async {
            setState(() {
              _pickuping = true;
            });
            await widget.onPickUp?.call();
            setState(() {
              _pickuping = false;
            });
          },
        ),
      ];
    } else if (_callState == CallState.calling) {
      return [
        LiveButton.microphone(on: _enabledMicrophone, onTap: _toggleAudio),
        LiveButton.hungUp(onTap: () => widget.onHangUp?.call(true)),
        LiveButton.speaker(on: _enabledSpeaker, onTap: _toggleSpeaker),
      ];
    }
    return [];
  }

  bool get isVideo => widget.callType == CallType.video;

  bool get isCalling => _callState == CallState.calling;

  Widget get _videoCallingDurationView => Visibility(
        visible: isVideo && isCalling,
        child: _callingDurationStr.toText..style = Styles.ts_FFFFFF_opacity70_17sp,
      );

  Widget get _userInfoView {
    String text;
    if (_callState == CallState.call) {
      text = isVideo ? StrRes.waitingVideoCallHint : StrRes.waitingVoiceCallHint;
    } else if (_callState == CallState.beCalled) {
      text = isVideo ? StrRes.invitedVideoCallHint : StrRes.invitedVoiceCallHint;
    } else if (_callState == CallState.connecting) {
      text = StrRes.connecting;
    } else {
      text = isVideo ? '' : _callingDurationStr;
    }

    String? nickname = IMUtils.emptyStrToNull(widget.userInfo!.remark) ?? widget.userInfo!.nickname;
    String? faceURL = widget.userInfo!.faceURL;

    return Visibility(
      visible: !(isVideo && isCalling),
      child: Column(
        children: [
          AvatarView(width: 70.w, height: 70.h, text: nickname, url: faceURL),
          10.verticalSpace,
          (nickname ?? '').toText..style = Styles.ts_FFFFFF_20sp_medium,
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: text.toText
              ..style = Styles.ts_FFFFFF_opacity70_17sp
              ..maxLines = 1
              ..overflow = TextOverflow.ellipsis,
          ),
          if (_callState == CallState.call) const LiveLoadingView(),
        ],
      ),
    );
  }
}
