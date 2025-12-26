import 'dart:convert';

import 'package:azlistview_plus/azlistview_plus.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

class ISGroupInfo extends GroupInfo implements ISuspensionBean {
  String? tagIndex;
  String? pinyin;
  String? shortPinyin;
  String? namePinyin;

  // 方式1：声明时赋予默认值
  @override
  bool isShowSuspension = true; // 也可以设为 false，根据业务需求定

  ISGroupInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    tagIndex = json['tagIndex'];
    pinyin = json['pinyin'];
    shortPinyin = json['shortPinyin'];
    namePinyin = json['namePinyin'];
    // 可选：也可以从 json 中读取 isShowSuspension 的值
    // isShowSuspension = json['isShowSuspension'] ?? true;
  }

  @override
  Map<String, dynamic> toJson() {
    var map = super.toJson();
    map['tagIndex'] = tagIndex;
    map['pinyin'] = pinyin;
    map['shortPinyin'] = shortPinyin;
    map['namePinyin'] = namePinyin;
    map['isShowSuspension'] = isShowSuspension; // 序列化时带上该字段
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