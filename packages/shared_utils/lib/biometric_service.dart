import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  BiometricService._();

  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// 是否可以使用生物识别, 硬件/系统是否支持
  Future<bool> canUseBiometrics() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// 查设备是否有人脸 / 指纹, 用于文本展示
  Future<({bool hasFace, bool hasFingerprint})> getBiometricTypes() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      final hasFace = types.contains(BiometricType.face) || types.contains(BiometricType.strong); // 某些平台用 strong
      final hasFingerprint = types.contains(BiometricType.fingerprint);
      return (hasFace: hasFace, hasFingerprint: hasFingerprint);
    } on PlatformException {
      return (hasFace: false, hasFingerprint: false);
    }
  }

  /// 执行一次生物识别, faceID / 指纹
  Future<bool> authenticate({String reason = '请使用指纹 / 人脸验证身份'}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // 只用生物识别，允许 PIN
          stickyAuth: true, // 切后台回来保持
        ),
      );
      return ok;
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }
}
