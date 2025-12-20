import 'dart:async';
import 'dart:io';

// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/openim_live.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

import '../im_callback.dart';

class IMController extends GetxController with IMCallback, OpenIMLive {
  late Rx<UserFullInfo> userInfo;
  late String atAllTag;

  bool _sdkInited = false;
  Completer<bool>? _initCompleter;

  @override
  void onInit() {
    super.onInit();
    onInitLive();

    userInfo = UserFullInfo.fromJson({}).obs;
    atAllTag = '';

    unawaited(initOpenIM());
  }

  @override
  void onClose() {
    onCloseLive();
    super.onClose();
  }

  Future<bool> initOpenIM({bool force = false}) async {
    // 重进IM时如果已经init过，也要再广播一次当前状态，
    // 不然 SplashLogic 新注册的 listener 收不到事件就卡死
    if (_initCompleter != null && !force) {
      try {
        initializedSubject.sink.add(_sdkInited); // 重放一次 true/false
      } catch (_) {}
      return _initCompleter!.future;
    }
    _initCompleter = Completer<bool>();

    try {
      final cachePath = await _ensureCachePathAndBasicEnv();

      final initialized = await OpenIM.iMManager.initSDK(
        platformID: IMUtils.getPlatform(),
        apiAddr: Config.imApiUrl,
        wsAddr: Config.imWsUrl,
        dataDir: cachePath,
        logLevel: Config.logLevel,
        logFilePath: cachePath,
        listener: OnConnectListener(
          onConnecting: () => imSdkStatus(IMSdkStatus.connecting),
          onConnectFailed: (code, error) => imSdkStatus(IMSdkStatus.connectionFailed),
          onConnectSuccess: () => imSdkStatus(IMSdkStatus.connectionSucceeded),
          onKickedOffline: kickedOffline,
          onUserTokenExpired: kickedOffline,
          onUserTokenInvalid: userTokenInvalid,
        ),
      );

      _sdkInited = initialized == true;
      initializedSubject.sink.add(_sdkInited);

      if (!_sdkInited) {
        _initCompleter!.complete(false);
        return false;
      }

      _bindListeners();

      Logger.print('---------------------initialized---------------------');
      _initCompleter!.complete(true);
      return true;
    } catch (e, s) {
      Logger.print('initOpenIM error: $e\n$s', isError: true);
      _sdkInited = false;
      initializedSubject.sink.add(false);

      if (!(_initCompleter?.isCompleted ?? true)) {
        _initCompleter!.complete(false);
      }
      return false;
    }
  }

  Future<String> _ensureCachePathAndBasicEnv() async {
    final doc = await getApplicationDocumentsDirectory();
    final dir = Directory('${doc.path}/openim');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final path = '${dir.path}/';

    try {
      final existed = Config.cachePath; // 可能会 throw LateInitializationError
      if (existed.isNotEmpty) return existed;
    } catch (_) {
      // ignore
    }
    try {
      Config.cachePath = path;
    } catch (_) {
      // ignore
    }

    try {
      await DataSp.init();
    } catch (_) {}
    try {
      HttpUtil.init();
    } catch (_) {}

    try {
      final raw = Config.serverIp.trim();
      final baseUrl = (raw.startsWith('http://') || raw.startsWith('https://')) ? raw : 'http://$raw';
      ApiService().setBaseUrl(baseUrl);
    } catch (_) {}

    return path;
  }

