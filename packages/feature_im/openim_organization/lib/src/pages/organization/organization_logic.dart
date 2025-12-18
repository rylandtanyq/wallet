import 'package:collection/collection.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_organization/openim_organization.dart';

class OrganizationLogic extends GetxController {
  final deptTreeList = <DeptInfo>[].obs;
  final subDeptList = <DeptInfo>[].obs;
  final deptMemberList = <MemberUser>[].obs;
  DeptInfo? startNode;

  @override
  void onInit() {
    startNode = Get.arguments['deptInfo'];
    super.onInit();
  }

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
          departmentID: deptInfo?.departmentID ?? ''),
    );
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

  viewDeptMemberInfo(DeptMemberInfo memberInfo) =>
      PackageBridge.viewUserProfileBridge!.viewUserProfile(
        memberInfo.userID!,
        memberInfo.nickname,
        memberInfo.faceURL,
      );

  void toSearch() => ONavigator.startSearchOrganization();
}
