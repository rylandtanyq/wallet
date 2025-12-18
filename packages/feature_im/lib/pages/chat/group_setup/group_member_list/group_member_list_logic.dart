import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../core/controller/im_controller.dart';
import '../group_setup_logic.dart';

enum GroupMemberOpType {
  view,
  transferRight,
  call,
  at,
  del,
}

class GroupMemberListLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final groupSetupLogic = Get.find<GroupSetupLogic>();
  final controller = RefreshController();
  final memberList = <GroupMembersInfo>[].obs;
  final checkedList = <GroupMembersInfo>[].obs;
  final poController = CustomPopupMenuController();
  int count = 500;
  final myGroupMemberLevel = 1.obs;
  late GroupInfo groupInfo;
  late GroupMemberOpType opType;
  late StreamSubscription mISub;
  late StreamSubscription _guSub;
  bool get canLookMembersInfo =>
      groupInfo.lookMemberInfo != 1 ||
      myGroupMemberLevel.value != GroupRoleLevel.member;

  /// 多选模式
  bool get isMultiSelMode =>
      opType == GroupMemberOpType.call ||
      opType == GroupMemberOpType.at ||
      opType == GroupMemberOpType.del;

  /// 需要移除自己
  bool get excludeSelfFromList =>
      opType == GroupMemberOpType.call ||
      opType == GroupMemberOpType.at ||
      opType == GroupMemberOpType.transferRight;

  bool get isDelMember => opType == GroupMemberOpType.del;

  bool get isAdmin => myGroupMemberLevel.value == GroupRoleLevel.admin;

  bool get isOwner => myGroupMemberLevel.value == GroupRoleLevel.owner;

  bool get isOwnerOrAdmin => isAdmin || isOwner;

  int get maxLength => min(groupInfo.memberCount!, 10);

  @override
  void onClose() {
    mISub.cancel();
    _guSub.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    groupInfo = Get.arguments['groupInfo'];
    opType = Get.arguments['opType'];
    mISub = imLogic.memberInfoChangedSubject.listen(_updateMemberLevel);
    _guSub = imLogic.groupInfoUpdatedSubject.listen((value) {
      if (value.groupID == groupInfo.groupID) {
        groupInfo = value;
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    _queryMyGroupMemberLevel();
    super.onReady();
  }

  void _updateMemberLevel(GroupMembersInfo e) {
    if (e.groupID == groupInfo.groupID) {
      equal(GroupMembersInfo el) => el.userID == e.userID;
      final member = memberList.firstWhereOrNull(equal);
      if (null != member && e.roleLevel != member.roleLevel) {
        member.roleLevel = e.roleLevel;
        // memberList.refresh();
      }
      memberList.sort((a, b) {
        if (b.roleLevel != a.roleLevel) {
          return b.roleLevel!.compareTo(a.roleLevel!);
        } else {
          return b.joinTime!.compareTo(a.joinTime!);
        }
      });

      if (e.userID == OpenIM.iMManager.userID) {
        myGroupMemberLevel.value = e.roleLevel ?? 20;
      }
    }
  }

  void _queryMyGroupMemberLevel() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      final list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupID: groupInfo.groupID,
        userIDList: [OpenIM.iMManager.userID],
      );
      final myInfo = list.firstOrNull;
      if (null != myInfo) {
        myGroupMemberLevel.value = myInfo.roleLevel ?? 1;
      }
      await onLoad();
    });
  }

  Future<List<GroupMembersInfo>> _getGroupMembers() async {
    final result = await OpenIM.iMManager.groupManager.getGroupMemberList(
      groupID: groupInfo.groupID,
      count: count,
      offset: memberList.length,
    );

    if (isDelMember) {
      if (isOwner) {
        result.removeWhere(
            (element) => element.roleLevel == GroupRoleLevel.owner);
      } else if (isAdmin) {
        result.removeWhere((element) =>
            element.roleLevel == GroupRoleLevel.admin ||
            element.roleLevel == GroupRoleLevel.owner);
      }
    }

    count = 100;

    return result;
  }

  onLoad() async {
    final list = await _getGroupMembers();
    list.sort((a, b) {
      if (b.roleLevel != a.roleLevel) {
        return b.roleLevel!.compareTo(a.roleLevel!);
      } else {
        return b.joinTime!.compareTo(a.joinTime!);
      }
    });
    memberList.addAll(list);

    if (list.length < count) {
      controller.loadNoData();
    } else {
      controller.loadComplete();
    }
  }

  bool isChecked(GroupMembersInfo membersInfo) =>
      checkedList.contains(membersInfo);

  clickMember(GroupMembersInfo membersInfo) async {
    if (opType == GroupMemberOpType.transferRight) {
      _transferGroupRight(membersInfo);
      return;
    }
    if (isMultiSelMode) {
      if (isChecked(membersInfo)) {
        checkedList.remove(membersInfo);
      } else if (checkedList.length < maxLength) {
        checkedList.add(membersInfo);
      }
    } else if (isOwnerOrAdmin) {
      viewMemberInfo(membersInfo);
    }
  }

  static _transferGroupRight(GroupMembersInfo membersInfo) async {
    var confirm = await Get.dialog(CustomDialog(
      title: sprintf(StrRes.confirmTransferGroupToUser, [membersInfo.nickname]),
    ));
    if (confirm == true) {
      Get.back(result: membersInfo);
    }
  }

  void removeSelectedMember(GroupMembersInfo membersInfo) {
    checkedList.remove(membersInfo);
  }

  viewMemberInfo(GroupMembersInfo membersInfo) {
    if (!canLookMembersInfo) {
      return;
    }
    AppNavigator.startUserProfilePane(
      userID: membersInfo.userID!,
      groupID: membersInfo.groupID,
      nickname: membersInfo.nickname,
      faceURL: membersInfo.faceURL,
    );
  }

  void addMember() async {
    poController.hideMenu();
    await groupSetupLogic.addMember();
    refreshData();
  }

  void refreshData() {
    LoadingView.singleton.wrap(asyncFunction: () async {
      memberList.clear();
      await onLoad();
    });
  }

  void delMember() async {
    poController.hideMenu();
    await groupSetupLogic.removeMember();
    refreshData();
  }

  void search() async {
    final memberInfo = await AppNavigator.startSearchGroupMember(
      groupInfo: groupInfo,
      opType: opType,
    );
    if (opType == GroupMemberOpType.transferRight) {
      Get.back(result: memberInfo);
    } else if (isMultiSelMode) {
      clickMember(memberInfo);
    }
  }

  static _buildEveryoneMemberInfo() => GroupMembersInfo(
        userID: OpenIM.iMManager.conversationManager.atAllTag,
        nickname: StrRes.everyone,
      );

  void selectEveryone() {
    // checkedList.add(_buildEveryoneMemberInfo());
    // confirmSelectedMember();
    Get.back(result: <GroupMembersInfo>[_buildEveryoneMemberInfo()]);
  }

  void confirmSelectedMember() {
    Get.back(result: checkedList.value);
  }

  bool hiddenMember(GroupMembersInfo membersInfo) =>
      excludeSelfFromList && membersInfo.userID == OpenIM.iMManager.userID;
}
