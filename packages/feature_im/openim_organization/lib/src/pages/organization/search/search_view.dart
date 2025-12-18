import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import 'search_logic.dart';

class SearchOrganizationPage extends StatelessWidget {
  final logic = Get.find<SearchOrganizationLogic>();

  SearchOrganizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: TitleBar.search(
          focusNode: logic.focusNode,
          controller: logic.searchCtrl,
          onSubmitted: (_) => logic.search(),
          onCleared: () => logic.focusNode.requestFocus(),
        ),
        backgroundColor: Styles.c_F8F9FA,
        body: Obx(() => logic.isSearchNotResult
            ? _emptyListView
            : ListView.builder(
                itemCount: logic.memberList.length,
                itemBuilder: (_, index) =>
                    _buildDeptMemberItemView(logic.memberList[index]),
              )),
      ),
    );
  }

  Widget _buildDeptMemberItemView(MemberUser memberInfo) => Ink(
        height: 64.h,
        color: Styles.c_FFFFFF,
        child: InkWell(
          onTap: () => logic.viewDeptMemberInfo(memberInfo.member),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                AvatarView(
                  width: 44.w,
                  height: 44.h,
                  url: memberInfo.user.faceUrl,
                  text: memberInfo.user.nickname,
                ),
                10.horizontalSpace,
                // ConstrainedBox(
                //   constraints: BoxConstraints(maxWidth: 100.w),
                //   child: (memberInfo.nickname ?? '').toText
                //     ..style = Styles.ts_0C1C33_17sp,
                // ),
                SearchKeywordText(
                  text: memberInfo.user.nickname,
                  keyText: logic.searchCtrl.text.trim(),
                  style: Styles.ts_0C1C33_17sp,
                  keyStyle: Styles.ts_0089FF_17sp,
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

  Widget get _emptyListView => SizedBox(
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 157.verticalSpace,
            // ImageRes.blacklistEmpty.toImage
            //   ..width = 120.w
            //   ..height = 120.h,
            // 22.verticalSpace,
            44.verticalSpace,
            StrRes.searchNotFound.toText..style = Styles.ts_8E9AB0_17sp,
          ],
        ),
      );
}
