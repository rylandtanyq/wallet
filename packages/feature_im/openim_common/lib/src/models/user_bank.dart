class UserBankList {
  int? total;
  List<UserBank>? banks;
  UserBankList({this.total, this.banks});
  UserBankList.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    banks = json['banks'] is List
        ? (json['banks'] as List).map((e) => UserBank.fromJson(e)).toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['total'] = this.total;
    data['banks'] = this.banks;
    return data;
  }
}

class UserBank {
  String? id;
  String? userID;
  String? bankName;
  String? bankUserName;
  String? bankCardNo;
  String? createTime;
  UserBank(
      {this.id,
      this.userID,
      this.bankName,
      this.bankUserName,
      this.bankCardNo,
      this.createTime});
  UserBank.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userID = json['userID'];
    bankName = json['bankName'];
    bankUserName = json['bankUserName'];
    bankCardNo = json['bankCardNo'];
    createTime = json['createTime'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['id'] = this.id;
    data['userID'] = this.userID;
    data['bankName'] = this.bankName;
    data['bankUserName'] = this.bankUserName;
    data['bankCardNo'] = this.bankCardNo;
    data['createTime'] = this.createTime;
    return data;
  }
}
