import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/src/utils/live_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../openim_live.dart';
import '../../../widgets/small_window.dart';
import 'controls.dart';
import 'participant.dart';

abstract class SignalView extends StatefulWidget {
  const SignalView({
    Key? key,
    required this.callType,
    required this.initState,
    this.roomID,
    required this.userID,
    required this.callEventSubject,
    this.onDial,
    this.onSyncUserInfo,
    this.onTapCancel,
    this.onTapHangup,
    this.onTapPickup,
    this.onTapReject,
    this.onClose,
    required this.autoPickup,
    this.onBindRoomID,
    this.onWaitingAccept,
    this.onBusyLine,
    this.onStartCalling,
    this.onError,
    this.onCreateRoom,
    this.onAction,
    this.onEnabledSpeaker,
  }) : super(key: key);
  final CallType callType;
  final CallState initState;
  final String? roomID;
  final String userID;
  final PublishSubject<CallEvent> callEventSubject;
  final Future<SignalingCertificate> Function()? onDial;
  final Future<SignalingCertificate> Function()? onTapPickup;
  final Future Function()? onTapCancel;
  final Future Function(int duration, bool isPositive)? onTapHangup;
  final Future Function()? onTapReject;
  final Function()? onClose;
  final bool autoPickup;
  final Function(String roomID)? onBindRoomID;
  final Function()? onWaitingAccept;
  final Function()? onBusyLine;
  final Function()? onStartCalling;
  final Function(dynamic error, dynamic stack)? onError;
  final Future<UserInfo?> Function(String userID)? onSyncUserInfo;
  final Function(Room?)? onCreateRoom;
  final void Function(CallingOperationType type, String userID)? onAction;
  final void Function(bool enabledSpeaker)? onEnabledSpeaker;
}

abstract class SignalState<T extends SignalView> extends State<T> {
  final callStateSubject = BehaviorSubject<CallState>();
  final roomDidUpdateSubject = PublishSubject<Room>();
  late CallState callState;
  late SignalingCertificate certificate;
  String? roomID;
  UserInfo? userInfo;
  StreamSubscription? callEventSub;
  bool minimize = false;
  int duration = 0;
  bool enabledMicrophone = true;
  bool enabledSpeaker = false;

  ParticipantTrack? remoteParticipantTrack;
  ParticipantTrack? localParticipantTrack;

  @override
  void initState() {
    roomID ??= widget.roomID;
    callState = widget.initState;
    callEventSub = sameRoomSignalStream.listen(_onStateDidUpdate);
    widget.onSyncUserInfo?.call(widget.userID).then(_onUpdateUserInfo);
    onDail();
    autoPickup();
    onChangedSpeakerStatus(enabledSpeaker);
    super.initState();
  }

  @override
  void dispose() {
    roomDidUpdateSubject.close();
    callStateSubject.close();
    callEventSub?.cancel();
    super.dispose();
  }

  /// 过滤其他房间的信令
  Stream<CallEvent> get sameRoomSignalStream =>
      widget.callEventSubject.stream.where((event) => LiveUtils.isSameRoom(event, roomID));

  _onUpdateUserInfo(UserInfo? info) {
    if (!mounted && null != info) return;
    setState(() {
      userInfo = info;
    });
  }

  ///  某些信令通过liveKit的监听
  _onStateDidUpdate(CallEvent event) {
    Logger.print("CallEvent : 当前：$callState  收到：$event");
    if (!mounted) return;

    // ui 状态只有 呼叫，被呼叫，通话中，连接中
    if (event.state == CallState.call ||
        event.state == CallState.beCalled ||
        event.state == CallState.connecting ||
        event.state == CallState.calling) {
      callStateSubject.add(event.state);
    }

    if (event.state == CallState.beRejected || event.state == CallState.beCanceled) {
      // 如果挂断用户非当前聊天用户，或不是单聊用户 不做处理
      if (event.data.userID != widget.userID || event.data.invitation!.sessionType != 1) {
        return;
      }
      widget.onClose?.call();
    } else if (event.state == CallState.otherReject || event.state == CallState.otherAccepted) {
      if (existParticipants()) {
        return;
      }
      widget.onClose?.call();
      IMViews.showToast(
          sprintf(StrRes.otherCallHandle, [event.state == CallState.otherReject ? StrRes.rejectCall : StrRes.accept]));
    } else if (event.state == CallState.timeout) {
      widget.onClose?.call();
    } else if (event.state == CallState.beAccepted) {
      // 邀请对象比发起对象提前进入房间
      if (null != remoteParticipantTrack) {
        onParticipantConnected();
      }
    } else if (event.state == CallState.beHangup) {
      widget.onTapHangup?.call(duration, false);
    }
  }

  onParticipantConnected() {
    if (!callStateSubject.isClosed) {
      callStateSubject.add(CallState.calling);
    }
    widget.onStartCalling?.call();
  }

  onParticipantDisconnected() {
    onTapHangup(false);
  }

