import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_live_alert/flutter_openim_live_alert.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:livekit_client/livekit_client.dart' hide Participant;
import 'package:openim_common/openim_common.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';

import '../openim_live.dart';
import 'utils/live_utils.dart';

/// 信令
mixin OpenIMLive {
  final waitTimeout = 60;

  final signalingSubject = PublishSubject<CallEvent>();

  /// 被邀请者收到：邀请者取消音视频通话
  void invitationCancelled(SignalingInfo info) {
    Logger.print(
      'invitationCancelled',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );
    _signalingInfo = info;
    if (!_currentIsSignal) {
      if (info.invitation?.groupID == _currentGroupID) {
        removeInvitee(info.userID!);
      }
    }
    signalingSubject.add(CallEvent(CallState.beCanceled, info));
  }

  /// 邀请者收到：被邀请者超时未接通
  void invitationTimeout(SignalingInfo info) {
    Logger.print(
      'invitationTimeout',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );
    _signalingInfo = info;
    if (!_currentIsSignal) {
      if (info.invitation?.groupID == _currentGroupID) {
        removeInvitee(info.userID!, isTimeout: true);
      }
    }
    signalingSubject.add(CallEvent(CallState.timeout, info));
  }

  /// 邀请者收到：被邀请者同意音视频通话
  void inviteeAccepted(SignalingInfo info) {
    Logger.print(
      'inviteeAccepted',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );
    _signalingInfo = info;
    signalingSubject.add(CallEvent(CallState.beAccepted, info));
  }

  /// 邀请者收到：被邀请者拒绝音视频通话
  void inviteeRejected(SignalingInfo info) {
    Logger.print(
      'inviteeRejected',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );
    _signalingInfo = info;
    if (!_currentIsSignal) {
      if (info.invitation?.groupID == _currentGroupID) {
        removeInvitee(info.userID!);
      }
    }
    signalingSubject.add(CallEvent(CallState.beRejected, info));
  }

  /// 被邀请者收到：音视频通话邀请
  void receiveNewInvitation(SignalingInfo info) {
    if (isBusy) {
      return;
    }
    Logger.print(
      'receiveNewInvitation',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );
    _signalingInfo = info;
    if (info.isGroup) {
      assignAllInvitee(info.invitation!.inviteeUserIDList!);
    }
    signalingSubject.add(CallEvent(CallState.beCalled, info));
  }

  /// 被邀请者（其他端）收到：比如被邀请者在手机拒接，在pc上会收到此回调
  void inviteeAcceptedByOtherDevice(SignalingInfo info) {
    Logger.print(
      'inviteeAcceptedByOtherDevice',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );
    _signalingInfo = info;
    signalingSubject.add(CallEvent(CallState.otherAccepted, info));
  }

  /// 被邀请者（其他端）收到：比如被邀请者在手机拒接，在pc上会收到此回调
  void inviteeRejectedByOtherDevice(SignalingInfo info) {
    Logger.print(
      'inviteeRejectedByOtherDevice',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );

    _signalingInfo = info;
    if (!_currentIsSignal) {
      if (info.invitation?.groupID == _currentGroupID) {
        removeInvitee(info.userID!);
      }
    }
    signalingSubject.add(CallEvent(CallState.otherReject, info));
  }

  /// 被挂断
  void beHangup(SignalingInfo info) {
    Logger.print(
      'beHangup',
      fileName: 'live_controller.dart',
      keyAndValues: ['opUserID', info.userID],
    );
    _signalingInfo = info;
    if (!_currentIsSignal) {
      if (info.invitation?.groupID == _currentGroupID) {
        _participantsID.removeWhere((element) => element == info.userID);
        removeInvitee(info.userID!, isInviterHungup: info.userID == info.invitation?.inviterUserID);
      }
    }
    signalingSubject.add(CallEvent(CallState.beHangup, info));
  }

  /// 群通话信息变更
  void roomParticipantConnected(RoomCallingInfo info) {
    if (_currentIsSignal || info.groupID != _currentGroupID) {
      return;
    }

    Logger.print(
      'roomParticipantConnected',
      fileName: 'live_controller.dart',
      keyAndValues: [
        'groupID',
        info.groupID,
        'participant',
        info.participant?.map((e) => e.userInfo?.userID).toList().join(',')
      ],
    );

    final pIDs = info.participant?.map((e) => e.userInfo!.userID!).toList() ?? [];
    _participantsID.assignAll(pIDs);

    roomParticipantConnectedSubject.add(info);
  }

  /// 群通话信息变更
  void roomParticipantDisconnected(RoomCallingInfo info) {
    if (_currentIsSignal || info.groupID != _currentGroupID) {
      return;
    }

    Logger.print(
      'roomParticipantDisconnected',
      fileName: 'live_controller.dart',
      keyAndValues: [
        'groupID',
        info.groupID,
        'participant',
        info.participant?.map((e) => e.userInfo?.userID).toList().join(',')
      ],
    );

    final pIDs = info.participant?.map((e) => e.userInfo!.userID!).toList() ?? [];
    _participantsID.assignAll(pIDs);

    roomParticipantDisconnectedSubject.add(info);
  }

  final insertSignalingMessageSubject = PublishSubject<CallEvent>();

  Function(SignalingMessageEvent)? onSignalingMessage;
  final roomParticipantDisconnectedSubject = PublishSubject<RoomCallingInfo>();
  final roomParticipantConnectedSubject = PublishSubject<RoomCallingInfo>();
  final inviteeSubject = PublishSubject<List<String>>();

  bool _isRunningBackground = false;

  /// 退到后台不会弹出拨号界面，切到前台后才会弹出界面。
  /// 如果存在值，表示收到了来电邀请，启动后需要恢复拨号界面
  CallEvent? _beCalledEvent;

  /// true:点击了系统桌面的接受按钮，恢复拨号界面后自动接听
  bool _autoPickup = false;

  final _ring = 'assets/audio/live_ring.wav';
  final _audioPlayer = AudioPlayer();
  final _androidAudioManager = Platform.isAndroid ? AndroidAudioManager() : null;
  final _avAudioSession = Platform.isIOS ? AVAudioSession() : null;

  // Invited list
  final _inviteeUsersID = <String>[];
  // in the livekit room
  final _participantsID = <String>[];

  void assignAllInvitee(List<String> userIDs) {
    _inviteeUsersID.assignAll(userIDs);
    inviteeSubject.add(_inviteeUsersID);
  }

  void removeInvitee(String userID, {bool isTimeout = false, bool isInviterHungup = false}) {
    _inviteeUsersID.remove(userID);
    inviteeSubject.add(_inviteeUsersID);

    var canClose = false;

    if (!_currentIsSignal && _participantsID.isEmpty) {
      if (_inviteeUsersID.isEmpty) {
        canClose = true;
      }
    } else {
      final leftParticipantCount = _participantsID.length;

      if (isInviterHungup && leftParticipantCount < 2) {
        canClose = true;
      } else if (leftParticipantCount < 2) {
        final p = _participantsID.firstOrNull;
        final isLeftInviter = p == _signalingInfo?.invitation?.inviterUserID;

        if (isLeftInviter) {
          if (_inviteeUsersID.isEmpty) {
            canClose = true;
          }
        } else {
          canClose = true;
        }
      }
    }

    Logger.print(
      'removeInvitee: [$userID] array: $_inviteeUsersID',
      fileName: 'live_controller.dart',
      keyAndValues: [
        'userID',
        userID,
        'canClose',
        canClose,
        'isTimeout',
        isTimeout,
        'isInviterHungup',
        isInviterHungup,
        '_inviteeUsersID',
        _inviteeUsersID,
        'participant.length',
        _participantsID.length
      ],
    );

    if (canClose) {
      if (isTimeout) {
        onTimeoutCancelled(_signalingInfo!);
      }
      _closeHelper();
    }
  }

  bool get isBusy => OpenIMLiveClient().isBusy;

  bool _currentIsSignal = false;

  String? _currentGroupID;

  SignalingInfo? _signalingInfo;

  Timer? _beCallTimer;

  CallEvent? _callEvent;

  Future<void> forceHunup() async {
    _stopSound();
    try {
      Logger.print('=========force hunup=========');
      if (_signalingInfo != null) {
        if (_participantsID.any((e) => e == OpenIM.iMManager.userID)) {
          Logger.print('=========signalingHungUp=========');
          await OpenIM.iMManager.signalingManager.signalingHungUp(
            info: _signalingInfo!..userID = OpenIM.iMManager.userID,
          );
        } else {
          Logger.print('=========signalingReject=========');
          await OpenIM.iMManager.signalingManager.signalingReject(
            info: _signalingInfo!..userID = OpenIM.iMManager.userID,
          );
        }
      }
      _resetFields();
      OpenIMLiveClient().close();
      Logger.print('=========OpenIMLiveClient().close();=========');
      return;
    } catch (e, s) {
      Logger.print('=========force hunup error: $e, $s==========');
      return;
    }
  }

  onCloseLive() {
    _inviteeUsersID.clear();
    // inviteeSubject.close();
    // signalingSubject.close();
    // insertSignalingMessageSubject.close();
    // roomParticipantDisconnectedSubject.close();
    // roomParticipantConnectedSubject.close();
    _resetFields();
    _stopSound();
    FlutterOpenimLiveAlert.closeLiveAlert();
  }

  onInitLive() async {
    _signalingListener();
    _insertSignalingMessageListener();

    // 桌面浮窗
    FlutterOpenimLiveAlert.buttonEvent(
      onAccept: () {
        // 自动接听
        _autoPickup = true;
      },
      onReject: () async {
        // 点击系统桌面浮窗的拒绝按钮
        await onTapReject(_beCalledEvent!.data..userID = OpenIM.iMManager.userID);
        // 重置拨号状态
        _beCalledEvent = null;
      },
    );

    // 群通话状态监听
    roomParticipantDisconnectedSubject.listen((info) {
      final hasOne = _participantsID.length < 2;

      if (null == info.participant || hasOne) {
        OpenIMLiveClient().closeByRoomID(info.invitation!.roomID!);
      }
    });
  }

  void callingTerminal() {
    Logger.print('==========callingTerminal==========');
    OpenIMLiveClient().roomDisconnect();
  }

  void enterbackground() {
    _isRunningBackground = true;
  }

  void enterforeground() {
    _isRunningBackground = false;
    // 恢复拨号界面
    if (_beCalledEvent != null) {
      signalingSubject.add(_beCalledEvent!);
    }

    _closeLiveAlert();
  }

  void _closeLiveAlert() {
    if (Platform.isAndroid) {
      FlutterOpenimLiveAlert.closeLiveAlert();
    }
  }

  /// 拦截其他干扰信令
  Stream<CallEvent> get _stream => signalingSubject.stream /*.where((event) => LiveClient.dispatchSignaling(event))*/;

  _signalingListener() => _stream.listen(
        (event) async {
          _callEvent = event;
          _beCalledEvent = null;
          if (event.state == CallState.beCalled) {
            _playSound();
            final mediaType = event.data.invitation!.mediaType;
            final sessionType = event.data.invitation!.sessionType;
            final callType = mediaType == 'audio' ? CallType.audio : CallType.video;
            final callObj = sessionType == ConversationType.single ? CallObj.single : CallObj.group;
            _currentIsSignal = callObj == CallObj.single;
            _currentGroupID = event.data.invitation?.groupID;

            if (sessionType == ConversationType.superGroup) {
              // If the client does not accept the audio or video invitation, the interface is closed.
              var timeout = event.data.invitation!.timeout ?? waitTimeout;
              _beCallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                timeout -= 1;
                if (timeout <= 0) {
                  timer.cancel();
                  if (!_participantsID.contains(OpenIM.iMManager.userID)) {
                    _stopSound();
                    _closeHelper();
                  }
                }
              });
            }

            if (Platform.isAndroid && _isRunningBackground) {
              // 记录拨号状态
              _beCalledEvent = event;
              if (await Permissions.checkSystemAlertWindow()) {
                // 如果当前处于后台，显示系统浮窗并拦截拨号界面
                var list = await OpenIM.iMManager.userManager.getUsersInfo(
                  userIDList: [event.data.invitation!.inviterUserID!],
                );
                // 后台弹框
                FlutterOpenimLiveAlert.showLiveAlert(
                  title: sprintf(StrRes.inviteYouCall,
                      [list.firstOrNull?.nickname, callType == CallType.audio ? StrRes.callVoice : StrRes.callVideo]),
                  rejectText: StrRes.rejectCall,
                  acceptText: StrRes.acceptCall,
                );
                return;
              }
            }
            // 重置
            _beCalledEvent = null;
            OpenIMLiveClient().start(
              Get.overlayContext!,
              callEventSubject: signalingSubject,
              roomID: event.data.invitation!.roomID!,
              inviteeUserIDList: event.data.invitation!.inviteeUserIDList!,
              inviterUserID: event.data.invitation!.inviterUserID!,
              groupID: event.data.invitation!.groupID,
              callType: callType,
              callObj: callObj,
              initState: CallState.beCalled,
              onSyncUserInfo: onSyncUserInfo,
              onSyncGroupInfo: onSyncGroupInfo,
              onSyncGroupMemberInfo: onSyncGroupMemberInfo,
              autoPickup: _autoPickup,
              onTapPickup: () => onTapPickup(
                event.data..userID = OpenIM.iMManager.userID,
              ),
              onTapReject: () => onTapReject(
                event.data..userID = OpenIM.iMManager.userID,
              ),
              onTapHangup: (duration, isPositive) => onTapHangup(
                event.data..userID = OpenIM.iMManager.userID,
                duration,
                isPositive,
              ),
              onError: onError,
              inviteeUserIDListSubject: inviteeSubject,
            );
          } else if (event.state == CallState.beRejected) {
            final sessionType = event.data.invitation!.sessionType;

            if (sessionType == ConversationType.superGroup) {
              if (_inviteeUsersID.isEmpty) {
                _stopSound();
                insertSignalingMessageSubject.add(event);
                _closeHelper();
              }
            } else {
              _stopSound();
              insertSignalingMessageSubject.add(event);
              _resetFields();
            }
          } else if (event.state == CallState.beHangup) {
            // 被挂断
            _stopSound();
            // 通过挂断方法插入通话时长消息
            // insertSignalingMessageSubject.add(event);
            final sessionType = event.data.invitation!.sessionType;
            final operatorID = event.data.userID!;
            final inviter = event.data.invitation!.inviterUserID!;
            final hasOne = _participantsID.length < 2 && _inviteeUsersID.isEmpty;

            if (sessionType == ConversationType.superGroup && operatorID == inviter && hasOne) {
              _closeHelper();
            }
          } else if (event.state == CallState.beCanceled) {
            // 超时被取消
            if (_isRunningBackground) {
              _closeLiveAlert();
            }
            _stopSound();
            insertSignalingMessageSubject.add(event);
            _resetFields();
          } else if (event.state == CallState.beAccepted) {
            // 被接听
            _stopSound();
          } else if (event.state == CallState.otherReject || event.state == CallState.otherAccepted) {
            // 被其他设备接听
            _stopSound();
            IMViews.showToast(sprintf(
                StrRes.otherCallHandle, [event.state == CallState.otherReject ? StrRes.rejectCall : StrRes.accept]));
            _closeHelper();
            if (_isRunningBackground) {
              _closeLiveAlert();
            }
          } else if (event.state == CallState.timeout) {
            // 超时无响应
            _stopSound();
            insertSignalingMessageSubject.add(event);
            final sessionType = event.data.invitation!.sessionType;

            if (sessionType == 1) {
              onTimeoutCancelled(event.data);
            }
          }
        },
      );

  _insertSignalingMessageListener() {
    insertSignalingMessageSubject.listen((value) {
      _insertMessage(
        state: value.state,
        signalingInfo: value.data,
        duration: value.fields ?? 0,
      );
    });
  }

  void _closeHelper() {
    _callEvent = null;
    _beCallTimer?.cancel();
    _beCallTimer = null;
    _resetFields();
    IMUtils.disableBackgroundExecution();
    OpenIMLiveClient().close();
  }

  void _resetFields() {
    _beCalledEvent = null;
    _signalingInfo = null;
  }

  call({
    required CallObj callObj,
    required CallType callType,
    CallState callState = CallState.call,
    String? roomID,
    String? inviterUserID,
    required List<String> inviteeUserIDList,
    String? groupID,
    SignalingCertificate? credentials,
  }) async {
    final mediaType = callType == CallType.audio ? 'audio' : 'video';
    final sessionType = callObj == CallObj.single ? 1 : 3;
    inviterUserID ??= OpenIM.iMManager.userID;
    assignAllInvitee(inviteeUserIDList);
    _currentIsSignal = callObj == CallObj.single;
    _currentGroupID = groupID;

    final signal = SignalingInfo(
      userID: inviterUserID,
      invitation: InvitationInfo(
        inviterUserID: inviterUserID,
        inviteeUserIDList: inviteeUserIDList,
        roomID: roomID ?? groupID ?? const Uuid().v4(),
        timeout: waitTimeout,
        mediaType: mediaType,
        sessionType: sessionType,
        platformID: IMUtils.getPlatform(),
        groupID: groupID,
      ),
    );
    _signalingInfo = signal;

    if (callState != CallState.join) {
      _playSound(); // play sound while start call somebody
    }
    OpenIMLiveClient().start(
      Get.overlayContext!,
      callEventSubject: signalingSubject,
      inviterUserID: inviterUserID,
      groupID: groupID,
      inviteeUserIDList: inviteeUserIDList,
      inviteeUserIDListSubject: inviteeSubject,
      callObj: callObj,
      callType: callType,
      initState: callState,
      onDialSingle: () => onDialSingle(signal),
      onDialGroup: () => onDialGroup(signal),
      onJoinGroup: () => Future.value(credentials!),
      onTapCancel: () => onTapCancel(signal),
      onTapHangup: (duration, isPositive) => onTapHangup(
        signal,
        duration,
        isPositive,
      ),
      onSyncUserInfo: onSyncUserInfo,
      onSyncGroupInfo: onSyncGroupInfo,
      onSyncGroupMemberInfo: onSyncGroupMemberInfo,
      onWaitingAccept: () {
        // _playSound();
      },
      onBusyLine: onBusyLine,
      onStartCalling: () {
        _stopSound();
      },
      onError: onError,
      onClose: onCloseLive,
      onAction: (type, userID) {
        switch (type) {
          case CallingOperationType.participantConnected:
            if (callObj == CallObj.group) {
              _stopSound();
            }
            break;
          case CallingOperationType.participantDisconnected:
            _participantsID.removeWhere((e) => e == userID);
            removeInvitee(userID);
            break;
          default:
        }
      },
      onEnabledSpeaker: (enabled) async {
        if (_callEvent?.state == CallState.beCalled ||
            _callEvent?.state == CallState.calling ||
            _callEvent?.state == CallState.beAccepted) {
          return;
        }
        // The problem occurs when the bluetooth headset is used as the output device.
        // if (enabled) {
        //   switchToSpeaker();
        // } else {
        //   switchToReceiver();
        // }
      },
    );
  }

  onError(error, stack) async {
    Logger.print(
      'onError=====> $error $stack',
      fileName: 'live_controller.dart',
    );

    var tips = StrRes.networkError;

    if (error is PlatformException) {
      if (int.parse(error.code) == SDKErrorCode.hasBeenBlocked) {
        tips = StrRes.callFail;
      } else if (int.parse(error.code) == SDKErrorCode.callingInviterIsBusy) {
        tips = StrRes.inviterBusyVideoCallHint;
      }

      _closeHelper();
      _stopSound();
    } else if (error is LiveKitException) {
      tips = kDebugMode ? error.message : '';
    } else if (error is MediaConnectException) {
      tips = kDebugMode ? error.message : '';
    } else {
      _closeHelper();
      _stopSound();
    }
    if (tips.isNotEmpty) {
      IMViews.showToast(tips);
    }

    return;
  }

  /// 拨向单人
  Future<SignalingCertificate> onDialSingle(SignalingInfo signaling) async {
    final offlinePushInfo = Config.offlinePushInfo;
    final newPushInfo = OfflinePushInfo(
      title: offlinePushInfo.title,
      desc: offlinePushInfo.desc,
      iOSBadgeCount: offlinePushInfo.iOSBadgeCount,
    )..title = StrRes.offlineCallMessage;

    final temp = await OpenIM.iMManager.signalingManager
        .signalingInvite(
            info: signaling
              ..invitation?.timeout = waitTimeout
              ..offlinePushInfo = newPushInfo)
        .catchError(onError);

    return temp;
  }

  /// 拨向多人
  Future<SignalingCertificate> onDialGroup(SignalingInfo signaling) {
    // _playSound();
    final offlinePushInfo = Config.offlinePushInfo;
    final newPushInfo = OfflinePushInfo(
      title: offlinePushInfo.title,
      desc: offlinePushInfo.desc,
      iOSBadgeCount: offlinePushInfo.iOSBadgeCount,
    )..title = StrRes.offlineCallMessage;

    return OpenIM.iMManager.signalingManager.signalingInviteInGroup(
      info: signaling
        ..invitation?.timeout = waitTimeout
        ..offlinePushInfo = newPushInfo,
    )
      ..then((value) {
        final busy = value.busyLineUserIDList;

        if (busy?.isNotEmpty == true) {
          for (var userID in busy!) {
            removeInvitee(userID);
          }
        }
      })
      ..catchError(onError);
  }

  /// 接听
  Future<SignalingCertificate> onTapPickup(SignalingInfo signaling) {
    _beCalledEvent = null; // ios bug
    _autoPickup = false;
    _beCallTimer?.cancel();
    _beCallTimer = null;
    _stopSound();
    return OpenIM.iMManager.signalingManager.signalingAccept(info: signaling).catchError(onError);
  }

  /// 拒绝
  onTapReject(SignalingInfo signaling) async {
    _stopSound();
    insertSignalingMessageSubject.add(CallEvent(CallState.reject, signaling));

    _resetFields();
    return OpenIM.iMManager.signalingManager.signalingReject(info: signaling);
  }

  /// 取消
  onTapCancel(SignalingInfo signaling) async {
    _stopSound();
    insertSignalingMessageSubject.add(CallEvent(CallState.cancel, signaling));

    _resetFields();
    OpenIM.iMManager.signalingManager.signalingCancel(info: signaling);
    return true;
  }

  /// 超时取消
  onTimeoutCancelled(SignalingInfo signaling) async {
    _resetFields();

    return OpenIM.iMManager.signalingManager.signalingCancel(
      info: signaling..userID = OpenIM.iMManager.userID,
    );
  }

  /// 挂断
  /// [isPositive] 人为挂断行为
  onTapHangup(SignalingInfo signaling, int duration, bool isPositive) async {
    Logger.print(
      'onTapHangup: ${signaling.userID} ${signaling.invitation?.groupID} $isPositive]',
      fileName: 'live_controller.dart',
    );
    if (isPositive) {
      await OpenIM.iMManager.signalingManager.signalingHungUp(
        info: signaling..userID = OpenIM.iMManager.userID,
      );
    }
    _stopSound();
    insertSignalingMessageSubject.add(CallEvent(
      CallState.hangup,
      signaling,
      fields: duration,
    ));

    _resetFields();
  }

  /// 用户繁忙
  onBusyLine() {
    _stopSound();
    IMViews.showToast('用户正忙，请稍后再试！');
  }

  onJoin() {}

  /// 同步用户信息
  Future<UserInfo?> onSyncUserInfo(userID) async {
    final friendInfo = await OpenIM.iMManager.friendshipManager.getFriendsInfo(userIDList: [userID]);

    if (friendInfo.isEmpty) {
      final list = await OpenIM.iMManager.userManager.getUsersInfo(
        userIDList: [userID],
      );

      return list.firstOrNull?.simpleUserInfo;
    }

    return friendInfo.firstOrNull?.simpleUserInfo;
  }

  /// 同步组信息
  Future<GroupInfo?> onSyncGroupInfo(groupID) async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [groupID],
    );
    return list.firstOrNull;
  }

  /// 同步群成员信息
  Future<List<GroupMembersInfo>> onSyncGroupMemberInfo(groupID, userIDList) async {
    var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupID: groupID,
      userIDList: userIDList,
    );
    return list;
  }

  /// 自定义通话消息
  void _insertMessage({
    required CallState state,
    required SignalingInfo signalingInfo,
    int duration = 0,
  }) async {
    (() async {
      var invitation = signalingInfo.invitation;
      var mediaType = invitation!.mediaType;
      var inviterUserID = invitation.inviterUserID;
      var inviteeUserID = invitation.inviteeUserIDList!.first;
      var groupID = invitation.groupID;
      Logger.print(
          'end calling and insert message state:${state.name}, mediaType:$mediaType, inviterUserID:$inviterUserID, inviteeUserID:$inviteeUserID, groupID:$groupID, duration:$duration',
          functionName: '_insertMessage');
      _recordCall(state: state, signaling: signalingInfo, duration: duration);
      var message = await OpenIM.iMManager.messageManager.createCallMessage(
        state: state.name,
        type: mediaType!,
        duration: duration,
      );
      switch (invitation.sessionType) {
        case 1:
          {
            String? receiverID;
            if (inviterUserID != OpenIM.iMManager.userID) {
              receiverID = inviterUserID;
            } else {
              receiverID = inviteeUserID;
            }

            var msg = await OpenIM.iMManager.messageManager.insertSingleMessageToLocalStorage(
              receiverID: inviteeUserID,
              senderID: inviterUserID,
              // receiverID: receiverID,
              // senderID: OpenIM.iMManager.uid,
              message: message
                ..status = 2
                ..isRead = true,
            );

            onSignalingMessage?.call(SignalingMessageEvent(msg, 1, receiverID, null));
            // signalingMessageSubject.add(
            //   SignalingMessageEvent(msg, 1, receiverID, null),
            // );
          }
          break;
        case 2:
          {
            // signalingMessageSubject.add(
            //   SignalingMessageEvent(message, 2, null, groupID),
            // );
            // OpenIM.iMManager.messageManager.insertGroupMessageToLocalStorage(
            //   groupID: groupID!,
            //   senderID: inviterUserID,
            //   message: message..status = 2,
            // );
          }
          break;
      }
    })();
  }

  /// 播放提示音
  void _playSound() async {
    if (!_audioPlayer.playerState.playing) {
      _audioPlayer.setAsset(_ring, package: 'openim_common');
      _audioPlayer.setLoopMode(LoopMode.one);

      await Future.delayed(const Duration(seconds: 1)); // experiment as needed

      _audioPlayer.setVolume(1.0);
      _audioPlayer.play();
    }
  }

  /// 关闭提示音
  void _stopSound() async {
    _callEvent = null;
    if (_audioPlayer.playerState.playing) {
      _audioPlayer.stop();
    }
  }

  Future<bool> switchToSpeaker() async {
    if (_androidAudioManager != null) {
      await _androidAudioManager!.setMode(AndroidAudioHardwareMode.normal);
      await _androidAudioManager!.stopBluetoothSco();
      await _androidAudioManager!.setBluetoothScoOn(false);
      await _androidAudioManager!.setSpeakerphoneOn(true);
    } else if (_avAudioSession != null) {
      await _avAudioSession!.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker);
    }

    return true;
  }

  Future<bool> switchToReceiver() async {
    if (_androidAudioManager != null) {
      await _androidAudioManager!.setMode(AndroidAudioHardwareMode.inCommunication);
      await _androidAudioManager!.stopBluetoothSco();
      await _androidAudioManager!.setBluetoothScoOn(false);
      await _androidAudioManager!.setSpeakerphoneOn(false);

      return true;
    } else if (_avAudioSession != null) {
      await _avAudioSession!.overrideOutputAudioPort(AVAudioSessionPortOverride.none);

      return _switchToAnyIosPortIn({AVAudioSessionPort.builtInMic});
    }

    return false;
  }

  Future<bool> _switchToAnyIosPortIn(Set<AVAudioSessionPort> ports) async {
    for (final input in await _avAudioSession!.availableInputs) {
      if (ports.contains(input.portType)) {
        await _avAudioSession!.setPreferredInput(input);
      }
    }

    return false;
  }

  void _recordCall({
    required CallState state,
    required SignalingInfo signaling,
    int duration = 0,
  }) async {
    var invitation = signaling.invitation;
    if (invitation!.sessionType != ConversationType.single) return;
    var mediaType = invitation.mediaType;
    var inviterUserID = invitation.inviterUserID;
    var inviteeUserID = invitation.inviteeUserIDList!.first;
    var isMeCall = inviterUserID == OpenIM.iMManager.userID;
    var userID = isMeCall ? inviteeUserID : inviterUserID!;
    var incomingCall = isMeCall ? false : true;
    var userInfo = (await OpenIM.iMManager.userManager.getUsersInfo(userIDList: [userID])).firstOrNull;
    if (null == userInfo) return;
    final cache = Get.find<CacheController>();
    cache.addCallRecords(CallRecords(
      userID: userID,
      nickname: userInfo.nickname ?? '',
      faceURL: userInfo.faceURL,
      success: state == CallState.hangup || state == CallState.beHangup,
      date: DateTime.now().millisecondsSinceEpoch,
      type: mediaType!,
      incomingCall: incomingCall,
      duration: duration,
    ));
  }
}

class SignalingMessageEvent {
  Message message;
  String? userID;
  String? groupID;
  int sessionType;

  SignalingMessageEvent(
    this.message,
    this.sessionType,
    this.userID,
    this.groupID,
  );

  /// 单聊消息
  bool get isSingleChat => sessionType == ConversationType.single;

  /// 群聊消息
  bool get isGroupChat => sessionType == ConversationType.group || sessionType == ConversationType.superGroup;
}

extension SignalingInfoExt on SignalingInfo {
  bool get isGroup => invitation?.groupID != null;
}
