import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

class Apis {
  static Options get imTokenOptions =>
      Options(headers: {'token': DataSp.imToken});

  static Options get chatTokenOptions =>
      Options(headers: {'token': DataSp.chatToken});

  static StreamController kickoffController = StreamController<int>.broadcast();

  static void _kickoff(int? errCode) {
    if (errCode == 1501 ||
        errCode == 1503 ||
        errCode == 1504 ||
        errCode == 1505) {
      kickoffController.sink.add(errCode);
    }
  }

  /// login
  static Future<LoginCertificate> login({
    String? areaCode,
    String? phoneNumber,
    String? account,
    String? email,
    String? password,
    String? verificationCode,
  }) async {
    try {
      var data = await HttpUtil.post(Urls.login, data: {
        "areaCode": areaCode,
        'account': account,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': null != password ? IMUtils.generateMD5(password) : null,
        'platform': IMUtils.getPlatform(),
        'verifyCode': verificationCode,
      });
      final cert = LoginCertificate.fromJson(data!);
      ApiService().setToken(cert.imToken);

      return cert;
    } catch (e, _) {
      final t = e as (int, String?)?;

      if (t == null) {
        Logger.print('e:$e');

        return Future.error(e);
      }
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return Future.error(e);
    }
  }

  /// register
  static Future<LoginCertificate> register({
    required String nickname,
    required String password,
    String? faceURL,
    String? areaCode,
    String? phoneNumber,
    String? email,
    String? account,
    int birth = 0,
    int gender = 1,
    required String verificationCode,
    String? invitationCode,
  }) async {
    try {
      var data = await HttpUtil.post(Urls.register, data: {
        'deviceID': DataSp.getDeviceID(),
        'verifyCode': verificationCode,
        'platform': IMUtils.getPlatform(),
        'invitationCode': invitationCode,
        'autoLogin': true,
        'user': {
          "nickname": nickname,
          "faceURL": faceURL,
          'birth': birth,
          'gender': gender,
          'email': email,
          "areaCode": areaCode,
          'phoneNumber': phoneNumber,
          'account': account,
          'password': IMUtils.generateMD5(password),
        },
      });

      final cert = LoginCertificate.fromJson(data!);
      ApiService().setToken(cert.imToken);

      return cert;
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return Future.error(e);
    }
  }

