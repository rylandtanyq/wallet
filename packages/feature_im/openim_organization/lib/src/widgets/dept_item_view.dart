import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../o_apis.dart';
import '../routes/o_navigator.dart';

class DeptItemController extends GetxController {
  final organizationInfo = DeptInfo().obs;
  final userInDeptList = <DeptMemberInfo>[].obs;
  late String? userID;

  DeptItemController(this.userID);

  @override
  void onReady() {
    _queryOrganization();
    _queryUserInDept();
    super.onReady();
  }

  void _queryOrganization() async {
    final company = await OApis.getOrganizationInfo();
    if (company == null) {
      return;
    }
    var info = await OApis.queryDepartment();
    organizationInfo.update((val) {
      val?.departmentID = info.departmentID;
      val?.faceURL = info.faceURL;
      val?.name = info.name;
      val?.parentID = info.parentID;
      val?.order = info.order;
      val?.departmentType = info.departmentType;
      val?.createTime = info.createTime;
      val?.subDepartmentNum = info.subDepartmentNum;
      val?.memberNum = info.memberNum;
      val?.ex = info.ex;
      val?.attachedInfo = info.attachedInfo;
    });
  }

  void _queryUserInDept() async {
    var list = await OApis.queryUserInDept(
      userIDs: [userID ?? OpenIM.iMManager.userID],
    );
    userInDeptList.assignAll(list);
  }
}

enum DeptItemType {
  contacts,
  userProfilesPanel,
}

class DeptItemView extends StatelessWidget {
  const DeptItemView({
    Key? key,
    required this.type,
    this.userID,
  }) : super(key: key);
  final DeptItemType type;
  final String? userID;

  const DeptItemView.contacts({
    super.key,
    this.userID,
  }) : type = DeptItemType.contacts;

  const DeptItemView.userProfilesPanel({
    super.key,
    this.userID,
  }) : type = DeptItemType.userProfilesPanel;

  @override
  Widget build(BuildContext context) {
    if (type == DeptItemType.contacts) {
      return GetBuilder<DeptItemController>(
        init: DeptItemController(userID),
        global: false,
        builder: (logic) => Obx(() => _buildContactsView(logic)),
      );
    } else if (type == DeptItemType.userProfilesPanel) {
      return GetBuilder<DeptItemController>(
        init: DeptItemController(userID),
        global: false,
        builder: (logic) => Obx(() => _buildUserProfilesView(logic)),
      );
    }
    return const SizedBox();
  }

  Widget _buildContactsView(DeptItemController logic) {
    if (logic.organizationInfo.value.name?.isNotEmpty == true) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // _buildOrganizationEnterView(
          //   name: logic.organizationInfo.value.name!,
          //   faceUrl: logic.organizationInfo.value.faceURL,
          // ),
          ..._buildUserInDeptView(logic.userInDeptList),
        ],
      );
    }

    return Container();
  }

  Widget _buildOrganizationEnterView({
    required String name,
    String? faceUrl,
  }) =>
      Ink(
        color: Styles.c_FFFFFF,
        child: InkWell(
          onTap: ONavigator.startEnterOrganization,
          child: Container(
            height: 66.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                AvatarView(
                  width: 42.w,
                  height: 42.h,
                  text: name,
                  url: faceUrl,
                  textStyle: Styles.ts_FFFFFF_14sp_medium,
                ),
                12.horizontalSpace,
                name.toText..style = Styles.ts_0C1C33_17sp,
                const Spacer(),
                4.horizontalSpace,
                ImageRes.rightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
              ],
            ),
          ),
        ),
      );

  /// 我加入的部门
  List<Widget> _buildUserInDeptView(List<DeptMemberInfo> list) => list
      .map((dept) => Ink(
            color: Styles.c_FFFFFF,
            child: InkWell(
              onTap: () => ONavigator.startEnterOrganization(
                deptInfo: dept.department,
              ),
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42.w,
                      height: 42.h,
                      child: Center(
                        child: ImageRes.tree.toImage
                          ..width = 18.w
                          ..height = 18.h,
                      ),
                    ),
                    12.horizontalSpace,
                    (dept.department?.name ?? '').toText
                      ..style = Styles.ts_0C1C33_17sp,
                    const Spacer(),
                    4.horizontalSpace,
                    ImageRes.rightArrow.toImage
                      ..width = 24.w
                      ..height = 24.h,
                  ],
                ),
              ),
            ),
          ))
      .toList();

  Widget _buildUserProfilesView(DeptItemController logic) =>
      logic.userInDeptList.isNotEmpty == true
          ? Container(
              color: Styles.c_FFFFFF,
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.verticalSpace,
                  StrRes.organizationInfo.toText
                    ..style = Styles.ts_0C1C33_17sp_semibold,
                  8.verticalSpace,
                  _buildDeptItemView(
                    label: StrRes.organization,
                    value: logic.organizationInfo.value.name,
                  ),
                  ...logic.userInDeptList
                      .map((e) => _buildDeptItemView(
                            label: '${StrRes.department}/${StrRes.position}',
                            value: '${e.department?.name}/${e.position}',
                          ))
                      .toList(),
                ],
              ),
            )
          : Container();

  Widget _buildDeptItemView({
    required String label,
    String? value,
  }) =>
      SizedBox(
        height: 40.h,
        child: Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 88.w),
              child: label.toText..style = Styles.ts_8E9AB0_17sp,
            ),
            SizedBox(
              width: 8.w,
            ),
            (value ?? '').toText..style = Styles.ts_0C1C33_17sp,
          ],
        ),
      );

// Widget _buildTabView(UserInDept dept) => Table(
//       columnWidths: {0: FixedColumnWidth(67.w)},
//       children: [
//         _buildTabRowView(
//           label: StrRes.organization,
//           value: dept.department?.name,
//         ),
//         _buildTabRowView(
//           label: StrRes.department,
//           value: dept.department?.name,
//         ),
//         _buildTabRowView(
//           label: StrRes.position,
//           value: dept.member?.position,
//         ),
//       ],
//     );

// TableRow _buildTabRowView({
//   required String label,
//   String? value,
// }) =>
//     TableRow(
//       children: [
//         TableCell(
//           child: Container(
//             height: 40.h,
//             alignment: Alignment.centerLeft,
//             child: label.toText..style = Styles.ts_8E9AB0_17sp,
//           ),
//         ),
//         TableCell(
//           child: Container(
//             height: 40.h,
//             alignment: Alignment.centerLeft,
//             child: (value ?? '').toText..style = Styles.ts_0C1C33_17sp,
//           ),
//         ),
//       ],
//     );
}
