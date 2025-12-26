import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../widgets/file_download_progress.dart';
import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  // final logic = Get.find<ChatLogic>();
  final logic = Get.find<ChatLogic>(tag: GetTags.chat);

  ChatPage({super.key});

  Widget _buildItemView(Message message, int index) {
    final userRole = logic.groupMemberRoleList.value
        .firstWhereOrNull((element) => element.userID == message.sendID);
    return ChatItemView(
      key: logic.itemKey(message),
      // isBubbleMsg: logic.showBubbleBg(message),
      message: message,
      textScaleFactor: logic.scaleFactor.value,
      allAtMap: logic.getAtMapping(message),
      timelineStr: logic.getShowTime(message),
      // clickSubject: logic.clickSubject,
      sendStatusSubject: logic.sendStatusSub,
      sendProgressSubject: logic.sendProgressSub,
      closePopMenuSubject: logic.forceCloseMenuSub,
      isMultiSelMode: logic.showCheckbox(message),
      // ignorePointer: logic.isMuted || logic.isInvalidGroup,
      checkedList: logic.multiSelList.value,
      enabledReadStatus: logic.enabledReadStatus(message),
      isPrivateChat: message.isPrivateType,
      readingDuration: logic.readTime(message),
      isPlayingSound: logic.isPlaySound(message),
      showLongPressMenu: !logic.isMuted && !logic.isInvalidGroup,
      canReEdit: logic.canEditMessage(message),
      leftNickname: logic.getNewestNickname(message),
      leftFaceUrl: logic.getNewestFaceURL(message),
      rightNickname: logic.senderName,
      rightFaceUrl: OpenIM.iMManager.userInfo.faceURL,
      showLeftNickname: !logic.isSingleChat,
      showRightNickname: !logic.isSingleChat,
      enabledCopyMenu: logic.showCopyMenu(message),
      enabledRevokeMenu: logic.showRevokeMenu(message),
      enabledReplyMenu: logic.showReplyMenu(message),
      enabledMultiMenu: logic.showMultiMenu(message),
      enabledForwardMenu: logic.showForwardMenu(message),
      enabledDelMenu: logic.showDelMenu(message),
      enabledAddEmojiMenu: logic.showAddEmojiMenu(message),
      onFailedToResend: () => logic.failedResend(message),
      onReEit: () => logic.reEditMessage(message),
      onDestroyMessage: () => logic.deleteMsg(message),
      onPopMenuShowChanged: logic.onPopMenuShowChanged,
      onClickItemView: () => logic.parseClickEvent(message, index),
      onViewMessageReadStatus: () {
        logic.viewGroupMessageReadStatus(message);
      },
      onMultiSelChanged: (checked) {
        logic.multiSelMsg(message, checked);
      },
      onTapCopyMenu: () => logic.copy(message),
      onTapDelMenu: () => logic.deleteMsg(message),
      onTapForwardMenu: () => logic.forward(message),
      onTapReplyMenu: () => logic.setQuoteMsg(message),
      onTapRevokeMenu: () {
        logic.markRevokedMessage(message);
        logic.revokeMsgV2(message);
      },
      onTapMultiMenu: () => logic.openMultiSelMode(message),
      onTapAddEmojiMenu: () => logic.addEmoji(message),
      visibilityChange: (msg, visible) {
        logic.markMessageAsRead(message, visible);
      },
      onLongPressLeftAvatar: () {
        logic.onLongPressLeftAvatar(message);
      },
      onLongPressRightAvatar: () {},
      onTapLeftAvatar: () {
        logic.onTapLeftAvatar(message);
      },
      onTapRightAvatar: logic.onTapRightAvatar,
      onTapQuoteMessage: (Message message) {
        logic.onTapQuoteMsg(message);
      },
      onVisibleTrulyText: (text) {
        logic.copyTextMap[message.clientMsgID] = text;
      },
      customTypeBuilder: _buildCustomTypeItemView,
      fileDownloadProgressView: FileDownloadProgressView(message),
      patterns: <MatchPattern>[
        MatchPattern(
          type: PatternType.at,
          onTap: logic.clickLinkText,
        ),
        MatchPattern(
          type: PatternType.email,
          onTap: logic.clickLinkText,
        ),
        MatchPattern(
          type: PatternType.url,
          onTap: logic.clickLinkText,
        ),
        MatchPattern(
          type: PatternType.mobile,
          onTap: logic.clickLinkText,
        ),
        MatchPattern(
          type: PatternType.tel,
          onTap: logic.clickLinkText,
        ),
      ],
      mediaItemBuilder: (context, message) {
        return _buildMediaItem(context, message);
      },
      onTapUserProfile: handleUserProfileTap,
      userLevel: logic.groupMemberLevelList.value[message.sendID],
      userRole: userRole?.roleLevel,
    );
  }

  void handleUserProfileTap(
      ({
        String userID,
        String name,
        String? faceURL,
        String? groupID
      }) userProfile) {
    final userInfo = UserInfo(
        userID: userProfile.userID,
        nickname: userProfile.name,
        faceURL: userProfile.faceURL);
    logic.viewUserInfo(userInfo);
  }

  Widget? _buildMediaItem(BuildContext context, Message message) {
    if (message.contentType != MessageType.picture &&
        message.contentType != MessageType.video) {
      return null;
    }
    Logger.print('message clientMsgID: ${message.clientMsgID}');
    return GestureDetector(
      onTap: () async {
        try {
          logic.stopVoice();
          final mediaMessages = await logic.searchMediaMessage();
          final temp = mediaMessages
              .firstWhereOrNull((e) => e.clientMsgID == message.clientMsgID);

          if (temp == null) {
            mediaMessages.add(message);
          }

          final cellIndex = mediaMessages
              .indexWhere((e) => e.clientMsgID == message.clientMsgID);

          if (cellIndex == -1 || !context.mounted) {
            return;
          }

          IMUtils.previewMediaFile(
              context: context,
              currentIndex: cellIndex,
              mediaMessages: mediaMessages,
              onAutoPlay: (index) {
                final msg = mediaMessages[index];
                return msg.clientMsgID == message.clientMsgID &&
                    !logic.playOnce;
              },
              muted: logic.rtcIsBusy,
              onPageChanged: (index) {
                logic.playOnce = true;
              },
              onOperate: (type) {
                if (type == OperateType.forward) {
                  logic.forward(message);
                }
              }).then((value) {
            logic.playOnce = false;
          });
        } catch (e) {
          IMViews.showToast(e.toString());
        }
      },
      child: Hero(
        tag: message.clientMsgID!,
        child: _buildMediaContent(message),
        placeholderBuilder:
            (BuildContext context, Size heroSize, Widget child) => child,
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    final isOutgoing = message.sendID == OpenIM.iMManager.userID;

    if (message.isVideoType) {
      return ChatVideoView(
        isISend: isOutgoing,
        message: message,
        sendProgressStream: logic.sendProgressSub,
        isSending: message.status == MessageStatus.sending,
      );
    } else {
      return ChatPictureView(
        isISend: isOutgoing,
        message: message,
        sendProgressStream: logic.sendProgressSub,
      );
    }
  }

  CustomTypeInfo? _buildCustomTypeItemView(_, Message message) {
    final data = IMUtils.parseCustomMessage(message);
    if (null != data) {
      final viewType = data['viewType'];
      if (viewType == CustomMessageType.call) {
        final type = data['type'];
        final content = data['content'];
        final view = ChatCallItemView(type: type, content: content);
        return CustomTypeInfo(view);
      } else if (viewType == CustomMessageType.deletedByFriend ||
          viewType == CustomMessageType.blockedByFriend) {
        final view = ChatFriendRelationshipAbnormalHintView(
          name: logic.nickname.value,
          onTap: logic.sendFriendVerification,
          blockedByFriend: viewType == CustomMessageType.blockedByFriend,
          deletedByFriend: viewType == CustomMessageType.deletedByFriend,
        );
        return CustomTypeInfo(view, false, false);
      } else if (viewType == CustomMessageType.meeting) {
        // 会议
        final inviterUserID = data['inviterUserID'];
        final inviterNickname = data['inviterNickname'];
        final inviterFaceURL = data['inviterFaceURL'];
        final subject = data['subject'];
        final id = data['id'];
        final start = data['start'];
        final duration = data['duration'];
        final view = ChatMeetingView(
          inviterUserID: inviterUserID,
          inviterNickname: inviterNickname,
          subject: subject,
          start: start,
          duration: duration,
          id: id,
        );
        return CustomTypeInfo(view, false, true);
      } else if (viewType == CustomMessageType.removedFromGroup) {
        return CustomTypeInfo(
          StrRes.removedFromGroupHint.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.groupDisbanded) {
        return CustomTypeInfo(
          StrRes.groupDisbanded.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.tag) {
        final isISend = message.sendID == OpenIM.iMManager.userID;
        if (null != data['textElem']) {
          final textElem = TextElem.fromJson(data['textElem']);
          return CustomTypeInfo(
            ChatText(
              // isISend: isISend,
              text: textElem.content ?? '',
              textScaleFactor: logic.scaleFactor.value,
              model: TextModel.normal,
            ),
          );
        } else if (null != data['soundElem']) {
          final soundElem = SoundElem.fromJson(data['soundElem']);
          return CustomTypeInfo(
            ChatVoiceView(
              isISend: isISend,
              soundPath: soundElem.soundPath,
              soundUrl: soundElem.sourceUrl,
              duration: soundElem.duration,
              isPlaying: logic.isPlaySound(message),
            ),
          );
        }
      }
    }
    return null;
  }

  Widget get _topNoticeView => logic.announcement.value.isNotEmpty
      ? TopNoticeView(
          content: logic.announcement.value,
          onPreview: logic.previewGroupAnnouncement,
          onClose: logic.closeGroupAnnouncement,
        )
      : const SizedBox();

  Widget? get _groupCallHintView => logic.participants.isEmpty
      ? null
      : ChatGroupCallHitView(
          expandPanel: logic.expandCallingMemberPanel,
          joinGroupCalling: logic.joinGroupCalling,
          showCallingMember: logic.showCallingMember.value,
          participants: logic.participants,
          isVideo: logic.roomCallingInfo?.invitation?.mediaType == 'video',
        );

  Widget? get _syncView => logic.syncStatusStr == null
      ? null
      : Column(
          children: [
            10.verticalSpace,
            SyncStatusView(
              isFailed: logic.isSyncFailed,
              statusStr: logic.syncStatusStr!,
            ),
          ],
        );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: logic.willPop(),
      child: ChatVoiceRecordLayout(
        onCompleted: logic.sendVoice,
        builder: (bar) => Obx(() {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Styles.c_F0F2F6,
                appBar: TitleBar.chat(
                  title: logic.nickname.value,
                  member: logic.memberStr,
                  subTitle: logic.subTile,
                  showOnlineStatus: logic.showOnlineStatus(),
                  isOnline: logic.onlineStatus.value,
                  isMultiModel: logic.multiSelMode.value,
                  showCallBtn: !logic.isInvalidGroup,
                  isMuted: logic.isMuted,
                  onCloseMultiModel: logic.exit,
                  onClickMoreBtn: logic.chatSetup,
                  onClickCallBtn: logic.call,
                ),
                body: SafeArea(
                  // top: false,
                  child: WaterMarkBgView(
                    text: '',
                    path: logic.background.value,
                    backgroundColor: Styles.c_FFFFFF,
                    // newMessageCount: logic.scrollingCacheMessageList.length,
                    // onSeeNewMessage: logic.scrollToIndex,
                    topView: _topNoticeView,
                    floatView: _groupCallHintView,
                    bottomView: ChatInputBox(
                      allAtMap: logic.atUserNameMappingMap,
                      forceCloseToolboxSub: logic.forceCloseToolbox,
                      controller: logic.inputCtrl,
                      focusNode: logic.focusNode,
                      enabled: !logic.isMuted,
                      hintText: logic.hintText,
                      inputFormatters: [AtTextInputFormatter(logic.openAtList)],
                      isMultiModel: logic.multiSelMode.value,
                      isNotInGroup: logic.isInvalidGroup,
                      quoteContent: logic.quoteContent.value,
                      onClearQuote: () => logic.setQuoteMsg(null),
                      directionalText: logic.directionalText(),
                      onCloseDirectional: logic.onClearDirectional,
                      onSend: (v) => logic.sendTextMsg(),
                      toolbox: ChatToolBox(
                          onTapAlbum: logic.onTapAlbum,
                          onTapCall: logic.call,
                          onTapCamera: logic.onTapCamera,
                          onTapCard: logic.onTapCarte,
                          onTapFile: logic.onTapFile,
                          onTapLocation: logic.onTapLocation,
                          showCard: logic.showCardIcon
                          // onTapDirectionalMessage: logic.onTapDirectionalMessage,
                          ),
                      voiceRecordBar: bar,
                      emojiView: ChatEmojiView(
                        textEditingController: logic.inputCtrl,
                        favoriteList: logic.cacheLogic.urlList,
                        // onAddEmoji: logic.onAddEmoji,
                        // onDeleteEmoji: logic.onDeleteEmoji,
                        onAddFavorite: logic.favoriteManage,
                        onSelectedFavorite: logic.sendFavoritePic,
                      ),
                      multiOpToolbox: ChatMultiSelToolbox(
                        onDelete: logic.mergeDelete,
                        onMergeForward: () => logic.forward(null),
                      ),
                    ),
                    child: ChatListView(
                      onTouch: () => logic.closeToolbox(),
                      itemCount: logic.messageList.length,
                      controller: logic.scrollController,
                      onScrollToBottomLoad: logic.onScrollToBottomLoad,
                      onScrollToTop: logic.onScrollToTop,
                      itemBuilder: (_, index) {
                        final message = logic.indexOfMessage(index);
                        return Obx(() => _buildItemView(message, index));
                      },
                    ),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
