import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../live_client.dart';
import '../../utils/live_utils.dart';
import 'widgets/call_state.dart';
import 'widgets/participant_info.dart';

class GroupRoomView extends SignalView {
  const GroupRoomView({
    super.key,
    required super.callType,
    required super.initState,
    required super.callEventSubject,
    required super.autoPickup,
    super.roomID,
    required super.groupID,
    required super.inviterUserID,
    required super.inviteeUserIDList,
    super.inviteeUserIDListSubject,
    super.onClose,
    super.onBindRoomID,
    super.onDial,
    super.onJoin,
    super.onTapCancel,
    super.onTapHangup,
    super.onTapPickup,
    super.onTapReject,
    super.onError,
    super.onSyncGroupMemberInfo,
    super.onSyncGroupInfo,
    super.onCreateRoom,
    super.onAction,
    super.onWaitingAccept,
    super.onEnabledSpeaker,
  });

  @override
  State<GroupRoomView> createState() => _GroupRoomViewState();
}

class _GroupRoomViewState extends SignalState<GroupRoomView> {
  EventsListener<RoomEvent>? _listener;
  Room? _room;

  @override
  void initState() {
    super.initState();
    enabledSpeaker = true;
  }

  @override
  bool isHost() {
    return widget.inviterUserID == _room?.localParticipant?.identity;
  }

  @override
  void dispose() {
    // always dispose listener
    _room?.removeListener(_onRoomDidUpdate);
    Future.delayed(const Duration(seconds: 1), () async {
      await _listener?.dispose();
      Logger.print('listener dispose: listener is isDisposed: ${_listener?.isDisposed}', fileName: 'room.dart');
      if (_room != null && _room!.connectionState != ConnectionState.disconnected) {
        await _room?.disconnect();
      }
      Logger.print('room disconnect: room is disconnect: ${_room?.connectionState}', fileName: 'room.dart');
      await _room?.dispose();
      Logger.print('room dispose: room is isDisposed: ${_room?.isDisposed}', fileName: 'room.dart');
      _room = null;
      _listener = null;
    });
    super.dispose();
  }

