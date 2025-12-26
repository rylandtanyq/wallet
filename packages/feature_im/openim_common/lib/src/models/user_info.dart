import 'dart:convert';

import 'package:azlistview_plus/azlistview_plus.dart';
import 'package:openim_common/openim_common.dart';

class ISUserInfo extends UserFullInfo implements ISuspensionBean {
  String? tagIndex;
  String? pinyin;
  String? shortPinyin;
  String? namePinyin;
// 方式1：声明时赋予默认值
  @override
  bool isShowSuspension = true; // 也可以设为 false，根据业务需求定
  ISUserInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    tagIndex = json['tagIndex'];
    pinyin = json['pinyin'];
    shortPinyin = json['shortPinyin'];
    namePinyin = json['namePinyin'];
  }

  @override
  Map<String, dynamic> toJson() {
    var map = super.toJson();
    map['tagIndex'] = tagIndex;
    map['pinyin'] = pinyin;
    map['shortPinyin'] = shortPinyin;
    map['namePinyin'] = namePinyin;
    return map;
  }

  @override
  String getSuspensionTag() {
    return tagIndex!;
  }

  @override
  String toString() {
    return json.encode(this);
  }
}
