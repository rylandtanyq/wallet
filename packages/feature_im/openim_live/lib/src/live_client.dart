import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'pages/group/room.dart';
import 'pages/single/room.dart';
import 'utils/live_utils.dart';

enum CallType { audio, video }

enum CallObj { single, group }

enum CallState {
  call, // 主动邀请
  beCalled, // 被邀请
  reject, // 拒绝
  beRejected, // 被拒绝
  calling, // 通话中
  beAccepted, // 已接受
  hangup, // 主动挂断
  beHangup, // 被对方挂断
  connecting,
  // noReply, // 无响应
  otherAccepted, // 其他端接受
  otherReject, // 其他端拒绝
  cancel, // 主动取消
  beCanceled, // 被取消
  timeout, //超时
  join, //主动加入（群通话）
  // busyLine, // 繁忙
  networkError,
}

class CallEvent {
  CallState state;
  SignalingInfo data;
  dynamic fields;

  CallEvent(this.state, this.data, {this.fields});

  @override
  String toString() {
    return 'CallEvent{state: $state, data: $data, fields: $fields}';
  }
}

class OpenIMLiveClient implements RTCBridge {
  OpenIMLiveClient._();

  static final OpenIMLiveClient singleton = OpenIMLiveClient._();

  factory OpenIMLiveClient() {
    PackageBridge.rtcBridge ??= singleton;
    return singleton;
  }

  @override
  bool get hasConnection {
    Logger.print('live_client has Connection: $isBusy');
    return isBusy;
  }

  @override
  void dismiss() {
    close();
  }

  static OverlayEntry? _holder;

  /// 占线
  bool isBusy = false;

  String? currentRoomID;
  Room? _room;
  Future Function(int duration, bool isPositive)? onTapHangup;

  AnimationController? _animationController;

  quitClose(String roomID) async {
    if (currentRoomID == roomID) {
      await onTapHangup?.call(0, true);
      closeByRoomID(roomID);
    }
  }

  closeByRoomID(String roomID) {
    if (currentRoomID == roomID) {
      close();
    }
  }

  void close() {
    Logger.print(
      'calling remove overlay',
      fileName: 'live_client.dart',
      functionName: 'close',
    );
    if (_holder != null) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        await _animationController?.reverse();
        _holder?.remove();
        _holder = null;
        _animationController = null;
        // 重置状态
        WakelockPlus.disable();
        isBusy = false;
        currentRoomID = null;
      });
    }
  }

  Future<void> roomDisconnect() async {
    Logger.print(
      'roomDisconnect, room is null: ${_room == null}',
      fileName: 'live_client.dart',
      keyAndValues: ['status', _room?.connectionState.name],
    );
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;

    return;
  }

  // start method as described
  start(BuildContext ctx,
      {required PublishSubject<CallEvent> callEventSubject,
      String? roomID,
      CallState initState = CallState.call,
      CallType callType = CallType.video,
      CallObj callObj = CallObj.single,
      required String inviterUserID,
      required List<String> inviteeUserIDList,
      required PublishSubject<List<String>> inviteeUserIDListSubject,
      String? groupID,
      Future<SignalingCertificate> Function()? onDialSingle,
      Future<SignalingCertificate> Function()? onDialGroup,
      Future<SignalingCertificate> Function()? onJoinGroup,
      Future<SignalingCertificate> Function()? onTapPickup,
      Future Function()? onTapCancel,
      Future Function(int duration, bool isPositive)? onTapHangup,
      Future Function()? onTapReject,
      Future<UserInfo?> Function(String userID)? onSyncUserInfo,
      Future<GroupInfo?> Function(String groupID)? onSyncGroupInfo,
      Future<List<GroupMembersInfo>> Function(String groupID, List<String> memberIDList)? onSyncGroupMemberInfo,
      bool autoPickup = false,
      Function()? onWaitingAccept,
      Function()? onBusyLine,
      Function()? onStartCalling,
      Function(dynamic error, dynamic stack)? onError,
      Function()? onClose,
      void Function(CallingOperationType type, String userID)? onAction,
      void Function(bool enabled)? onEnabledSpeaker}) {
    if (isBusy) return;
    isBusy = true;
    currentRoomID = roomID;

    FocusScope.of(ctx).requestFocus(FocusNode());

    // Choose the overlay widget based on CallObj type
    if (callObj == CallObj.single) {
      _holder = OverlayEntry(
        builder: (context) => SlideInSlideOutWidget(
          contentBuilder: (controller) {
            _animationController = controller;
            return SingleRoomView(
              callType: callType,
              initState: initState,
              callEventSubject: callEventSubject,
              roomID: roomID,
              userID: initState == CallState.call ? inviteeUserIDList.first : inviterUserID,
              onDial: onDialSingle,
              onTapCancel: onTapCancel,
              onTapHangup: onTapHangup,
              onTapReject: onTapReject,
              onTapPickup: onTapPickup,
              onSyncUserInfo: onSyncUserInfo,
              autoPickup: autoPickup,
              onBindRoomID: (roomID) => currentRoomID = roomID,
              onWaitingAccept: onWaitingAccept,
              onBusyLine: onBusyLine,
              onStartCalling: onStartCalling,
              onError: onError,
              onCreateRoom: (r) => _room = r,
              onClose: () {
                onClose?.call();
                close();
              },
              onEnabledSpeaker: onEnabledSpeaker,
            );
          },
        ),
      );
    } else {
      _holder = OverlayEntry(
        builder: (context) => SlideInSlideOutWidget(
          contentBuilder: (controller) {
            _animationController = controller;
            return GroupRoomView(
              callType: callType,
              initState: initState,
              callEventSubject: callEventSubject,
              roomID: roomID,
              inviterUserID: inviterUserID,
              inviteeUserIDList: inviteeUserIDList,
              inviteeUserIDListSubject: inviteeUserIDListSubject,
              groupID: groupID!,
              onDial: onDialGroup,
              onJoin: onJoinGroup,
              onTapCancel: onTapCancel,
              onTapHangup: onTapHangup,
              onTapReject: onTapReject,
              onTapPickup: onTapPickup,
              onSyncGroupInfo: onSyncGroupInfo,
              onSyncGroupMemberInfo: onSyncGroupMemberInfo,
              onBindRoomID: (roomID) => currentRoomID = roomID,
              onWaitingAccept: onWaitingAccept,
              onError: onError,
              autoPickup: autoPickup,
              onCreateRoom: (r) => _room = r,
              onClose: () {
                onClose?.call();
                close();
              },
              onAction: onAction,
              onEnabledSpeaker: onEnabledSpeaker,
            );
          },
        ),
      );
    }

    Overlay.of(ctx).insert(_holder!);

    // Enable screen wake lock
    WakelockPlus.enable();
  }
}

// FadeInFadeOutWidget is used to wrap the content with an animation
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
      duration: const Duration(milliseconds: 500),
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
