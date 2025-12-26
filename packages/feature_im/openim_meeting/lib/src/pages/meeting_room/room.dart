import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/src/widgets/page_content.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:sprintf/sprintf.dart';

import '../../method_channels/replay_kit_channel.dart';
import '../../repository/forPB/meeting.pb.dart' hide MeetingMetadata;
import '../../repository/meeting.pb.dart' hide NotifyMeetingData, KickOffReason;
import '../../repository/pb_extension.dart';
import '../../widgets/meeting_alert_dialog.dart';
import '../../widgets/meeting_state.dart';
import '../../widgets/participant.dart';
import '../../widgets/participant_info.dart';

class MeetingRoom extends MeetingView {
  const MeetingRoom(
    super.room,
    super.listener, {
    super.key,
    required super.roomID,
    super.onClose,
    super.infoSetting,
  });

  @override
  MeetingViewState<MeetingRoom> createState() => _MeetingRoomState();
}

class _MeetingRoomState extends MeetingViewState<MeetingRoom> {
  //
  List<ParticipantTrack> participantTracks = [];

  EventsListener<RoomEvent> get _listener => widget.listener;

  bool get fastConnection => widget.room.engine.fastConnectOptions != null;
  bool _flagStartedReplayKit = false;
  ParticipantTrack? get _localParticipantTrack => ParticipantTrack(participant: widget.room.localParticipant!);

  ScrollPhysics? scrollPhysics;
  final PageController _pageController = PageController(initialPage: 1);
  int _pages = 0;

