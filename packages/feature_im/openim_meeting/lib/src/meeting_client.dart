import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/openim_meeting.dart';
import 'package:openim_meeting/src/pages/meeting/meeting_logic.dart';
import 'package:openim_meeting/src/pages/meeting_room/room.dart';
import 'package:openim_meeting/src/repository/repository_adapter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:fixnum/fixnum.dart';

import 'repository/meeting.pb.dart';
import 'repository/pb_extension.dart';

/// 会议室
class MeetingClient implements MeetingBridge {
  MeetingClient._();

  static final MeetingClient _singleton = MeetingClient._();

  factory MeetingClient.singleton() {
    PackageBridge.meetingBridge ??= _singleton;
    return _singleton;
  }

  factory MeetingClient() {
    return MeetingClient.singleton();
  }

  VoidCallback? onClose;

  @override
  bool get hasConnection {
    Logger.print('meeting_client has Connection: $isBusy');
    return isBusy;
  }

  @override
  void dismiss() {
    close();
  }

  OverlayEntry? _holder;
  bool isBusy = false;
  // PublishSubject<MeetingStreamEvent>? subject;
  String? roomID;
  AnimationController? _animationController;
  Room? _room;

  close() async {
    await _animationController?.reverse();
    if (_holder != null) {
      _holder?.remove();
      _holder = null;
    }

    isBusy = false;
    // subject?.close();
    // subject = null;
    onClose?.call();
    roomID = null;
    // The next line disables the wakelock again.
    if (await WakelockPlus.enabled) WakelockPlus.disable();
  }

  Future forceClose() async {
    if (roomID != null) {
      close();

      final userID = DataSp.userID;

      final meetingInfo = await MeetingRepository().getMeetingInfo(roomID!, userID!);

      try {
        if (meetingInfo.hostUserID == userID) {
          await MeetingRepository().endMeeting(roomID!, userID);
          Get.find<MeetingLogic>().removeLocalFinishedMeeting(roomID!);
        } else {
          MeetingRepository().leaveMeeting(roomID!, userID);
        }
      } catch (e) {
        Logger.print('forceClose error: $e');
      }
    }
  }

  create(
    BuildContext ctx, {
    required String meetingName,
    required int startTime,
    required int duration,
    VoidCallback? onClose,
  }) =>
      _connect(ctx,
          isCreate: true, meetingName: meetingName, startTime: startTime, duration: duration, onClose: onClose);

  join(
    BuildContext ctx, {
    required String meetingID,
    String? meetingName,
    String? participantNickname,
    VoidCallback? onClose,
  }) =>
      _connect(ctx,
          isCreate: false,
          meetingID: meetingID,
          meetingName: meetingName,
          participantNickname: participantNickname,
          onClose: onClose);

