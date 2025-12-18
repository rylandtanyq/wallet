import 'package:collection/collection.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_organization/openim_organization.dart';

class SelectContactsFromOrganizationLogic extends GetxController {
  OrganizationMultiSelBridge get bridge => PackageBridge.organizationBridge!;
  final deptTreeList = <DeptInfo>[].obs;
  final subDeptList = <DeptInfo>[].obs;
  final deptMemberList = <MemberUser>[].obs;
  DeptInfo? startNode;

  @override
  void onReady() {
    loadSubDeptAndMemberList(startNode);
    super.onReady();
  }

  void loadSubDeptAndMemberList(DeptInfo? deptInfo) async {
    // var currentDept = deptTreeList.lastOrNull;
    // if (currentDept == null) return;
    final r = await LoadingView.singleton.wrap(
      asyncFunction: () => OApis.getDeptMemberAndSubDept(
        departmentID: deptInfo?.departmentID,
      ),
    );
    updateDefaultChecked(r.members);
    subDeptList.assignAll(r.departments);
    deptMemberList.assignAll(r.members);
    final node = r.parents + (r.current != null ? [r.current!] : []);
    deptTreeList.assignAll(node);
  }

  /// 打开子节点
  void openChildNode(DeptInfo curDept) {
    // deptTreeList.add(curDept);
    loadSubDeptAndMemberList(curDept);
  }

  /// 打开指定节点
  void openTreeNode(int index) {
    // deptTreeList..assignAll(deptTreeList.sublist(0, index + 1));
    loadSubDeptAndMemberList(deptTreeList.elementAt(index));
  }

  /// 回退上一级节点
  void backParentTreeNode() {
    if (deptTreeList.length - 1 == 0) {
      Get.back();
      return;
    }
    deptTreeList.assignAll(deptTreeList.sublist(0, deptTreeList.length - 1));
    final last = deptTreeList.lastOrNull;
    if (null != last) {
      loadSubDeptAndMemberList(last);
    }
  }

  Iterable<MemberUser> get operableList => deptMemberList.where(_remove);

  bool _remove(MemberUser info) => !bridge.isDefaultChecked(info);

  bool get isSelectAll {
    if (operableList.every((item) => bridge.isChecked(item))) {
      return true;
    } else {
      return false;
    }
  }

  selectAll() {
    if (isSelectAll) {
      for (var info in operableList) {
        bridge.removeItem(info);
      }
    } else {
      for (var info in operableList) {
        final isChecked = bridge.isChecked(info);
        if (!isChecked) {
          bridge.toggleChecked(info);
        }
      }
    }
  }

  updateDefaultChecked(List<MemberUser>? list) {
    if (null != list) {
      final userIDList = list.map((e) => e.member.userID!).toList();
      if (userIDList.isNotEmpty) {
        bridge.updateDefaultCheckedList(userIDList);
      }
    }
  }

  void toSearch() async {
    final result = await ONavigator.startSelectContactsFromSearchOrganization();
    if (null != result) {
      Get.back(result: result);
    }
  }
}
