import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 2}) : assert(decimalRange >= 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // 可以删光
    if (text.isEmpty) {
      return newValue;
    }

    // 只允许数字和 .
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    // 只允许一个小数点
    final dotCount = '.'.allMatches(text).length;
    if (dotCount > 1) {
      return oldValue;
    }

    // 限制小数位数
    if (text.contains('.')) {
      final parts = text.split('.');
      final fraction = parts.length > 1 ? parts[1] : '';
      if (fraction.length > decimalRange) {
        return oldValue;
      }
    }

    return newValue;
  }
}
