import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';

import '../../live_client.dart';
import 'widgets/call_state.dart';
import 'widgets/participant.dart';

class SingleRoomView extends SignalView {
  const SingleRoomView({
    super.key,
    required super.callType,
    required super.initState,
    required super.userID,
    required super.callEventSubject,
    required super.autoPickup,
    super.roomID,
    super.onClose,
    super.onBindRoomID,
    super.onBusyLine,
    super.onDial,
    super.onStartCalling,
    super.onTapCancel,
    super.onTapHangup,
    super.onTapPickup,
    super.onTapReject,
    super.onWaitingAccept,
    super.onSyncUserInfo,
    super.onError,
    super.onCreateRoom,
    super.onAction,
    super.onEnabledSpeaker,
  });

  @override
  SignalState<SingleRoomView> createState() => _SingleRoomViewState();
}

class _SingleRoomViewState extends SignalState<SingleRoomView> {
  EventsListener<RoomEvent>? _listener;
  Room? _room;
  bool _poorNetwork = false;

  @override
  void dispose() {
    // always dispose listener
    _poorNetwork = false;
    _room?.removeListener(_onRoomDidUpdate);
    Future.delayed(const Duration(seconds: 0), () async {
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

    // Future.delayed(const Duration(seconds: 0), () async {
    //   await _room?.disconnect();
    //   Logger.print('room disconnect: room is disconnect: ${_room?.connectionState.name}', fileName: 'room.dart');
    //   await _room?.dispose();
    //   Logger.print('room dispose: room is isDisposed: ${_room?.isDisposed}', fileName: 'room.dart');
    //   await _listener?.dispose();
    //   Logger.print('listener dispose: listener is isDisposed: ${_listener?.isDisposed}', fileName: 'room.dart');
    //   _room = null;
    //   _listener = null;
    // });

    super.dispose();
  }

  @override
  Future<void> connect() async {
    final url = certificate.liveURL!;
    final token = certificate.token!;
    final busyLineUsers = certificate.busyLineUserIDList ?? [];
    if (busyLineUsers.isNotEmpty) {
      widget.onBusyLine?.call();
      widget.onClose?.call();
      return;
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

      // Create a Listener before connecting
      _listener = _room?.createListener();

      await _room?.prepareConnection(
        url,
        token,
      );
      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      Logger.print(
        'connect begin',
        fileName: 'single-room.dart',
        keyAndValues: [url, token],
      );

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

      Logger.print(
        'connect success',
        fileName: 'single-room.dart',
      );

      await _publish(widget.initState != CallState.call);
    } catch (error, stackTrace) {
      if (_room?.connectionState == ConnectionState.connected) {
        return;
      }
      Logger.print(
        'connect error',
        fileName: 'single-room.dart',
        errorMsg: 'error: ${error.toString()}, stackTrace: ${stackTrace.toString()}',
      );
      widget.onError?.call(error, stackTrace);
    }
  }

  void _setUpListeners() => _listener!
    ..on<RoomDisconnectedEvent>((event) async {
      Logger.print(
        'RoomDisconnectedEvent',
        fileName: 'single-room.dart',
        keyAndValues: ['reason', event.reason.toString()],
      );

      if (event.reason == DisconnectReason.signalingConnectionFailure ||
          event.reason == DisconnectReason.reconnectAttemptsExceeded ||
          event.reason == DisconnectReason.roomDeleted ||
          event.reason == DisconnectReason.participantRemoved ||
          event.reason == DisconnectReason.stateMismatch) {
        widget.onClose?.call();
      }
    })
    ..on<ParticipantConnectedEvent>((event) {
      Logger.print(
        'ParticipantConnectedEvent',
        fileName: 'single-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      // sender
      if (widget.initState == CallState.call &&
          enabledMicrophone &&
          _room?.localParticipant?.isMicrophoneEnabled() == false) {
        Logger.print('ParticipantConnectedEvent setMicrophoneEnabled true', fileName: 'single-room.dart');
        _room?.localParticipant?.setMicrophoneEnabled(true);
      }
      onParticipantConnected();
    })
    ..on<ParticipantDisconnectedEvent>((event) {
      Logger.print(
        'ParticipantDisconnectedEvent',
        fileName: 'single-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      if (_poorNetwork) {
        OverlayWidget().showToast(
            context: context,
            text: StrRes.callingInterruption,
            onDelayDismiss: () {
              onParticipantDisconnected();
            });
      } else {
        onParticipantDisconnected();
      }
    })
    ..on<LocalTrackPublishedEvent>((event) {
      Logger.print(
        'LocalTrackPublishedEvent',
        fileName: 'single-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<LocalTrackUnpublishedEvent>((event) {
      Logger.print(
        'LocalTrackUnpublishedEvent',
        fileName: 'single-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<TrackSubscribedEvent>((event) {
      Logger.print(
        'TrackSubscribedEvent',
        fileName: 'single-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      // sender
      if (widget.initState == CallState.call &&
          enabledMicrophone &&
          _room?.localParticipant?.isMicrophoneEnabled() == false) {
        Logger.print('TrackSubscribedEvent setMicrophoneEnabled true', fileName: 'single-room.dart');
        _room?.localParticipant?.setMicrophoneEnabled(true);
      }

      _sortParticipants();
    })
    ..on<TrackUnsubscribedEvent>((event) {
      Logger.print(
        'TrackUnsubscribedEvent',
        fileName: 'single-room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );

      _sortParticipants();
    })
    ..on<ParticipantConnectionQualityUpdatedEvent>((event) {
      Logger.print(
        'ParticipantConnectionQualityUpdatedEvent',
        fileName: 'single-room.dart',
        keyAndValues: [event.toString()],
      );

      if (event.connectionQuality == ConnectionQuality.lost || event.connectionQuality == ConnectionQuality.poor) {
        final isMine = event.participant.identity == _room?.localParticipant?.identity;
        _poorNetwork = true;

        OverlayWidget().showToast(
          context: context,
          text: isMine ? StrRes.networkNotStable : StrRes.otherNetworkNotStableHint,
        );
      } else {
        _poorNetwork = false;
      }
    })
    ..on<RoomAttemptReconnectEvent>((event) {
      Logger.print(
        'RoomAttemptReconnectEvent',
        fileName: 'single-room.dart',
        keyAndValues: [event.attempt, event.maxAttemptsRetry],
      );

      if (event.attempt == 3) {
        OverlayWidget().showToast(
          context: context,
          text: StrRes.callingInterruption,
        );
      }
    })
    ..on<RoomReconnectedEvent>((event) {
      Logger.print(
        'RoomReconnectedEvent',
        fileName: 'single-room.dart',
      );
    })
    ..on<ActiveSpeakersChangedEvent>((event) {
      Logger.print(
        'ActiveSpeakersChangedEvent: ${event.toString()}',
        fileName: 'single-room.dart',
      );
    })
    ..on<TrackMutedEvent>((event) {
      Logger.print(
        'TrackMutedEvent: ${event.participant.metadata} ${event.publication.kind}',
        fileName: 'single-room.dart',
      );
    })
    ..on<TrackUnmutedEvent>((event) {
      Logger.print(
        'TrackUnmutedEvent: ${event.participant.metadata} ${event.publication.kind}',
        fileName: 'single-room.dart',
      );
    });

  Future _publish([bool publishMic = true]) async {
    // video will fail when running in ios simulator
    await IMUtils.requestBackgroundPermission(title: StrRes.audioAndVideoCall, text: StrRes.audioAndVideoCall);

    try {
      final enabled = widget.callType == CallType.video;
      await _room?.localParticipant?.setCameraEnabled(enabled);
      Logger.print('publish video success', fileName: 'single-room.dart');
    } catch (error, stackTrace) {
      Logger.print('could not publish video: ${error.toString()} ${stackTrace.toString()}',
          fileName: 'single-room.dart');
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
    if (null != _room) roomDidUpdateSubject.add(_room!);
  }

  void _sortParticipants() {
    if (null == _room || !mounted) return;

    final localParticipant = _room!.localParticipant;
    if (null != localParticipant) {
      VideoTrack? videoTrack;
      for (var t in localParticipant.videoTrackPublications) {
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      localParticipantTrack = ParticipantTrack(
        participant: localParticipant,
        videoTrack: videoTrack,
        isScreenShare: false,
      );
    }

    final participant = _room!.remoteParticipants.values.firstOrNull;
    if (null != participant) {
      VideoTrack? videoTrack;
      for (var t in participant.videoTrackPublications) {
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      remoteParticipantTrack = ParticipantTrack(
        participant: participant,
        videoTrack: videoTrack,
        isScreenShare: false,
      );
    }

    if (null != remoteParticipantTrack) {
      onParticipantConnected();
    }
    setState(() {});
  }

  @override
  bool existParticipants() {
    return _room?.remoteParticipants.isNotEmpty == true;
  }
}
