class UserInfoHongbaoRecord {
  String? amount;
  List<UserInfoHongbao>? records;
  UserInfoHongbaoRecord({
    this.amount,
    this.records,
  });
  UserInfoHongbaoRecord.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    records = json['records'] is List
        ? (json['records'] as List)
            .map((e) => UserInfoHongbao.fromJson(e))
            .toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['amount'] = this.amount;
    data['records'] = this.records;
    return data;
  }
}

class UserInfoHongbao {
  String? id;
  String? uuid;
  String? amount;
  String? fromID;
  String? fromNickname;
  String? createTime;
  String? userNickname;
  String? userFaceUrl;
  int? type;
  int? category;
  UserInfoHongbao(
      {this.id,
      this.uuid,
      this.amount,
      this.fromID,
      this.fromNickname,
      this.createTime,
      this.userNickname,
      this.userFaceUrl,
      this.type,
      this.category});
  UserInfoHongbao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    amount = json['amount'];
    fromID = json['fromID'];
    fromNickname = json['fromNickname'];
    createTime = json['createTime'];
    userNickname = json['userNickname'];
    userFaceUrl = json['userFaceUrl'] != null ? json['userFaceUrl'] : "";
    type = json['type'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['amount'] = this.amount;
    data['fromID'] = this.fromID;
    data['fromNickname'] = this.fromNickname;
    data['createTime'] = this.createTime;
    data['userNickname'] = this.userNickname;
    data['userFaceUrl'] = this.userFaceUrl;
    data['type'] = this.type;
    data['category'] = this.category;
    return data;
  }
}

class Hongbao {
  String? redID;
  String? uuid;
  int? type;
  int? category;
  String? totalAmount;
  int? totalCount;
  String? remainingAmount;
  int? remainingCount;
  String? userID;
  String? userNickname;
  String? userFaceURL;
  String? targetID;
  int? status;
  int? createTime;
  String? content;
  Hongbao(
      {this.redID,
      this.uuid,
      this.type,
      this.category,
      this.totalAmount,
      this.totalCount,
      this.remainingAmount,
      this.remainingCount,
      this.userID,
      this.userNickname,
      this.userFaceURL,
      this.targetID,
      this.status,
      this.createTime,
      this.content});
  Hongbao.fromJson(Map<String, dynamic> json) {
    redID = json['redID'];
    uuid = json['uuid'];
    type = json['type'];
    category = json['category'];
    totalAmount = json['totalAmount'];
    totalCount = json['totalCount'];
    remainingAmount = json['remainingAmount'];
    remainingCount =
        json['remainingCount'] != null ? json['remainingCount'] : 0;
    userID = json['userID'];
    userNickname = json['userNickname'];
    userFaceURL = json['userFaceURL'] != null ? json['userFaceURL'] : "";
    targetID = json['targetID'];
    status = json['status'];
    createTime = json['createTime'];
    content = json['content'] != null ? json['content'] : "";
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['redID'] = this.redID;
    data['uuid'] = this.uuid;
    data['type'] = this.type;
    data['category'] = this.category;
    data['totalAmount'] = this.totalAmount;
    data['totalCount'] = this.totalCount;
    data['remainingAmount'] = this.remainingAmount;
    data['remainingCount'] = this.remainingCount;
    data['userID'] = this.userID;
    data['userNickname'] = this.userNickname;
    data['userFaceURL'] = this.userFaceURL;
    data['targetID'] = this.targetID;
    data['status'] = this.status;
    data['createTime'] = this.createTime;
    data['content'] = this.content;
    return data;
  }
}
