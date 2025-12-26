import 'config.dart';

class Urls {
  static final onlineStatus =
      "${Config.imApiUrl}/manager/get_users_online_status";
  static final queryAllUsers = "${Config.imApiUrl}/manager/get_all_users_uid";
  static final updateUserInfo = "${Config.appAuthUrl}/user/update";
  static final searchFriendInfo = "${Config.appAuthUrl}/friend/search";
  static final getUsersFullInfo = "${Config.appAuthUrl}/user/find/full";
  static final searchUserFullInfo = "${Config.appAuthUrl}/user/search/full";

  static final getVerificationCode = "${Config.appAuthUrl}/account/code/send";
  static final checkVerificationCode =
      "${Config.appAuthUrl}/account/code/verify";
  static final register = "${Config.appAuthUrl}/account/register";

  static final resetPwd = "${Config.appAuthUrl}/account/password/reset";
  static final changePwd = "${Config.appAuthUrl}/account/password/change";
  static final login = "${Config.appAuthUrl}/account/login";

  static final upgrade = "${Config.appAuthUrl}/app/check";

  /// office
  static final tag = "${Config.appAuthUrl}/office/tag";
  static final getUserTags = "$tag/find/user";
  static final createTag = "$tag/add";
  static final deleteTag = "$tag/del";
  static final updateTag = "$tag/set";
  static final sendTagNotification = "$tag/send";
  static final getTagNotificationLog = "$tag/send/log";
  static final delTagNotificationLog = "$tag/send/log/del";

  /// 全局配置
  static final getClientConfig = '${Config.appAuthUrl}/client_config/get';

  /// 小程序
  static final uniMPUrl = '${Config.appAuthUrl}/applet/list';

  /// meeting
  static final meeting = '${Config.imApiUrl}/rtc-meeting';
  static final logout = '$meeting/logout';
  static final getMeetings = '$meeting/get_meetings';
  static final booking = '$meeting/book_meeting';
  static final quickly = '$meeting/create_immediate_meeting';
  static final join = '$meeting/join_meeting';
  static final getLiveToken = '$meeting/get_meeting_token';
  static final getMeeting = '$meeting/get_meeting';
  static final leaveMeeting = '$meeting/leave_meeting';
  static final endMeeting = '$meeting/end_meeting';
  static final setPersonalSetting = '$meeting/set_personal_setting';
  static final updateSetting = '$meeting/update_meeting';
  static final operateAllStream = '$meeting/operate_meeting_all_stream';
  static final modifyParticipantName =
      '$meeting/modify_meeting_participant_name';
  static final kickParticipants = '$meeting/remove_participants';
  static final setMeetingHost = '$meeting/set_meeting_host_info';

  //红包
  static final sendHongbao = '${Config.appAuthUrl}/red/send';
  static final receiveHongbao = '${Config.appAuthUrl}/red/receive';
  static final hongbaoRecord = '${Config.appAuthUrl}/red/record';
  static final hongbaoDetail = '${Config.appAuthUrl}/red/detail';
  static final hongbaoStatus = '${Config.appAuthUrl}/red/receive/record';

  // 群管理
  static final groupCategorySearch =
      '${Config.appAuthUrl}/group/category/search';
  static final groupSearch = '${Config.appAuthUrl}/group/search';
  static final groupApply = '${Config.appAuthUrl}/group/apply';
  static final groupUserTag = '${Config.appAuthUrl}/group/member/tags';
  static final getMyWalletLog = '${Config.appAuthUrl}/user/account/log';
  static final getGroupMemberLevel = '${Config.appAuthUrl}/group/member/level';
  static final doWithdraw = '${Config.appAuthUrl}/cash/apply';
  static final getWithdrawLog = '${Config.appAuthUrl}/cash/list';
  static final doSetSafePassword = '${Config.appAuthUrl}/user/safe_pwd';
  static final getBankList = '${Config.appAuthUrl}/bank/list';
  static final doBankAdd = '${Config.appAuthUrl}/bank/add';
  static final doBankDel = '${Config.appAuthUrl}/bank/del';
  static final doBankEdit = '${Config.appAuthUrl}/bank/update';
  static final getSmscode = '${Config.appAuthUrl}/account/code/send/logged';
  static final checkUpgrade = '${Config.appAuthUrl}/application/latest_version';
}