  /// 发起者在对方为进入房间都是 等待状态
  onDail() async {
    if (widget.initState == CallState.call) {
      // callStateSubject.add(CallState.connecting);
      certificate = await widget.onDial!.call();
      widget.onBindRoomID?.call(roomID = certificate.roomID!);
      await connect();
    }
  }

  autoPickup() {
    if (widget.autoPickup) {
      onTapPickup();
    }
  }

  Future onTapPickup() async {
    Logger.print('------------onTapPickup---------connecting--------');
    callStateSubject.add(CallState.connecting);
    certificate = await widget.onTapPickup!.call();
    widget.onBindRoomID?.call(roomID = certificate.roomID!);
    await connect();
    callStateSubject.add(CallState.calling);
    widget.onStartCalling?.call();
    Logger.print('------------onTapPickup---------connected--------');
    return;
  }

  /// [isPositive] 人为挂断行为
  onTapHangup(bool isPositive) async {
    await widget.onTapHangup
        ?.call(duration, isPositive)
        .whenComplete(() => /*isPositive ? {} : */ widget.onClose?.call());
  }

  onTapCancel() async {
    await widget.onTapCancel?.call().whenComplete(() => widget.onClose?.call());
  }

  onTapReject() async {
    await widget.onTapReject?.call().whenComplete(() => widget.onClose?.call());
  }

  onTapMinimize() {
    setState(() {
      minimize = true;
    });
  }

  onTapMaximize() {
    setState(() {
      minimize = false;
    });
  }

  callingDuration(int duration) {
    this.duration = duration;
  }

  onChangedMicStatus(bool enabled) {
    enabledMicrophone = enabled;
  }

  onChangedSpeakerStatus(bool enabled) {
    enabledSpeaker = enabled;
    widget.onEnabledSpeaker?.call(enabled);
  }

  //Alignment(0.9, -0.9),
  double alignX = 0.9;
  double alignY = -0.9;

  Alignment get moveAlign => Alignment(alignX, alignY);

  onMoveSmallWindow(DragUpdateDetails details) {
    final globalDy = details.globalPosition.dy;
    final globalDx = details.globalPosition.dx;
    setState(() {
      alignX = (globalDx - .5.sw) / .5.sw;
      alignY = (globalDy - .5.sh) / .5.sh;
    });
  }

  Future<void> connect();

  bool existParticipants();

  bool smallScreenIsRemote = true;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          AnimatedScale(
            scale: minimize ? 0 : 1,
            alignment: moveAlign,
            duration: const Duration(milliseconds: 200),
            onEnd: () {},
            child: Container(
              color: Styles.c_000000,
              child: Stack(
                children: [
                  // ImageRes.liveBg.toImage
                  //   ..fit = BoxFit.cover
                  //   ..width = 1.sw
                  //   ..height = 1.sh,
                  if (null != remoteParticipantTrack)
                    ParticipantWidget.widgetFor(smallScreenIsRemote ? remoteParticipantTrack! : localParticipantTrack!),

                  ControlsView(
                    callStateStream: callStateSubject.stream,
                    roomDidUpdateStream: roomDidUpdateSubject.stream,
                    initState: widget.initState,
                    callType: widget.callType,
                    userInfo: userInfo,
                    onMinimize: onTapMinimize,
                    onCallingDuration: callingDuration,
                    onEnabledMicrophone: onChangedMicStatus,
                    onEnabledSpeaker: onChangedSpeakerStatus,
                    onHangUp: onTapHangup,
                    onPickUp: onTapPickup,
                    onReject: onTapReject,
                    onCancel: onTapCancel,
                    onChangedCallState: (state) => callState = state,
                  ),
                  if (null != localParticipantTrack)
                    Positioned(
                      top: 97.h,
                      right: 12.w,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 120.w,
                          height: 180.h,
                          child: IgnorePointer(
                            child: ParticipantWidget.widgetFor(
                                smallScreenIsRemote ? localParticipantTrack! : remoteParticipantTrack!),
                          ),
                        ),
                        onTap: () {
                          if (remoteParticipantTrack != null) {
                            setState(() {
                              smallScreenIsRemote = !smallScreenIsRemote;
                            });
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (minimize)
            Align(
              alignment: moveAlign,
              child: AnimatedOpacity(
                opacity: minimize ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: SmallWindowView(
                  opacity: minimize ? 1 : 0,
                  userInfo: userInfo,
                  callState: callState,
                  onTapMaximize: onTapMaximize,
                  onPanUpdate: onMoveSmallWindow,
                  child: (state) {
                    // if (null != remoteParticipantTrack &&
                    //     state == CallState.calling &&
                    //     widget.callType == CallType.video) {
                    //   return SizedBox(
                    //     width: 120.w,
                    //     height: 180.h,
                    //     child: ParticipantWidget.widgetFor(
                    //         remoteParticipantTrack!),
                    //   );
                    // }
                    return null;
                  },
                ),
              ),
            ),
        ],
      );
}