  void _bindListeners() {
    OpenIM.iMManager
      ..setUploadLogsListener(
        OnUploadLogsListener(onUploadProgress: uploadLogsProgress),
      )
      ..userManager.setUserListener(
        OnUserListener(
          onSelfInfoUpdated: (u) {
            selfInfoUpdated(u);
            userInfo.update((val) {
              val?.nickname = u.nickname;
              val?.faceURL = u.faceURL;
              val?.remark = u.remark;
              val?.ex = u.ex;
              val?.globalRecvMsgOpt = u.globalRecvMsgOpt;
            });
          },
          onUserStatusChanged: userStausChanged,
        ),
      )
      ..messageManager.setAdvancedMsgListener(
        OnAdvancedMsgListener(
          onRecvC2CReadReceipt: recvC2CMessageReadReceipt,
          onRecvNewMessage: recvNewMessage,
          onRecvGroupReadReceipt: recvGroupMessageReadReceipt,
          onNewRecvMessageRevoked: recvMessageRevoked,
          onRecvOfflineNewMessage: recvOfflineMessage,
        ),
      )
      ..messageManager.setMsgSendProgressListener(
        OnMsgSendProgressListener(onProgress: progressCallback),
      )
      ..messageManager.setCustomBusinessListener(
        OnCustomBusinessListener(onRecvCustomBusinessMessage: recvCustomBusinessMessage),
      )
      ..friendshipManager.setFriendshipListener(
        OnFriendshipListener(
          onBlackAdded: blacklistAdded,
          onBlackDeleted: blacklistDeleted,
          onFriendApplicationAccepted: friendApplicationAccepted,
          onFriendApplicationAdded: friendApplicationAdded,
          onFriendApplicationDeleted: friendApplicationDeleted,
          onFriendApplicationRejected: friendApplicationRejected,
          onFriendInfoChanged: friendInfoChanged,
          onFriendAdded: friendAdded,
          onFriendDeleted: friendDeleted,
        ),
      )
      ..conversationManager.setConversationListener(
        OnConversationListener(
          onConversationChanged: conversationChanged,
          onNewConversation: newConversation,
          onTotalUnreadMessageCountChanged: totalUnreadMsgCountChanged,
          onInputStatusChanged: inputStateChanged,
        ),
      )
      ..groupManager.setGroupListener(
        OnGroupListener(
          onGroupApplicationAccepted: groupApplicationAccepted,
          onGroupApplicationAdded: groupApplicationAdded,
          onGroupApplicationDeleted: groupApplicationDeleted,
          onGroupApplicationRejected: groupApplicationRejected,
          onGroupInfoChanged: groupInfoChanged,
          onGroupMemberAdded: groupMemberAdded,
          onGroupMemberDeleted: groupMemberDeleted,
          onGroupMemberInfoChanged: groupMemberInfoChanged,
          onJoinedGroupAdded: joinedGroupAdded,
          onJoinedGroupDeleted: joinedGroupDeleted,
        ),
      )
      ..signalingManager.setSignalingListener(
        OnSignalingListener(
          onInvitationCancelled: invitationCancelled,
          onInvitationTimeout: invitationTimeout,
          onInviteeAccepted: inviteeAccepted,
          onInviteeRejected: inviteeRejected,
          onReceiveNewInvitation: receiveNewInvitation,
        ),
      );
  }

  Future login(String userID, String token) async {
    final ok = await initOpenIM();
    if (!ok) return Future.error('OpenIM SDK init failed');

    try {
      final user = await OpenIM.iMManager.login(
        userID: userID,
        token: token,
        defaultValue: () async => UserInfo(userID: userID),
      );

      ApiService().setToken(token);
      userInfo = UserFullInfo.fromJson(user.toJson()).obs;

      _queryMyFullInfo();
      _queryAtAllTag();
    } catch (e, s) {
      Logger.print('login e: $e  s:$s', isError: true);
      await _handleLoginRepeatError(e);
      return Future.error(e, s);
    }
  }

  Future logout() async {
    if (!_sdkInited) return;
    return OpenIM.iMManager.logout();
  }

  void _queryAtAllTag() {
    if (!_sdkInited) return;
    atAllTag = OpenIM.iMManager.conversationManager.atAllTag;
  }

  void _queryMyFullInfo() async {
    if (!_sdkInited) return;
    final data = await Apis.queryMyFullInfo();
    if (data is UserFullInfo) {
      userInfo.update((val) {
        val?.allowAddFriend = data.allowAddFriend;
        val?.allowBeep = data.allowBeep;
        val?.allowVibration = data.allowVibration;
        val?.nickname = data.nickname;
        val?.faceURL = data.faceURL;
        val?.phoneNumber = data.phoneNumber;
        val?.email = data.email;
        val?.birth = data.birth;
        val?.gender = data.gender;
        val?.account = data.account;
      });
    }
  }

  Future<void> _handleLoginRepeatError(Object e) async {
    if (e is PlatformException && (e.code == "13002" || e.code == '1507')) {
      await logout();
      await DataSp.removeLoginCertificate();
    }
  }
}
