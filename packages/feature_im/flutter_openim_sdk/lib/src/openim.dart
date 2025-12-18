import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

class OpenIM {
  static const version = '3.8.3-patch.3-e-v1.1.11';

  static const _channel = MethodChannel('flutter_openim_sdk');

  static final iMManager = IMManager(_channel);

  OpenIM._();
}