  /// reset password
  static Future<dynamic> resetPassword({
    String? areaCode,
    String? phoneNumber,
    String? email,
    String?account,
    required String password,
    required String verificationCode,
  }) async {
    try {
      return HttpUtil.post(
        Urls.resetPwd,
        data: {
          "areaCode": areaCode,
          'phoneNumber': phoneNumber,
          'email': email,
          'account':account,
          'password': IMUtils.generateMD5(password),
          'verifyCode': verificationCode,
          'platform': IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
    }
  }

  /// change password
  static Future<bool> changePassword({
    required String userID,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await HttpUtil.post(
        Urls.changePwd,
        data: {
          "userID": userID,
          'currentPassword': IMUtils.generateMD5(currentPassword),
          'newPassword': IMUtils.generateMD5(newPassword),
          'platform': IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
      return true;
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return false;
    }
  }

  /// change password to b
  static Future<bool> changePasswordOfB({
    required String newPassword,
  }) async {
    try {
      await HttpUtil.post(
        Urls.resetPwd,
        data: {
          'password': IMUtils.generateMD5(newPassword),
          'platform': IMUtils.getPlatform(),
        },
        options: chatTokenOptions,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// update user info
  static Future<dynamic> updateUserInfo({
    required String userID,
    String? account,
    String? phoneNumber,
    String? areaCode,
    String? email,
    String? nickname,
    String? faceURL,
    int? gender,
    int? birth,
    int? level,
    int? allowAddFriend,
    int? allowBeep,
    int? allowVibration,
  }) async {
    try {
      Map<String, dynamic> param = {'userID': userID};
      void put(String key, dynamic value) {
        if (null != value) {
          param[key] = value;
        }
      }

      put('account', account);
      put('phoneNumber', phoneNumber);
      put('areaCode', areaCode);
      put('email', email);
      put('nickname', nickname);
      put('faceURL', faceURL);
      put('gender', gender);
      put('gender', gender);
      put('level', level);
      put('birth', birth);
      put('allowAddFriend', allowAddFriend);
      put('allowBeep', allowBeep);
      put('allowVibration', allowVibration);

      return HttpUtil.post(
        Urls.updateUserInfo,
        data: {
          ...param,
          'platform': IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
    }
  }

  static Future<List<FriendInfo>> searchFriendInfo(
    String keyword, {
    int pageNumber = 1,
    int showNumber = 10,
    bool showErrorToast = true,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.searchFriendInfo,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'keyword': keyword,
        },
        options: chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      if (data['users'] is List) {
        return (data['users'] as List)
            .map((e) => FriendInfo.fromJson(e))
            .toList();
      }
      return [];
    } catch (e, _) {
      if (e is (int, String?)) {
        final errCode = e.$1;
        final errMsg = e.$2;
        _kickoff(errCode);
        Logger.print('e:$errCode s:$errMsg');
      }
      return [];
    }
  }

  static Future<List<UserFullInfo>?> getUserFullInfo({
    int pageNumber = 0,
    int showNumber = 10,
    required List<String> userIDList,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.getUsersFullInfo,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'userIDs': userIDList,
          'platform': IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
      if (data['users'] is List) {
        return (data['users'] as List)
            .map((e) => UserFullInfo.fromJson(e))
            .toList();
      }
      return null;
    } catch (e, s) {
      if (e is (int, String?)) {
        final errCode = e.$1;
        final errMsg = e.$2;
        _kickoff(errCode);

        Logger.print('e:$errCode s:$errMsg');
      } else {
        _catchError(e, s);
      }
      return [];
    }
  }

  static Future<List<UserFullInfo>?> searchUserFullInfo({
    required String content,
    int pageNumber = 1,
    int showNumber = 10,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.searchUserFullInfo,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'keyword': content,
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
      if (data['users'] is List) {
        return (data['users'] as List)
            .map((e) => UserFullInfo.fromJson(e))
            .toList();
      }
      return null;
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return [];
    }
  }

  static Future<UserFullInfo?> queryMyFullInfo() async {
    final list = await Apis.getUserFullInfo(
      userIDList: [OpenIM.iMManager.userID],
    );
    return list?.firstOrNull;
  }

  /// 获取验证码
  /// [usedFor] 1：注册，2：重置密码 3：登录
  static Future<bool> requestVerificationCode({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required int usedFor,
    String? invitationCode,
  }) async {
    return HttpUtil.post(
      Urls.getVerificationCode,
      data: {
        "areaCode": areaCode,
        "phoneNumber": phoneNumber,
        "email": email,
        'usedFor': usedFor,
        'invitationCode': invitationCode
      },
    ).then((value) {
      IMViews.showToast(StrRes.sentSuccessfully);
      return true;
    }).catchError((e, s) {
      Logger.print('e:$e s:$s');
      return false;
    });
  }

  /// 校验验证码
  static Future<dynamic> checkVerificationCode({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required String verificationCode,
    required int usedFor,
    String? invitationCode,
  }) {
    return HttpUtil.post(
      Urls.checkVerificationCode,
      data: {
        "phoneNumber": phoneNumber,
        "areaCode": areaCode,
        "email": email,
        "verifyCode": verificationCode,
        "usedFor": usedFor,
        // 'operationID': operationID,
        'invitationCode': invitationCode
      },
    );
  }

  /// 蒲公英更新检测
  static Future<UpgradeInfoV2> checkUpgradeV2() {
    return dio.post<Map<String, dynamic>>(
      'https://www.pgyer.com/apiv2/app/check',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
      data: {
        '_api_key': '6f43600074306e8bc506ed0cd3275e9e',
        'appKey': 'dbccc0c5d85ca2e87dc20f9c13f8cf3a',
      },
    ).then((resp) {
      Map<String, dynamic> map = resp.data!;
      if (map['code'] == 0) {
        return UpgradeInfoV2.fromJson(map['data']);
      }
      return Future.error(map);
    });
  }

  /// discoverPageURL
  /// ordinaryUserAddFriend,
  /// bossUserID,
  /// adminURL ,
  /// allowSendMsgNotFriend
  /// needInvitationCodeRegister
  /// robots
  static Future<Map<String, dynamic>> getClientConfig() async {
    return {
      'discoverPageURL': Config.discoverPageURL,
      'allowSendMsgNotFriend': Config.allowSendMsgNotFriend,
      'financePageURL': Config.financePageURL,
    };
    try {
      var result = await HttpUtil.post(
        Urls.getClientConfig,
        data: {
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
        showErrorToast: false,
      );
      return result['config'] ?? {};
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return {};
    }
  }

  /// 查询tag组
  static Future<TagGroup> getUserTags({String? userID}) => HttpUtil.post(
        Urls.getUserTags,
        data: {'userID': userID},
        options: chatTokenOptions,
      ).then((value) => TagGroup.fromJson(value));

  /// 创建tag
  static createTag({
    required String tagName,
    required List<String> userIDList,
  }) {
    try {
      return HttpUtil.post(
        Urls.createTag,
        data: {'tagName': tagName, 'userIDs': userIDList},
        options: chatTokenOptions,
      );
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return null;
    }
  }

  /// 创建tag
  static deleteTag({required String tagID}) {
    try {
      return HttpUtil.post(
        Urls.deleteTag,
        data: {'tagID': tagID},
        options: chatTokenOptions,
      );
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return null;
    }
  }

  /// 创建tag
  static updateTag({
    required String tagID,
    required String name,
    required List<String> increaseUserIDList,
    required List<String> reduceUserIDList,
  }) {
    try {
      return HttpUtil.post(
        Urls.updateTag,
        data: {
          'tagID': tagID,
          'name': name,
          'addUserIDs': increaseUserIDList,
          'delUserIDs': reduceUserIDList,
        },
        options: chatTokenOptions,
      );
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return null;
    }
  }

  /// 下发tag通知
  static sendTagNotification({
    // required int contentType,
    TextElem? textElem,
    SoundElem? soundElem,
    PictureElem? pictureElem,
    VideoElem? videoElem,
    FileElem? fileElem,
    CardElem? cardElem,
    LocationElem? locationElem,
    List<String> tagIDList = const [],
    List<String> userIDList = const [],
    List<String> groupIDList = const [],
  }) async {
    try {
      return HttpUtil.post(
        Urls.sendTagNotification,
        data: {
          'tagIDs': tagIDList,
          'userIDs': userIDList,
          'groupIDs': groupIDList,
          'senderPlatformID': IMUtils.getPlatform(),
          'content': json.encode({
            'data': json.encode({
              "customType": CustomMessageType.tag,
              "data": {
                // 'contentType': contentType,
                'pictureElem': pictureElem?.toJson(),
                'videoElem': videoElem?.toJson(),
                'fileElem': fileElem?.toJson(),
                'cardElem': cardElem?.toJson(),
                'locationElem': locationElem?.toJson(),
                'soundElem': soundElem?.toJson(),
                'textElem': textElem?.toJson(),
              },
            }),
            'extension': '',
            'description': '',
          }),
        },
        options: chatTokenOptions,
      );
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return null;
    }
  }

  /// 获取tag通知列表
  static Future<List<TagNotification>> getTagNotificationLog({
    String? userID,
    required int pageNumber,
    required int showNumber,
  }) async {
    try {
      final result = await HttpUtil.post(
        Urls.getTagNotificationLog,
        data: {
          'userID': userID,
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
        },
        options: chatTokenOptions,
      );
      final list = result['tagSendLogs'];
      if (list is List) {
        return list.map((e) => TagNotification.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return [];
    }
  }

  static delTagNotificationLog({
    required List<String> ids,
  }) {
    try {
      return HttpUtil.post(
        Urls.delTagNotificationLog,
        data: <String, dynamic>{'ids': ids},
        options: chatTokenOptions,
      );
    } catch (e, s) {
      final t = e as (int, String?);
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return null;
    }
  }

  static Future _showHud<T>(Future<T> Function() asyncFunction,
      {bool show = true}) {
    return show
        ? LoadingView.singleton.wrap(asyncFunction: asyncFunction)
        : asyncFunction();
  }

  static Future meetingLogout() async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.logout,
          data: {
            'userID': DataSp.userID,
          },
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future getMeetings(Map<String, dynamic> params) async {
    try {
      if (DataSp.userID == null) {
        return null;
      }
      final result = await _showHud(
        () => ApiService().post(
          Urls.getMeetings,
          data: params,
        ),
        show: false,
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future getMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.getMeeting,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future bookingMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(Urls.booking, data: params),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future quicklyMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(Urls.quickly, data: params),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future joinMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(Urls.join, data: params),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return null;
    }
  }

  static Future createMeeting(String path, Map<String, dynamic> params) async {
    return await _showHud(
      () => ApiService().post(path, data: params),
    );
  }

  static Future getLiveKitToken(String meetingID, String userID) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.getLiveToken,
          data: {'meetingID': meetingID, 'userID': userID},
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future leaveMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.leaveMeeting,
          data: params,
        ),
        show: false,
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future endMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.endMeeting,
          data: params,
        ),
        show: false,
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future setPersonalSetting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.setPersonalSetting,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future updateMeetingSetting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.updateSetting,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future operateAllStream(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.operateAllStream,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future modifyParticipantName(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.modifyParticipantName,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future kickParticipant(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.kickParticipants,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future setMeetingHost(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.setMeetingHost,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static void _catchError(Object e, StackTrace s, {bool forceBack = true}) {
    if (e is ApiException) {
      var msg = '${e.code}'.tr;
      if (msg.isEmpty || e.code.toString() == msg) {
        msg = e.message ?? 'Unkonw error';
      } else if (e.code == 1004) {
        msg = sprintf(msg, [StrRes.meeting]);
      }

      IMViews.showToast(msg);

      if ((e.code == 10010 || e.code == 10002) && forceBack) {
        DataSp.removeLoginCertificate();
        Get.offAllNamed('/login');
      }
    } else {
      NetworkMonitor().isNetworkAvailable().then((isAvailable) {
        if (isAvailable) {
          IMViews.showToast(e.toString());
        } else {
          IMViews.showToast(
              '${StrRes.networkNotStable}，${StrRes.operateAgain}');
        }
      });
    }
  }

  //发送红包
  static Future<dynamic> sendHongbao({
    required String pwd,
    required int type,
    required int category,
    required double totalAmount,
    required int TotalCount,
    required String TargetID,
    required String content,
  }) async {
    final data = await HttpUtil.post(Urls.sendHongbao,
        data: {
          "pwd": pwd,
          "type": type,
          "category": category,
          "totalAmount": totalAmount,
          "TotalCount": TotalCount,
          "TargetID": TargetID,
          "content": content
        },
        options: chatTokenOptions);
    return data;
  }

  //领取红包
  static Future<dynamic> receiveHongbao({required String uuid}) async {
    final data = await HttpUtil.post(Urls.receiveHongbao,
        data: {"uuid": uuid}, options: chatTokenOptions);
    return data;
  }

  static Future<Hongbao> getHongbaoDetail({
    required String uuid,
  }) async {
    final data = await HttpUtil.post(Urls.hongbaoDetail,
        data: {"uuid": uuid}, options: chatTokenOptions);
    final info = Hongbao.fromJson(data["red"]);
    return info;
  }

  static Future<UserInfoHongbaoRecord?> getHongbaoRecord(
    String uuid,
    String userID, {
    int pageNumber = 1,
    int showNumber = 10,
    bool showErrorToast = true,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.hongbaoRecord,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'uuid': uuid,
          'userID': "",
        },
        options: chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      return UserInfoHongbaoRecord.fromJson(data);
    } catch (e, _) {
      if (e is (int, String?)) {
        final errCode = e.$1;
        final errMsg = e.$2;
        _kickoff(errCode);
        Logger.print('e:$errCode s:$errMsg');
      }
      return null;
    }
  }

  static Future<dynamic> getHongbaoStatus(
      {required List<String> uuid, required String userID}) async {
    final data = await HttpUtil.post(Urls.hongbaoStatus,
        data: {"uuid": uuid, "userID": userID}, options: chatTokenOptions);
    final info = data["result"];
    return info;
  }

  // 群管理
  static Future<dynamic> getGroupCategorys({
    int pageNumber = 1,
    int showNumber = 1000,
    bool showErrorToast = true,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.groupCategorySearch,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'status': 1,
        },
        options: chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      return data['categories'];
    } catch (e, _) {
      if (e is (int, String?)) {
        final errCode = e.$1;
        final errMsg = e.$2;
        _kickoff(errCode);
        Logger.print('e:$errCode s:$errMsg');
      }
      return null;
    }
  }

  static Future<dynamic> getGroupSearch(
      {required List<String> categoryIDs}) async {
    final data = await HttpUtil.post(Urls.groupSearch,
        data: {"categoryIDs": categoryIDs, "isHome": 1},
        options: chatTokenOptions);
    var info = [];
    if (data["groups"] is List) {
      info = data["groups"];
    }
    return info;
  }

  static Future<dynamic> groupUserTag({required String groupID}) async {
    final data = await HttpUtil.post(Urls.groupUserTag,
        data: {"groupID": groupID}, options: chatTokenOptions);
    final info = data["result"];
    return info;
  }

  static Future<dynamic> getMyWalletLogs(
    String userID, {
    int pageNumber = 1,
    int showNumber = 10,
    bool showErrorToast = true,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.getMyWalletLog,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'userID': userID,
        },
        options: chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      return data["logs"] != null ? data["logs"] : [];
    } catch (e, _) {
      if (e is (int, String?)) {
        final errCode = e.$1;
        final errMsg = e.$2;
        _kickoff(errCode);
        Logger.print('e:$errCode s:$errMsg');
      }
      return null;
    }
  }

  static Future<dynamic> getGroupMemberLevel({required String groupID}) async {
    final data = await HttpUtil.post(Urls.getGroupMemberLevel,
        data: {"groupID": groupID}, options: chatTokenOptions);
    final info = data["result"] == null ? null : data["result"];
    return info;
  }

  static Future<dynamic> setSafePwd(
      {required String pwd, required String verifyCode}) async {
    final data = await HttpUtil.post(Urls.doSetSafePassword,
        data: {"pwd": pwd, "verifyCode": verifyCode},
        options: chatTokenOptions);
    final info = data;
    return info;
  }

  static Future<UserBankList?> getBankList({
    int pageNumber = 1,
    int showNumber = 10,
    bool showErrorToast = true,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.getBankList,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
        },
        options: chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      return UserBankList.fromJson(data);
    } catch (e, _) {
      if (e is (int, String?)) {
        final errCode = e.$1;
        final errMsg = e.$2;
        _kickoff(errCode);
        Logger.print('e:$errCode s:$errMsg');
      }
      return null;
    }
  }

  static Future<dynamic> doBankAdd(
      {required String bankUserName,
      required String bankName,
      required String bankCardNo}) async {
    final data = await HttpUtil.post(Urls.doBankAdd,
        data: {
          "bankUserName": bankUserName,
          "bankName": bankName,
          "bankCardNo": bankCardNo
        },
        options: chatTokenOptions);
    final info = data;
    return info;
  }

  static Future<dynamic> doBankDel({required List<String> id}) async {
    final data = await HttpUtil.post(Urls.doBankDel,
        data: {"id": id}, options: chatTokenOptions);
    final info = data;
    return info;
  }

  static Future<dynamic> doWithdraw(
      {required String bankName,
      required String bankUserName,
      required String bankCardNo,
      required double amount,
      required String pwd}) async {
    final data = await HttpUtil.post(Urls.doWithdraw,
        data: {
          "bankUserName": bankUserName,
          "bankName": bankName,
          "bankCardNo": bankCardNo,
          "amount": amount,
          "pwd": pwd
        },
        options: chatTokenOptions);
    final info = data;
    return info;
  }

  static Future<dynamic> getWithdrawLogs({
    int pageNumber = 1,
    int showNumber = 10,
    bool showErrorToast = true,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.getWithdrawLog,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
        },
        options: chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      return data["cashs"] != null ? data["cashs"] : [];
    } catch (e, _) {
      if (e is (int, String?)) {
        final errCode = e.$1;
        final errMsg = e.$2;
        _kickoff(errCode);
        Logger.print('e:$errCode s:$errMsg');
      }
      return null;
    }
  }

  static Future<dynamic> getSmsCode({required int usedFor}) async {
    final data = await HttpUtil.post(Urls.getSmscode,
        data: {"usedFor": usedFor}, options: chatTokenOptions);
    final info = data;
    return info;
  }

  /// 后台更新APP检测
  static Future<UpgradeInfoByServer> checkUpgradeByServer(
      {required String platform, required String version}) async {
    try {
      var data = await HttpUtil.post(Urls.checkUpgrade,
          data: {"platform": platform, "version": version});
      final result = UpgradeInfoByServer.fromJson(data["version"]);
      return result;
    } catch (e, _) {
      final t = e as (int, String?)?;

      if (t == null) {
        Logger.print('e:$e');

        return Future.error(e);
      }
      final errCode = t.$1;
      final errMsg = t.$2;
      _kickoff(errCode);
      Logger.print('e:$errCode s:$errMsg');
      return Future.error(e);
    }
  }
}