  _connect(
    BuildContext ctx, {
    bool isCreate = true,
    String? meetingID,
    String? meetingName,
    int? startTime,
    int? duration,
    String? participantNickname,
    VoidCallback? onClose,
  }) async {
    try {
      if (isBusy) return;
      isBusy = true;

      FocusScope.of(ctx).requestFocus(FocusNode());

      roomID = meetingID;

      late LiveKit sc;
      final repository = MeetingRepository();
      MeetingInfoSetting infoSetting;

      if (isCreate) {
        final result = await repository.createMeeting(
          type: CreateMeetingType.quick,
          creatorUserID: DataSp.userID!,
          creatorDefinedMeetingInfo: CreatorDefinedMeetingInfo(
            title: meetingName,
            scheduledTime: Int64(startTime!),
            meetingDuration: Int64(duration!),
          ),
          setting: MeetingSetting(
            canParticipantsEnableCamera: true,
            canParticipantsUnmuteMicrophone: true,
            canParticipantsShareScreen: true,
            disableCameraOnJoin: true,
            disableMicrophoneOnJoin: true,
            canParticipantJoinMeetingEarly: true,
            lockMeeting: false,
            audioEncouragement: true,
            videoMirroring: true,
          ),
        );
        roomID = result.info.meetingID;

        if (result.cert == null) {
          isBusy = false;

          return;
        }

        sc = result.cert!;
        infoSetting = result.info;
      } else {
        final result = await repository.joinMeeting(meetingID!, DataSp.userID!);

        if (result == null) {
          isBusy = false;

          return;
        }
        infoSetting = await repository.getMeetingInfo(meetingID, DataSp.userID!);

        sc = result;
      }
      LoadingView().show();

      //create new room
      _room = Room(
        roomOptions: const RoomOptions(
          dynacast: true,
          adaptiveStream: true,
          defaultCameraCaptureOptions: CameraCaptureOptions(params: VideoParametersPresets.h720_169),
          defaultVideoPublishOptions: VideoPublishOptions(
              simulcast: true,
              videoCodec: 'VP8',
              videoEncoding: VideoEncoding(
                maxBitrate: 5 * 1000 * 1000,
                maxFramerate: 15,
              )),
          defaultScreenShareCaptureOptions:
              ScreenShareCaptureOptions(useiOSBroadcastExtension: true, maxFrameRate: 15.0),
        ),
      );

      OpenIM.iMManager.logs(
        file: 'meeting_client.dart',
        line: 174, // Updated line number
        msgs: 'OpenIM-Flutter: connect begin',
        keyAndValues: [sc.url, sc.token],
      );

      // Create a Listener before connecting
      final listener = _room!.createListener();

      await _room!.prepareConnection(
        sc.url,
        sc.token,
      );

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await _room!.connect(
        sc.url,
        sc.token,
      );

      // The following line will enable the Android and iOS wakelock.
      if (!await WakelockPlus.enabled) WakelockPlus.enable();
      DataSp.putMeetingInProgress(roomID!);

      OpenIM.iMManager.logs(
        file: 'meeting_client.dart',
        line: 197, // Updated line number
        msgs: 'OpenIM-Flutter: connect success',
      );
      // if (lkPlatformIs(PlatformType.android)) {
      // await _room!.localParticipant?.setMicrophoneEnabled(true);
      // }

      await _askPublish(
        infoSetting.setting.disableCameraOnJoin,
        infoSetting.setting.disableMicrophoneOnJoin,
      );

      Logger.print('loading end');
      LoadingView().dismiss();
      Overlay.of(ctx).insert(
        _holder = OverlayEntry(
          builder: (context) => SlideInSlideOutWidget(
            contentBuilder: (controller) {
              _animationController = controller;
              return MeetingRoom(
                _room!,
                listener,
                infoSetting: infoSetting,
                roomID: roomID!,
                onClose: () {
                  onClose?.call();
                  close();
                },
              );
            },
          ),
        ),
      );
    } catch (error, trace) {
      LoadingView().dismiss();

      if (_room?.connectionState == ConnectionState.connected) {
        // After dialing N times in a row, there may be a timeout. After N+1 successful connections, the previous timeout will close the interface.
        return;
      }
      close();
      Logger.print("error:$error  stack:$trace");
      OpenIM.iMManager.logs(
        file: 'meeting_client.dart',
        line: 199,
        msgs: 'OpenIM-Flutter: connect error',
        err: 'error: ${error.toString()}, stackTrace: ${trace.toString()}',
      );

      if (error.toString().contains('NotExist')) {
        IMViews.showToast(StrRes.meetingIsOver);
      } else {
        IMViews.showToast(StrRes.networkError);
      }
    }
  }

  Future _askPublish(bool joinDisabledVideo, bool joinDisabledMicrophone) async {
    Logger.print('joinDisabledVideo: $joinDisabledVideo', fileName: 'meeting_room.dart');
    Logger.print('joinDisabledMicrophone: $joinDisabledMicrophone', fileName: 'meeting_room.dart');
    // video will fail when running in ios simulator
    await IMUtils.requestBackgroundPermission(title: StrRes.audioAndVideoCall, text: StrRes.audioAndVideoCall);

    try {
      await _room?.localParticipant?.setCameraEnabled(!joinDisabledVideo);
      Logger.print('publish video success', fileName: 'meeting_room.dart');
    } catch (error) {
      Logger.print('could not publish video: $error', fileName: 'meeting_room.dart');
    }
    try {
      // if (lkPlatformIs(PlatformType.android)) {
      await _room?.localParticipant?.setMicrophoneEnabled(!joinDisabledMicrophone);
      Logger.print('publish microphone success', fileName: 'meeting_room.dart');
      // }
    } catch (error) {
      Logger.print('could not publish audio: $error', fileName: 'meeting_room.dart');
    }
  }

  invite({
    required String meetingID,
    required String meetingName,
    required int startTime,
    required int duration,
    String? userID,
    String? groupID,
  }) async {
    final offlinePushInfo = Config.offlinePushInfo;
    final newPushInfo = OfflinePushInfo(
      title: offlinePushInfo.title,
      desc: offlinePushInfo.desc,
      iOSBadgeCount: offlinePushInfo.iOSBadgeCount,
    )..title = StrRes.offlineMeetingMessage;

    OpenIM.iMManager.messageManager.sendMessage(
      userID: userID,
      groupID: groupID,
      message: await OpenIM.iMManager.messageManager.createMeetingMessage(
        inviterUserID: OpenIM.iMManager.userInfo.userID!,
        inviterNickname: OpenIM.iMManager.userInfo.nickname ?? '',
        inviterFaceURL: OpenIM.iMManager.userInfo.faceURL,
        subject: meetingName,
        id: meetingID,
        start: startTime,
        duration: duration,
      ),
      offlinePushInfo: newPushInfo,
    );
  }
}

class SlideInSlideOutWidget extends StatefulWidget {
  final Widget Function(AnimationController) contentBuilder;

  const SlideInSlideOutWidget({super.key, required this.contentBuilder});

  @override
  State<SlideInSlideOutWidget> createState() => _SlideInSlideOutWidgetState();
}

class _SlideInSlideOutWidgetState extends State<SlideInSlideOutWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.contentBuilder(_controller),
    );
  }
}
