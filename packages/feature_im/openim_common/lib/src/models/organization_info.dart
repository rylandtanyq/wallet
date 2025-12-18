import 'dart:convert';

import 'package:openim_common/src/models/user_full_info.dart';

/// 组织信息
class OrganizationInfo {
  /// 部门id
  String? departmentID;

  /// 头像
  String? logoURL;

  /// 显示名
  String? name;

  /// 上一级部门id
  String? parentID;

  /// 排序方式
  int? order;

  /// 部门类型
  int? departmentType;

  /// 创建时间
  int? createTime;

  /// 子部门数量
  int? subDepartmentNum;

  /// 成员数量
  int? memberNum;

  /// 扩展字段
  String? ex;

  /// 附加信息
  String? attachedInfo;

  String? relatedGroupID;

  OrganizationInfo(
      {this.departmentID,
      this.logoURL,
      this.name,
      this.parentID,
      this.order,
      this.departmentType,
      this.createTime,
      this.subDepartmentNum,
      this.memberNum,
      this.ex,
      this.attachedInfo,
      this.relatedGroupID});

  OrganizationInfo.fromJson(Map<String, dynamic> json) {
    departmentID = json['departmentID'];
    logoURL = json['logoURL'];
    name = json['name'];
    parentID = json['parentID'];
    order = json['order'];
    departmentType = json['departmentType'];
    createTime = json['createTime'];
    subDepartmentNum = json['subDepartmentNum'];
    memberNum = json['memberNum'];
    ex = json['ex'];
    attachedInfo = json['attachedInfo'];
    relatedGroupID = json['relatedGroupID'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['departmentID'] = this.departmentID;
    data['logoURL'] = this.logoURL;
    data['name'] = this.name;
    data['parentID'] = this.parentID;
    data['order'] = this.order;
    data['departmentType'] = this.departmentType;
    data['createTime'] = this.createTime;
    data['subDepartmentNum'] = this.subDepartmentNum;
    data['memberNum'] = this.memberNum;
    data['ex'] = this.ex;
    data['attachedInfo'] = this.attachedInfo;
    data['relatedGroupID'] = this.relatedGroupID;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeptInfo &&
          runtimeType == other.runtimeType &&
          departmentID == other.departmentID;

  @override
  int get hashCode => departmentID.hashCode;
}

/// 部门信息
class DeptInfo {
  /// 部门id
  String? departmentID;

  /// 头像
  String? faceURL;

  /// 显示名
  String? name;

  /// 上一级部门id
  String? parentID;

  /// 排序方式
  int? order;

  /// 部门类型
  int? departmentType;

  /// 创建时间
  int? createTime;

  /// 子部门数量
  int? subDepartmentNum;

  /// 成员数量
  int? memberNum;

  /// 扩展字段
  String? ex;

  /// 附加信息
  String? attachedInfo;

  String? relatedGroupID;

  DeptInfo(
      {this.departmentID,
      this.faceURL,
      this.name,
      this.parentID,
      this.order,
      this.departmentType,
      this.createTime,
      this.subDepartmentNum,
      this.memberNum,
      this.ex,
      this.attachedInfo,
      this.relatedGroupID});

  DeptInfo.fromJson(Map<String, dynamic> json) {
    departmentID = json['departmentID'];
    faceURL = json['faceURL'];
    name = json['name'];
    parentID = json['parentID'];
    order = json['order'];
    departmentType = json['departmentType'];
    createTime = json['createTime'];
    subDepartmentNum = json['subDepartmentNum'];
    memberNum = json['memberNum'];
    ex = json['ex'];
    attachedInfo = json['attachedInfo'];
    relatedGroupID = json['relatedGroupID'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['departmentID'] = this.departmentID;
    data['faceURL'] = this.faceURL;
    data['name'] = this.name;
    data['parentID'] = this.parentID;
    data['order'] = this.order;
    data['departmentType'] = this.departmentType;
    data['createTime'] = this.createTime;
    data['subDepartmentNum'] = this.subDepartmentNum;
    data['memberNum'] = this.memberNum;
    data['ex'] = this.ex;
    data['attachedInfo'] = this.attachedInfo;
    data['relatedGroupID'] = this.relatedGroupID;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeptInfo &&
          runtimeType == other.runtimeType &&
          departmentID == other.departmentID;

  @override
  int get hashCode => departmentID.hashCode;
}

/// 部门成员信息
class DeptMemberInfo {
  /// 用户id
  String? userID;

  /// 用户昵称
  String? nickname;

  /// 英文名
  String? englishName;

  /// 头像
  String? faceURL;

  /// 性别
  int? gender;

  /// 手机号
  String? mobile;

  /// 座机
  String? telephone;

  /// 出生时间
  int? birth;

  /// 邮箱
  String? email;

  /// 所在部门的id
  String? departmentID;

  /// 排序方式
  int? order;

  /// 职位
  String? position;

  /// 是否是领导
  int? leader;

  /// 状态
  int? status;

  /// 创建时间
  int? createTime;

  /// 入职时间
  int? entryTime;

  /// 离职时间
  int? terminationTime;

  /// 扩展字段
  String? ex;

  /// 附加信息
  String? attachedInfo;

  /// 搜索时使用
  String? departmentName;

  /// 所在部门的所有上级部门
  List<DeptInfo>? parentDepartmentList;

  /// 当前部门信息
  DeptInfo? department;

  DeptMemberInfo({
    this.userID,
    this.nickname,
    this.englishName,
    this.faceURL,
    this.gender,
    this.mobile,
    this.telephone,
    this.birth,
    this.email,
    this.departmentID,
    this.order,
    this.position,
    this.leader,
    this.status,
    this.createTime,
    this.ex,
    this.attachedInfo,
    this.departmentName,
    this.parentDepartmentList,
    this.department,
  });

  DeptMemberInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    nickname = json['nickname'];
    englishName = json['englishName'];
    faceURL = json['faceURL'];
    gender = json['gender'];
    mobile = json['mobile'];
    telephone = json['telephone'];
    birth = json['birth'];
    email = json['email'];
    departmentID = json['departmentID'];
    order = json['order'];
    position = json['position'];
    leader = json['leader'];
    status = json['status'];
    createTime = json['createTime'];
    ex = json['ex'];
    attachedInfo = json['attachedInfo'];
    departmentName = json['departmentName'];
    if (json['parentDepartmentList'] != null) {
      parentDepartmentList = <DeptInfo>[];
      json['parentDepartmentList'].forEach((v) {
        parentDepartmentList!.add(DeptInfo.fromJson(v));
      });
    }
    department = json['department'] == null
        ? null
        : DeptInfo.fromJson(json['department']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['nickname'] = this.nickname;
    data['englishName'] = this.englishName;
    data['faceURL'] = this.faceURL;
    data['gender'] = this.gender;
    data['mobile'] = this.mobile;
    data['telephone'] = this.telephone;
    data['birth'] = this.birth;
    data['email'] = this.email;
    data['departmentID'] = this.departmentID;
    data['order'] = this.order;
    data['position'] = this.position;
    data['leader'] = this.leader;
    data['status'] = this.status;
    data['createTime'] = this.createTime;
    data['ex'] = this.ex;
    data['attachedInfo'] = this.attachedInfo;
    data['departmentName'] = this.departmentName;
    if (this.parentDepartmentList != null) {
      data['parentDepartmentList'] =
          this.parentDepartmentList!.map((v) => v.toJson()).toList();
    }
    data['department'] = this.department?.toJson();
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeptMemberInfo &&
          runtimeType == other.runtimeType &&
          userID == other.userID;

  @override
  int get hashCode => userID.hashCode;
}

class UsersInDepts {
  final List<UserElement> users;

  UsersInDepts({
    required this.users,
  });

  factory UsersInDepts.fromJson(String str) =>
      UsersInDepts.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UsersInDepts.fromMap(Map<String, dynamic> json) => UsersInDepts(
        users: List<UserElement>.from(
            json["users"].map((x) => UserElement.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "users": List<dynamic>.from(users.map((x) => x.toMap())),
      };
}

class UserElement {
  final UserUser user;
  final List<DeptMemberInfo> members;

  UserElement({
    required this.user,
    required this.members,
  });

  factory UserElement.fromJson(String str) =>
      UserElement.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserElement.fromMap(Map<String, dynamic> json) => UserElement(
        user: UserUser.fromMap(json["user"]),
        members: List<DeptMemberInfo>.from(
            json["members"].map((x) => DeptMemberInfo.fromJson(x))),
      );

  Map<String, dynamic> toMap() => {
        "user": user.toJson(),
        "members": List<dynamic>.from(members.map((x) => x.toJson())),
      };
}

class UserUser {
  final String userId;
  final String? password;
  final String? account;
  final String? phoneNumber;
  final String? areaCode;
  final String? email;
  final String nickname;
  final String? faceUrl;
  final int? gender;
  final int? level;
  final int? birth;
  final int? allowAddFriend;
  final int? allowBeep;
  final int? allowVibration;
  final String? englishName;
  final String? station;
  final String? telephone;

  UserUser({
    required this.userId,
    this.password,
    this.account,
    this.phoneNumber,
    this.areaCode,
    this.email,
    required this.nickname,
    this.faceUrl,
    this.gender,
    this.level,
    this.birth,
    this.allowAddFriend,
    this.allowBeep,
    this.allowVibration,
    this.englishName,
    this.station,
    this.telephone,
  });

  factory UserUser.fromJson(String str) => UserUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserUser.fromMap(Map<String, dynamic> json) => UserUser(
        userId: json["userID"],
        password: json["password"],
        account: json["account"],
        phoneNumber: json["phoneNumber"],
        areaCode: json["areaCode"],
        email: json["email"],
        nickname: json["nickname"] ?? '',
        faceUrl: json["faceURL"],
        gender: json["gender"],
        level: json["level"],
        birth: json["birth"],
        allowAddFriend: json["allowAddFriend"],
        allowBeep: json["allowBeep"],
        allowVibration: json["allowVibration"],
        englishName: json["englishName"],
        station: json["station"],
        telephone: json["telephone"],
      );

  Map<String, dynamic> toMap() => {
        "userID": userId,
        "password": password,
        "account": account,
        "phoneNumber": phoneNumber,
        "areaCode": areaCode,
        "email": email,
        "nickname": nickname,
        "faceURL": faceUrl,
        "gender": gender,
        "level": level,
        "birth": birth,
        "allowAddFriend": allowAddFriend,
        "allowBeep": allowBeep,
        "allowVibration": allowVibration,
        "englishName": englishName,
        "station": station,
        "telephone": telephone,
      };
}

class DeptMemberAndSubDept {
  final List<DeptInfo> departments;
  final List<MemberUser> members;
  final List<DeptInfo> parents;
  final DeptInfo? current;

  DeptMemberAndSubDept({
    required this.departments,
    required this.members,
    required this.parents,
    required this.current,
  });

  factory DeptMemberAndSubDept.fromJson(String str) =>
      DeptMemberAndSubDept.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DeptMemberAndSubDept.fromMap(Map<String, dynamic> json) =>
      DeptMemberAndSubDept(
        departments: json["departments"] == null
            ? []
            : List<DeptInfo>.from(
                json["departments"].map((x) => DeptInfo.fromJson(x))),
        members: json['members'] == null
            ? []
            : List<MemberUser>.from(
                json["members"].map((x) => MemberUser.fromMap(x))),
        parents: json['parents'] == null
            ? []
            : List<DeptInfo>.from(
                json["parents"].map((x) => DeptInfo.fromJson(x))),
        current:
            json['current'] == null ? null : DeptInfo.fromJson(json["current"]),
      );

  Map<String, dynamic> toMap() => {
        "departments": List<dynamic>.from(departments.map((x) => x.toJson())),
        "members": List<dynamic>.from(members.map((x) => x.toJson())),
        "parents": List<dynamic>.from(parents.map((x) => x.toJson())),
        "current": current!.toJson(),
      };
}

class MemberUser {
  final DeptMemberInfo member;
  final UserUser user;

  MemberUser({
    required this.member,
    required this.user,
  });

  factory MemberUser.fromJson(String str) =>
      MemberUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MemberUser.fromMap(Map<String, dynamic> json) => MemberUser(
        member: DeptMemberInfo.fromJson(json["member"]),
        user: UserUser.fromMap(json["user"]),
      );

  Map<String, dynamic> toMap() => {
        "member": member.toJson(),
        "user": user.toMap(),
      };
}

/// 搜索结果

class OrganizationSearchResult2 {
  final int total;
  final List<OrganizationSearchResultItem>? users;

  OrganizationSearchResult2({
    required this.total,
    required this.users,
  });

  factory OrganizationSearchResult2.fromJson(String str) =>
      OrganizationSearchResult2.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrganizationSearchResult2.fromMap(Map<String, dynamic> json) =>
      OrganizationSearchResult2(
        total: json["total"],
        users: json["users"] == null
            ? null
            : List<OrganizationSearchResultItem>.from(json["users"]
                .map((x) => OrganizationSearchResultItem.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "total": total,
        "users": users == null
            ? null
            : List<dynamic>.from(users!.map((x) => x.toMap())),
      };
}

class OrganizationSearchResultItem {
  final String userId;
  final String? password;
  final String? account;
  final String? phoneNumber;
  final String? areaCode;
  final String? email;
  final String nickname;
  final String? faceUrl;
  final int? gender;
  final int? level;
  final int? birth;
  final int? allowAddFriend;
  final int? allowBeep;
  final int? allowVibration;
  final String? englishName;
  final String? station;
  final String? mobile;
  final String? telephone;
  final List<DeptMemberInfo>? members;

  OrganizationSearchResultItem({
    required this.userId,
    this.password,
    this.account,
    this.phoneNumber,
    this.areaCode,
    this.email,
    required this.nickname,
    this.faceUrl,
    this.gender,
    this.level,
    this.birth,
    this.allowAddFriend,
    this.allowBeep,
    this.allowVibration,
    this.englishName,
    this.station,
    this.mobile,
    this.telephone,
    this.members,
  });

  factory OrganizationSearchResultItem.fromJson(String str) =>
      OrganizationSearchResultItem.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrganizationSearchResultItem.fromMap(Map<String, dynamic> json) =>
      OrganizationSearchResultItem(
        userId: json["userID"],
        password: json["password"],
        account: json["account"],
        phoneNumber: json["phoneNumber"],
        areaCode: json["areaCode"],
        email: json["email"],
        nickname: json["nickname"],
        faceUrl: json["faceURL"],
        gender: json["gender"],
        level: json["level"],
        birth: json["birth"],
        allowAddFriend: json["allowAddFriend"],
        allowBeep: json["allowBeep"],
        allowVibration: json["allowVibration"],
        englishName: json["englishName"],
        station: json["station"],
        mobile: json["mobile"],
        telephone: json["telephone"],
        members: json["members"] == null
            ? null
            : List<DeptMemberInfo>.from(
                json["members"].map((x) => DeptMemberInfo.fromJson(x))),
      );

  Map<String, dynamic> toMap() => {
        "userID": userId,
        "password": password,
        "account": account,
        "phoneNumber": phoneNumber,
        "areaCode": areaCode,
        "email": email,
        "nickname": nickname,
        "faceURL": faceUrl,
        "gender": gender,
        "level": level,
        "birth": birth,
        "allowAddFriend": allowAddFriend,
        "allowBeep": allowBeep,
        "allowVibration": allowVibration,
        "englishName": englishName,
        "station": station,
        "mobile": mobile,
        "telephone": telephone,
        "members": members == null
            ? null
            : List<dynamic>.from(members!.map((x) => x.toJson())),
      };
}

/// 搜索结果
class OrganizationSearchResult {
  /// 部门列表
  List<DeptInfo>? departments;

  /// 部门成员列表
  List<MemberUser>? members;

  OrganizationSearchResult({
    this.departments,
    this.members,
  });

  OrganizationSearchResult.fromJson(Map<String, dynamic> json) {
    if (json['departments'] != null) {
      departments = <DeptInfo>[];
      json['departments'].forEach((v) {
        departments!.add(DeptInfo.fromJson(v));
      });
    }
    if (json['members'] != null) {
      members = <MemberUser>[];
      json['members'].forEach((v) {
        members!.add(MemberUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    if (this.departments != null) {
      data['departments'] = this.departments!.map((v) => v.toJson()).toList();
    }
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