  @override
  void initState() {
    super.initState();
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();
    _sortParticipants();
    _parseRoomMetadata();
    WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      startTimerCompleter.complete(true);
    });

    if (lkPlatformIs(PlatformType.iOS)) {
      ReplayKitChannel.listenMethodChannel(widget.room);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // always dispose listener
    (() async {
      if (lkPlatformIs(PlatformType.iOS)) {
        ReplayKitChannel.closeReplayKit();
      }
      widget.room.removeListener(_onRoomDidUpdate);
      await _listener.dispose();
      if (widget.room.connectionState != ConnectionState.disconnected) {
        await widget.room.disconnect();
      }
      await widget.room.dispose();
      Logger.print(
          'room disconnect: room is disconnect: ${widget.room.connectionState}, room is isDisposed: ${widget.room.isDisposed}',
          fileName: 'room.dart');
    })();
    super.dispose();
  }

  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'metting_room.dart',
        line: 78,
        msgs: 'OpenIM-Flutter: RoomDisconnectedEvent',
        keyAndValues: ['reason', event.reason.toString()],
      );
      _meetingClosed();
    })
    ..on<RoomRecordingStatusChanged>((event) {})
    ..on<LocalTrackPublishedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 89,
        msgs: 'OpenIM-Flutter: LocalTrackPublishedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _sortParticipants();
    })
    ..on<LocalTrackUnpublishedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 98,
        msgs: 'OpenIM-Flutter: LocalTrackUnpublishedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _sortParticipants();
    })
    ..on<ParticipantConnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 107,
        msgs: 'OpenIM-Flutter: ParticipantConnectedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _sortParticipants();
    })
    ..on<ParticipantDisconnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 116,
        msgs: 'OpenIM-Flutter: ParticipantDisconnectedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _sortParticipants();
    })
    ..on<TrackSubscribedEvent>((event) {
      Logger.print(
        'TrackSubscribedEvent',
        fileName: 'meeting_room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<TrackUnsubscribedEvent>((event) {
      Logger.print(
        'TrackUnsubscribedEvent',
        fileName: 'meeting_room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<TrackUnmutedEvent>((event) {
      Logger.print('TrackUnmutedEvent: ${event.participant.metadata} ${event.publication.kind}');
    })
    ..on<TrackMutedEvent>((event) {
      Logger.print('TrackMutedEvent: ${event.participant.metadata} ${event.publication.kind}');
    })
    ..on<RoomMetadataChangedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 125,
        msgs: 'OpenIM-Flutter: RoomMetadataChangedEvent',
        keyAndValues: ['metadata', event.metadata ?? 'unkonwn room metadata'],
      );
      _parseRoomMetadata();
    })
    ..on<DataReceivedEvent>((event) => _parseDataReceived(event))
    ..on<RoomAttemptReconnectEvent>((event) {
      OpenIM.iMManager.logs(
          file: 'meeting_room.dart',
          line: 137,
          msgs: 'OpenIM-Flutter: RoomAttemptReconnectEvent',
          keyAndValues: [event.attempt, event.maxAttemptsRetry]);
    })
    ..on<RoomReconnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 144,
        msgs: 'OpenIM-Flutter: RoomReconnectedEvent',
      );
    });

  void _parseDataReceived(DataReceivedEvent event) {
    final result = NotifyMeetingData.fromBuffer(event.data);
    Logger.print(
      '_parseDataReceived',
      fileName: 'meeting_room.dart',
      keyAndValues: [jsonEncode(result.toProto3Json())],
    );
    // kickofff
    if (result.hasKickOffMeetingData() &&
        result.kickOffMeetingData.userID.isNotEmpty &&
        result.kickOffMeetingData.reasonCode == KickOffReason.DuplicatedLogin) {
      widget.room.disconnect();
      widget.onClose?.call();
      return;
    }

    if (!result.hasStreamOperateData()) return;

    final streamOperateData = result.streamOperateData;

    if (streamOperateData.operation.isEmpty || result.operatorUserID == widget.room.localParticipant?.identity) {
      return;
    }

    final operateUser = streamOperateData.operation.firstWhereOrNull((element) {
      return element.userID == widget.room.localParticipant?.identity;
    });

    if (operateUser == null) return;

    if (operateUser.hasCameraOnEntry()) {
      final cameraOnEntry = operateUser.cameraOnEntry;

      if (cameraOnEntry.value) {
        MeetingAlertDialog.show(context, sprintf(StrRes.requestXDoHint, [StrRes.meetingEnableVideo]),
            confirmText: StrRes.confirm, cancelText: StrRes.keepClose, onConfirm: () {
          widget.room.localParticipant?.setCameraEnabled(cameraOnEntry.value);
        });
      } else {
        widget.room.localParticipant?.setCameraEnabled(cameraOnEntry.value);
      }
    }

    if (operateUser.hasMicrophoneOnEntry()) {
      final microphoneOnEntry = operateUser.microphoneOnEntry;

      if (microphoneOnEntry.value) {
        MeetingAlertDialog.show(context, sprintf(StrRes.requestXDoHint, [StrRes.meetingUnmute]),
            confirmText: StrRes.confirm, cancelText: StrRes.keepClose, onConfirm: () {
          widget.room.localParticipant?.setMicrophoneEnabled(microphoneOnEntry.value);
        });
      } else {
        widget.room.localParticipant?.setMicrophoneEnabled(microphoneOnEntry.value);
      }
    }
  }

  void _parseRoomMetadata() {
    if (widget.room.metadata != null && widget.room.metadata!.isNotEmpty) {
      Logger.print('room parseRoomMetadata: ${widget.room.metadata}');
      meetingInfo = (MeetingMetadata()..mergeFromProto3Json(jsonDecode(widget.room.metadata!))).detail;
      watchedUserID ??= meetingInfo?.creatorUserID;
      meetingInfoChangedSubject.add(meetingInfo!);
      setState(() {});
    }
  }

  @override
  customWatchedUser(String userID) {
    watchedUserID = null;
    if (wasClickedUserID == userID) return;
    final track = participantTracks.firstWhereOrNull((e) => e.participant.identity == userID);
    wasClickedUserID = track?.participant.identity;
    if (null != wasClickedUserID) _sortParticipants();
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _sortParticipants() {
    List<ParticipantTrack> userMediaTracks = [];
    List<ParticipantTrack> screenTracks = [];
    for (var participant in widget.room.remoteParticipants.values) {
      if (participant.videoTrackPublications.isNotEmpty) {
        final screenShareTrack = participant.videoTrackPublications.firstWhereOrNull((e) => e.isScreenShare);

        if (screenShareTrack != null) {
          screenTracks.add(ParticipantTrack(
            participant: participant,
            type: ParticipantTrackType.kScreenShare,
            isHost: hostUserID == participant.identity,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: participant,
            isHost: hostUserID == participant.identity,
          ));
        }
      } else {
        userMediaTracks.add(ParticipantTrack(
          participant: participant,
          isHost: hostUserID == participant.identity,
        ));
      }
    }

    // sort speakers for the grid
    userMediaTracks.sort((a, b) {
      /*
      // loudest speaker first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // last spoken at
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }
      */

      // video on
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // joinedAt
      return a.participant.joinedAt.millisecondsSinceEpoch - b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks = widget.room.localParticipant?.videoTrackPublications;
    final screenShareTrack = localParticipantTracks?.firstWhereOrNull((e) => e.isScreenShare);

    if (screenShareTrack != null) {
      if (lkPlatformIs(PlatformType.iOS)) {
        if (!_flagStartedReplayKit) {
          _flagStartedReplayKit = true;

          ReplayKitChannel.startReplayKit();
        }
      }

      screenTracks.add(ParticipantTrack(
        participant: widget.room.localParticipant!,
        type: ParticipantTrackType.kScreenShare,
        isHost: hostUserID == widget.room.localParticipant?.identity,
      ));
    } else {
      if (lkPlatformIs(PlatformType.iOS)) {
        if (_flagStartedReplayKit) {
          _flagStartedReplayKit = false;

          ReplayKitChannel.closeReplayKit();
        }
      }

      userMediaTracks.add(ParticipantTrack(
        participant: widget.room.localParticipant!,
        isHost: hostUserID == widget.room.localParticipant?.identity,
      ));
    }

    setState(() {
      participantTracks = [...screenTracks, ...userMediaTracks];
      participantsSubject.add(participantTracks);
    });
  }

  ParticipantTrack? get _firstParticipantTrack {
    ParticipantTrack? track;
    if (null != watchedUserID) {
      track = participantTracks.firstWhereOrNull((e) => e.participant.identity == watchedUserID);
    } else if (null != wasClickedUserID) {
      track = participantTracks.firstWhereOrNull((e) => e.participant.identity == wasClickedUserID);
    } else {
      track = participantTracks.firstWhereOrNull((e) => e.participant.videoTrackPublications.isNotEmpty);
    }
    final videoTracks = track?.participant.videoTrackPublications;
    final screenTrack = videoTracks?.firstWhereOrNull((e) => e.isScreenShare);
    final videoTrack = videoTracks?.firstWhereOrNull((e) => !e.isScreenShare);

    Logger.print('first watch track : ${track == null} '
        'videoTrack:${screenTrack != null} '
        'screenShareTrack:${videoTrack != null} '
        'screen track muted:${screenTrack?.muted} '
        'video track muted:${videoTrack?.muted} '
        'audio track muted:${track?.participant.isMuted == true} ');
    return track;
  }

  _onPageChange(int pages) {
    setState(() {
      _pages = pages;
    });
  }

  _fixPages(int count) {
    _pages = min(_pages, count - 1);
    return count;
  }

  int get pageCount => _fixPages(
      (participantTracks.length % 4 == 0 ? participantTracks.length ~/ 4 : participantTracks.length ~/ 4 + 1) +
          (null == _firstParticipantTrack ? 0 : 1));

  @override
  Widget buildChild() => Stack(
        children: [
          widget.room.remoteParticipants.isEmpty
              ? (_localParticipantTrack == null
                  ? const SizedBox()
                  : GestureDetector(
                      onDoubleTap: toggleFullScreen,
                      child: ParticipantWidget.widgetFor(
                        _localParticipantTrack!,
                        // isZoom: false,
                        // useScreenShareTrack: true,
                        onTapSwitchCamera: () {
                          _localParticipantTrack!.toggleCamera();
                        },
                      )))
              : PageView.builder(
                  physics: scrollPhysics,
                  itemBuilder: (context, index) {
                    final existVideoTrack = null != _firstParticipantTrack;
                    if (existVideoTrack && index == 0) {
                      return GestureDetector(
                        child: FirstPage(
                          participantTrack: _firstParticipantTrack!,
                        ),
                        onDoubleTap: () {
                          toggleFullScreen();
                        },
                      );
                    }
                    return OtherPage(
                      participantTracks: participantTracks,
                      pages: existVideoTrack ? index - 1 : index,
                      onDoubleTap: (t) {
                        setState(() {
                          customWatchedUser(t.participant.identity);
                          _pageController.jumpToPage(0);
                        });
                      },
                    );
                  },
                  itemCount: pageCount,
                  onPageChanged: _onPageChange,
                  controller: _pageController,
                ),
          if (widget.room.remoteParticipants.isNotEmpty && pageCount > 1)
            Positioned(
              bottom: 8.h,
              child: PageViewDotIndicator(
                currentItem: _pages,
                count: pageCount,
                size: Size(8.w, 8.h),
                unselectedColor: Styles.c_FFFFFF_opacity50,
                selectedColor: Styles.c_FFFFFF,
              ),
            ),
          Positioned(
            right: 16.w,
            bottom: 16.h,
            child: ImageRes.meetingRotateScreen.toImage
              ..width = 44.w
              ..height = 44.h
              ..onTap = rotateScreen,
          )
        ],
      );

  void _meetingClosed() {
    if (humanOperation) {
      return;
    }
    OverlayWidget().showDialog(
      context: context,
      child: CustomDialog(
        onTapLeft: OverlayWidget().dismiss,
        onTapRight: () {
          OverlayWidget().dismiss();
          widget.onClose?.call();
        },
        title: StrRes.meetingClosedHint,
      ),
    );
  }
}

class FirstPageZoomNotification extends Notification {
  bool isZoom;

  FirstPageZoomNotification({this.isZoom = false});
}
