import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_organization/openim_organization.dart';

import '../organization_logic.dart';

class SearchOrganizationLogic extends GetxController {
  final organizationLogic = Get.find<OrganizationLogic>();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final deptList = <DeptInfo>[].obs;
  final memberList = <MemberUser>[].obs;
  final count = 40;

  @override
  void onInit() {
    searchCtrl.addListener(_clearInput);
    super.onInit();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  _clearInput() {
    final key = searchCtrl.text.trim();
    if (key.isEmpty) {
      memberList.clear();
    }
  }

  bool get isSearchNotResult =>
      searchCtrl.text.trim().isNotEmpty && memberList.isEmpty;

  void search() async {
    if (searchCtrl.text.trim().isEmpty) {
      return;
    }
    var result = await LoadingView.singleton.wrap(
      asyncFunction: () => OApis.searchDeptMember(
        keyword: searchCtrl.text.trim(),
      ),
    );
    memberList.assignAll(result.members ?? []);
  }

  viewDeptMemberInfo(DeptMemberInfo memberInfo) =>
      organizationLogic.viewDeptMemberInfo(memberInfo);
}
