import 'package:openim_common/openim_common.dart';

import 'o_urls.dart';

class OApis {
  static Future<OrganizationInfo?> getOrganizationInfo() async {
    var result = await HttpUtil.post(
      OUrls.queryOrganizationInfo,
      options: Apis.chatTokenOptions,
    );
    return result == null ? null : OrganizationInfo.fromJson(result);
  }

  static Future<DeptInfo> queryDepartment({
    List<String>? departmentIDs,
  }) async {
    var result = await HttpUtil.post(
      OUrls.queryDepartment,
      data: {'departmentIDs': departmentIDs},
      options: Apis.chatTokenOptions,
    );
    final departments = result['departments'] as List;

    final r2 = departments.map((e) => DeptInfo.fromJson(e)).toList();

    return r2.first;
  }

  static Future<List<DeptMemberInfo>> queryUserInDept({
    required List<String> userIDs,
  }) async {
    final result = await HttpUtil.post(
      OUrls.queryUserInDept,
      data: {'userIDs': userIDs},
      options: Apis.chatTokenOptions,
      showErrorToast: false,
    ) as Map<String, dynamic>;

    final r2 = UsersInDepts.fromMap(result);
    return r2.users.isEmpty ? [] : r2.users.first.members;
  }

  static Future<DeptMemberAndSubDept> getDeptMemberAndSubDept({
    String? departmentID,
  }) async {
    var result = await HttpUtil.post(
      OUrls.getDeptMemberAndSubDept,
      data: {'departmentID': departmentID},
      options: Apis.chatTokenOptions,
    );
    return DeptMemberAndSubDept.fromMap(result);
  }

  static Future<OrganizationSearchResult> searchDeptMember({
    String? keyword,
    bool showErrorToast = true,
    String? operationID,
  }) async {
    try {
      var result = await HttpUtil.post(
        OUrls.searchDeptMember,
        data: {
          'keyword': keyword,
          'pagination': {'pageNumber': 1, 'showNumber': 1000}
        },
        options: Apis.chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      final items = OrganizationSearchResult2.fromMap(result);
      final result2 = items.users == null
          ? <MemberUser>[]
          : items.users?.map((e) {
              final user = UserUser(
                  userId: e.userId, nickname: e.nickname, faceUrl: e.faceUrl);
              final member = DeptMemberInfo(
                  userID: e.members?.first.userID ?? e.userId,
                  nickname: e.members?.first.nickname ?? e.nickname,
                  faceURL: e.members?.first.faceURL ?? e.faceUrl);
              final mu = MemberUser(member: member, user: user);
              return mu;
            }).toList();
      return OrganizationSearchResult(members: result2!);
    } catch (e) {
      return OrganizationSearchResult(members: []);
    }
  }
}
