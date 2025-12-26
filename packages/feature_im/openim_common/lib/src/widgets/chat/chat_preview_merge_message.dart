import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_quote_view.dart';

class ChatPreviewMergeMsgView extends StatelessWidget {
  ChatPreviewMergeMsgView(
      {super.key,
      required this.messageList,
      required this.title,
      this.meetingItemClick});

  final List<Message> messageList;
  final String title;
  final Function(Message msg)? meetingItemClick;
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
      },
      child: Scaffold(
        appBar: TitleBar.back(title: title),
        backgroundColor: Styles.c_F8F9FA,
        body: ListView.builder(
          itemCount: messageList.length,
          shrinkWrap: true,
          itemBuilder: (_, index) => _buildItemView(index),
        ),
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    final isOutgoing = message.sendID == OpenIM.iMManager.userID;

    if (message.isVideoType) {
      return ChatVideoView(
        isISend: isOutgoing,
        message: message,
        sendProgressStream: null,
      );
    } else {
      return ChatPictureView(
        isISend: isOutgoing,
        message: message,
        sendProgressStream: null,
      );
    }
  }

  Widget _buildItemView(int index) {
    var message = messageList[index];
    //和上个数据是否相同,相同就隐藏头像
    bool isSame = index == 0
        ? false
        : messageList[index - 1].senderFaceUrl == message.senderFaceUrl;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        focusNode.unfocus();
        if (message.isCustomType) {
          final data = IMUtils.parseCustomMessage(message);
          if (null != data) {
            final viewType = data['viewType'];
            if (viewType == CustomMessageType.meeting) {
              meetingItemClick?.call(message);
              return;
            }
          }
        }
        IMUtils.parseClickEvent(
          message,
          messageList: [message],
          onViewUserInfo: (userInfo) {
            final arguments = {
              'userID': userInfo.userID,
              'nickname': userInfo.nickname,
              'faceURL': userInfo.faceURL,
            };
            Get.toNamed(
              '/user_profile_panel',
              arguments: arguments,
              preventDuplicates: false,
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility.maintain(
              visible: !isSame,
              child: AvatarView(
                url: message.senderFaceUrl,
                text: message.senderNickname,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10.w),
                padding: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(color: Styles.c_E8EAEF, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: (message.senderNickname ?? '').toText
                            ..style = Styles.ts_8E9AB0_12sp,
                        ),
                        IMUtils.getChatTimeline(message.sendTime!).toText
                          ..style = Styles.ts_8E9AB0_12sp,
                      ],
                    ),
                    10.verticalSpace,
                    buildItemContent(message)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItemContent(Message message) {
    String content = "[${StrRes.specialMessage}]";
    bool isISend = message.sendID == OpenIM.iMManager.userID;
    if (message.isTextType) {
      content = message.textElem!.content!;
      return ChatText(
        text: content,
        patterns: <MatchPattern>[
          MatchPattern(
            type: PatternType.email,
            onTap: clickLinkText,
          ),
          MatchPattern(
            type: PatternType.url,
            onTap: clickLinkText,
          ),
          MatchPattern(
            type: PatternType.mobile,
            onTap: clickLinkText,
          ),
          MatchPattern(
            type: PatternType.tel,
            onTap: clickLinkText,
          ),
        ],
      );
    }
    if (message.isPictureType || message.isVideoType) {
      return _buildMediaContent(message);
    }
    if (message.isVoiceType) {
      final sound = message.soundElem;
      return "[${StrRes.voice}]${sound?.duration}''".toText
        ..style = Styles.ts_8E9AB0_15sp;
      // return Container(
      //   padding: EdgeInsets.all(5.sp),
      //   decoration: BoxDecoration(
      //       color: const Color(0xFFf4f5f7),
      //       borderRadius: BorderRadius.only(
      //         topLeft: const Radius.circular(0),
      //         topRight: Radius.circular(6.r),
      //         bottomLeft: Radius.circular(6.r),
      //         bottomRight: Radius.circular(6.r),
      //       )),
      //   child: ChatVoiceView(
      //     isISend: isISend,
      //     soundPath: sound?.soundPath,
      //     soundUrl: sound?.sourceUrl,
      //     duration: sound?.duration,
      //     isPlaying: false,
      //   ),
      // );
    }
    if (message.isFileType) {
      return ChatFileView(
        message: message,
        isISend: isISend,
        sendProgressStream: null,
        fileDownloadProgressView: null,
      );
    }
    if (message.isLocationType) {
      final location = message.locationElem;
      return ChatLocationView(
        description: location!.description!,
        latitude: location.latitude!,
        longitude: location.longitude!,
      );
    }
    if (message.isMergerType) {
      return ChatMergeMsgView(
        title: message.mergeElem?.title ?? '',
        summaryList: message.mergeElem?.abstractList ?? [],
      );
    }
    if (message.isCardType) {
      return ChatCarteView(cardElem: message.cardElem!);
    }

    if (message.isQuoteType) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatText(text: message.quoteElem?.text ?? ''),
          ChatQuoteView(
            quoteMsg: message.quoteMessage!,
          ),
        ],
      );
    }
    if (message.isCustomFaceType) {
      final face = message.faceElem;
      return ChatCustomEmojiView(
        index: face?.index,
        data: face?.data,
        isISend: isISend,
        heroTag: message.clientMsgID,
      );
    }
    if (message.isCustomType) {
      final data = IMUtils.parseCustomMessage(message);
      if (null != data) {
        final viewType = data['viewType'];
        if (viewType == CustomMessageType.meeting) {
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
          return view;
        }
      }
    }
    return MatchTextView(
      text: content,
      textStyle: Styles.ts_0C1C33_17sp,
      isSupportCopy: true,
      copyFocusNode: focusNode,
    );
  }

  void clickLinkText(url, type) async {
    Logger.print('--------link  type:$type-------url: $url---');
    if (type == PatternType.at) {
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    }
    // await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }
}
