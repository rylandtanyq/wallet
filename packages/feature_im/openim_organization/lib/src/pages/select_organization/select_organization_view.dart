import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'select_organization_logic.dart';

class SelectContactsFromOrganizationPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromOrganizationLogic>();

  SelectContactsFromOrganizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: logic.deptTreeList.firstOrNull?.name,
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Column(
        children: [
          Container(
            color: Styles.c_FFFFFF,
            child: GestureDetector(
              onTap: logic.toSearch,
              child: SearchBox(
                height: 36.h,
                margin: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
              ),
            ),
          ),
          Obx(() => _buildTreeTitle()),
          if (logic.bridge.isMultiModel)
            Obx(() => Visibility(
                  visible: logic.deptMemberList.isNotEmpty,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Ink(
                      height: 64.h,
                      color: Styles.c_FFFFFF,
                      child: InkWell(
                        onTap: logic.selectAll,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: ChatRadio(checked: logic.isSelectAll),
                              ),
                              10.horizontalSpace,
                              StrRes.selectAll.toText
                                ..style = Styles.ts_0C1C33_17sp,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          Expanded(
            child: Obx(() => CustomScrollView(
                  slivers: [
                    if (logic.deptMemberList.isNotEmpty)
                      SliverToBoxAdapter(child: 10.verticalSpace),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                          final info = logic.deptMemberList[index];
                          return _buildDeptMemberItemView(info);
                        },
                        childCount: logic.deptMemberList.length,
                      ),
                    ),
                    SliverToBoxAdapter(child: 10.verticalSpace),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                          final info = logic.subDeptList.elementAt(index);
                          return _buildDeptView(info);
                        },
                        childCount: logic.subDeptList.length,
                      ),
                    ),
                  ],
                )),
          ),
          logic.bridge.checkedConfirmView,
        ],
      ),
    );
  }

  Widget _buildTreeTitle() {
    var children = <Widget>[];
    for (var i = 0; i < logic.deptTreeList.length; i++) {
      children.add(GestureDetector(
        onTap: () => logic.openTreeNode(i),
        child: SizedBox(
          height: 24.h,
          child: (logic.deptTreeList.elementAt(i).name ?? '-').toText
            ..style = (i == logic.deptTreeList.length - 1
                ? Styles.ts_0089FF_14sp
                : Styles.ts_8E9AB0_14sp),
        ),
      ));
      if (i != logic.deptTreeList.length - 1) {
        children.add(ImageRes.rightArrow.toImage
          ..width = 24.w
          ..height = 24.h);
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: Styles.c_FFFFFF,
      alignment: Alignment.centerLeft,
      child: Wrap(
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10.h,
        spacing: 4.w,
        children: children,
      ),
    );
  }

  Widget _buildDeptView(DeptInfo deptInfo) => Ink(
        height: 64.h,
        color: Styles.c_FFFFFF,
        child: InkWell(
          onTap: () => logic.openChildNode(deptInfo),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: '${deptInfo.name}（${deptInfo.memberNum ?? 0}）'.toText
                    ..style = Styles.ts_0C1C33_17sp,
                ),
                ImageRes.rightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
              ],
            ),
          ),
        ),
      );

  Widget _buildDeptMemberItemView(MemberUser memberInfo) {
    Widget buildChild() => Ink(
          height: 64.h,
          color: Styles.c_FFFFFF,
          child: InkWell(
            onTap:
                logic.bridge.onTap(UserInfo.fromJson(memberInfo.user.toMap())),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  if (logic.bridge.isMultiModel)
                    Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: ChatRadio(
                        checked: logic.bridge.isChecked(memberInfo),
                        enabled: !logic.bridge.isDefaultChecked(memberInfo),
                      ),
                    ),
                  AvatarView(
                    width: 44.w,
                    height: 44.h,
                    url: memberInfo.user.faceUrl,
                    text: memberInfo.user.nickname,
                  ),
                  10.horizontalSpace,
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 100.w),
                    child: (memberInfo.user.nickname).toText
                      ..style = Styles.ts_0C1C33_17sp,
                  ),
                  4.horizontalSpace,
                  if (memberInfo.member.position != null &&
                      memberInfo.member.position!.isNotEmpty)
                    _buildPositionTagView(memberInfo.member.position!),
                ],
              ),
            ),
          ),
        );
    return logic.bridge.isMultiModel ? Obx(buildChild) : buildChild();
  }

  Widget _buildPositionTagView(String tag) => Container(
        padding: EdgeInsets.only(left: 6.w, right: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(
            color: Styles.c_0089FF,
            width: 1,
          ),
        ),
        child: tag.toText..style = Styles.ts_0089FF_10sp,
      );
}
