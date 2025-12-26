import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_organization/openim_organization.dart';

abstract class SearchDeptMemberLogic extends GetxController {
  final deptMemberList = <DeptMemberInfo>[].obs;

  abstract String searchKey;

  Future<List<FriendInfo>> searchFriend() =>
      OpenIM.iMManager.friendshipManager.searchFriends(
        keywordList: [searchKey],
        isSearchRemark: true,
        isSearchNickname: true,
      );

  Future<OrganizationSearchResult> searchDeptMember() =>
      OApis.searchDeptMember(keyword: searchKey);

  void search() async {
    final result = await LoadingView.singleton.wrap(
        asyncFunction: () => Future.wait([searchFriend(), searchDeptMember()]));
    final friendList = result[0] as List<FriendInfo>;
    final deptMemberList =
        (result[1] as OrganizationSearchResult).members ?? [];
    if (friendList.isNotEmpty && deptMemberList.isNotEmpty) {}
  }
}