  @override
  Future<void> connect() async {
    final url = certificate.liveURL!;
    final token = certificate.token!;
    final busyLineUsers = certificate.busyLineUserIDList ?? [];
    if (busyLineUsers.isNotEmpty) {
      IMViews.showToast(StrRes.busyVideoCallHint);
    }
    // Try to connect to a room
    // This will throw an Exception if it fails for any reason.
    try {
      // 播放等待提示音
      if (CallState.call == callState || CallState.connecting == callState) {
        widget.onWaitingAccept?.call();
      }
      //create new room
      _room = Room(
        roomOptions: const RoomOptions(
          dynacast: true,
          adaptiveStream: true,
          defaultCameraCaptureOptions: CameraCaptureOptions(params: VideoParametersPresets.h720_169),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
            videoCodec: 'VP8',
            videoEncoding: VideoEncoding(
              maxBitrate: 5 * 1000 * 1000,
              maxFramerate: 15,
            ),
          ),
        ),
      );

      OpenIM.iMManager.logs(
        file: 'group-room.dart',
        line: 81,
        msgs: 'OpenIM-Flutter: connect begin',
        keyAndValues: [url, token],
      );
      // Create a Listener before connecting
      _listener = _room?.createListener();

      await _room?.prepareConnection(
        url,
        token,
      );

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await _room?.connect(
        url,
        token,
      );
      if (!mounted) return;

      _room?.addListener(_onRoomDidUpdate);
      if (null != _listener) _setUpListeners();
      if (null != _room) {
        roomDidUpdateSubject.add(_room!);
        widget.onCreateRoom?.call(_room);
      }

      OpenIM.iMManager.logs(
        file: 'group-room.dart',
        line: 110,
        msgs: 'OpenIM-Flutter: connect success',
      );

      _publish(callState != CallState.call);

      callStateSubject.add(CallState.calling);
    } catch (error, stackTrace) {
      widget.onError?.call(error, stackTrace);
      Logger.print('Could not connect $error  $stackTrace');

      OpenIM.iMManager.logs(
        file: 'group-room.dart',
        line: 125,
        msgs: 'OpenIM-Flutter: connect error',
        err: 'error: ${error.toString()}, stackTrace: ${stackTrace.toString()}',
      );
      Get.dialog(CustomDialog(
        title: error.toString(),
      ));
    }
  }

  void _setUpListeners() => _listener!
    ..on<RoomDisconnectedEvent>((event) async {
      Logger.print(
        'RoomDisconnectedEvent',
        fileName: 'group-room.dart',
        keyAndValues: ['reason', event.reason.toString()],
      );
      if (event.reason == DisconnectReason.signalingConnectionFailure ||
          event.reason == DisconnectReason.reconnectAttemptsExceeded ||
          event.reason == DisconnectReason.roomDeleted ||
          event.reason == DisconnectReason.stateMismatch) {
        widget.onClose?.call();
      }
    })
    ..on<ParticipantConnectedEvent>((event) {
      Logger.print(
        'ParticipantConnectedEvent',
        fileName: 'group-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      // sender
      if (widget.initState == CallState.call &&
          enabledMicrophone &&
          _room?.localParticipant?.isMicrophoneEnabled() == false) {
        Logger.print('ParticipantConnectedEvent setMicrophoneEnabled true', fileName: 'single-room.dart');
        _room?.localParticipant?.setMicrophoneEnabled(true);
      }

      _sortParticipants();
      widget.onAction?.call(CallingOperationType.participantConnected, event.participant.identity);
    })
    ..on<ParticipantDisconnectedEvent>((event) {
      Logger.print(
        'ParticipantDisconnectedEvent',
        fileName: 'group-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _sortParticipants();
      widget.onAction?.call(CallingOperationType.participantDisconnected, event.participant.identity);
    })
    ..on<LocalTrackPublishedEvent>((event) {
      Logger.print(
        'LocalTrackPublishedEvent',
        fileName: 'group-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<LocalTrackUnpublishedEvent>((event) {
      Logger.print(
        'LocalTrackUnpublishedEvent',
        fileName: 'group-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<TrackSubscribedEvent>((event) {
      Logger.print(
        'TrackSubscribedEvent',
        fileName: 'group-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<TrackUnsubscribedEvent>((event) {
      Logger.print(
        'TrackUnsubscribedEvent',
        fileName: 'group-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<RoomAttemptReconnectEvent>((event) {
      Logger.print(
        'RoomAttemptReconnectEvent',
        fileName: 'group-room.dart',
        keyAndValues: [event.attempt, event.maxAttemptsRetry],
      );
    })
    ..on<RoomReconnectedEvent>((event) {
      Logger.print(
        'RoomReconnectedEvent',
        fileName: 'group-room.dart',
      );
    });

  void _publish([bool publishMic = true]) async {
    // video will fail when running in ios simulator
    await IMUtils.requestBackgroundPermission(title: StrRes.audioAndVideoCall, text: StrRes.audioAndVideoCall);

    try {
      await _room?.localParticipant?.setCameraEnabled(isVideoCall);
      Logger.print('publish video success', fileName: 'group-room.dart');
    } catch (error, stackTrace) {
      Logger.print('could not publish video: ${stackTrace.toString()} ${stackTrace.toString()}',
          fileName: 'group-room.dart');
    }

    try {
      await _room?.localParticipant?.setMicrophoneEnabled(publishMic ? enabledMicrophone : false);
      Logger.print('setMicrophoneEnabled enable[${publishMic ? enabledMicrophone : false}] success',
          fileName: 'single-room.dart');
    } catch (error, stackTrace) {
      Logger.print('could not publish audio: ${error.toString()} ${stackTrace.toString()}',
          fileName: 'single-room.dart');
    }

    try {
      await _room?.setSpeakerOn(enabledSpeaker);
      Logger.print('setSpeakerOn[$enabledSpeaker] success', fileName: 'single-room.dart');
    } catch (error, stackTrace) {
      Logger.print('could not set speaker on [$enabledSpeaker]: ${error.toString()} ${stackTrace.toString()}',
          fileName: 'single-room.dart');
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
    if (null != _room && _room!.connectionState != lk.ConnectionState.disconnected) roomDidUpdateSubject.add(_room!);
  }

  void _sortParticipants() {
    if (null == _room || !mounted) return;
    List<ParticipantTrack> userMediaTracks = [];

    final localParticipant = _room!.localParticipant;
    if (null != localParticipant) {
      VideoTrack? videoTrack;
      for (var t in localParticipant.videoTrackPublications) {
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      userMediaTracks.add(ParticipantTrack(
        participant: localParticipant,
        videoTrack: videoTrack,
        isScreenShare: false,
      ));
    }

    for (var participant in _room!.remoteParticipants.values) {
      // 排除观察者
      if (roomID == participant.identity) {
        continue;
      }
      VideoTrack? videoTrack;
      for (var t in participant.videoTrackPublications) {
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      userMediaTracks.add(ParticipantTrack(
        participant: participant,
        videoTrack: videoTrack,
        isScreenShare: false,
      ));
    }

    setState(() {
      participantTracks = [...userMediaTracks];
    });
  }
}
