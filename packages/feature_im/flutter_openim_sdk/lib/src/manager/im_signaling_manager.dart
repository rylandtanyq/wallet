import 'package:flutter/services.dart';

import '../../flutter_openim_sdk.dart';

class SignalingManager {
  MethodChannel _channel;
  late OnSignalingListener listener;

  SignalingManager(this._channel);

  /// 信令监听
  Future setSignalingListener(OnSignalingListener listener) {
    this.listener = listener;
    return _channel.invokeMethod('setSignalingListener', _buildParam({}));
  }

  /// 邀请个人加入音视频
  /// [info] 信令对象[SignalingInfo]
  Future<SignalingCertificate> signalingInvite({
    required SignalingInfo info,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'signalingInvite',
              _buildParam({
                'signalingInfo': info.toJson(),
                'operationID': Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toObj(value, (map) => SignalingCertificate.fromJson(map)));

  /// 邀请群里某些人加入音视频
  /// [info] 信令对象[SignalingInfo]
  Future<SignalingCertificate> signalingInviteInGroup({
    required SignalingInfo info,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'signalingInviteInGroup',
              _buildParam({
                'signalingInfo': info.toJson(),
                'operationID': Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toObj(value, (map) => SignalingCertificate.fromJson(map)));

  /// 同意某人音视频邀请
  /// [info] 信令对象[SignalingInfo]
  Future<SignalingCertificate> signalingAccept({
    required SignalingInfo info,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'signalingAccept',
              _buildParam({
                'signalingInfo': info.toJson(),
                'operationID': Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toObj(value, (map) => SignalingCertificate.fromJson(map)));

  /// 拒绝某人音视频邀请
  /// [info] 信令对象[SignalingInfo]
  Future<dynamic> signalingReject({
    required SignalingInfo info,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'signalingReject',
          _buildParam({
            'signalingInfo': info.toJson(),
            'operationID': Utils.checkOperationID(operationID),
          }));

  /// 邀请者取消音视频通话
  /// [info] 信令对象[SignalingInfo]
  Future<dynamic> signalingCancel({
    required SignalingInfo info,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'signalingCancel',
          _buildParam({
            'signalingInfo': info.toJson(),
            'operationID': Utils.checkOperationID(operationID),
          }));

  /// 挂断
  /// [info] 信令对象[SignalingInfo]
  Future<dynamic> signalingHungUp({
    required SignalingInfo info,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'signalingHungUp',
          _buildParam({
            'signalingInfo': info.toJson(),
            'operationID': Utils.checkOperationID(operationID),
          }));

  /// 获取当前群通话信息
  /// [groupID] 当前群ID
  Future<RoomCallingInfo> signalingGetRoomByGroupID({
    required String groupID,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'signalingGetRoomByGroupID',
              _buildParam({
                'groupID': groupID,
                'operationID': Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toObj(value, (map) => RoomCallingInfo.fromJson(map)));

  /// 获取进入房间的信息
  /// [roomID] 当前房间ID
  Future<SignalingCertificate> signalingGetTokenByRoomID({
    required String roomID,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'signalingGetTokenByRoomID',
              _buildParam({
                'roomID': roomID,
                'operationID': Utils.checkOperationID(operationID),
              }))
          .then((value) => Utils.toObj(value, (map) => SignalingCertificate.fromJson(map..addAll({'roomID': roomID}))));

  /// 自定义信令
  /// [roomID] 会议ID
  /// [customInfo] 自定义信令
  Future<dynamic> signalingSendCustomSignal({
    required String roomID,
    required String customInfo,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'signalingSendCustomSignal',
          _buildParam({
            'roomID': roomID,
            'customInfo': customInfo,
            'operationID': Utils.checkOperationID(operationID),
          }));

  Future<SignalingInfo?> getSignalingInvitationInfoStartAppSafe({
    String? operationID,
  }) async {
    try {
      final value = await _channel.invokeMethod(
        'getSignalingInvitationInfoStartApp',
        _buildParam({'operationID': Utils.checkOperationID(operationID)}),
      );

      if (value == null) return null;
      return Utils.toObj(value, (map) => SignalingInfo.fromJson(map));
    } on PlatformException catch (e) {
      // 这两个就是你现在遇到的网络/超时类错误：直接当“没邀请信息”
      if (e.code == '10005' || e.code == '10000') {
        // Logger.print('[Signaling] getInvitation timeout/network: ${e.message}', onlyConsole: true);
        return null;
      }
      rethrow; // 其它错误继续抛（方便定位真正 bug）
    } catch (e) {
      // Logger.print('[Signaling] getInvitation unexpected: $e', onlyConsole: true);
      return null;
    }
  }

  static Map _buildParam(Map<String, dynamic> param) {
    param["ManagerName"] = "signalingManager";
    param = Utils.cleanMap(param);

    return param;
  }
}
