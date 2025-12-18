import 'package:openim_common/openim_common.dart';

class OUrls {
  ///  组织架构
  ///
  static final queryOrganizationInfo = "${Config.appAuthUrl}/organization/info";
  static final queryDepartment =
      "${Config.appAuthUrl}/organization/department/find";
  static final queryUserInDept =
      "${Config.appAuthUrl}/organization/user/department";
  static final getDeptMemberAndSubDept =
      "${Config.appAuthUrl}/organization/department/child";
  static final searchDeptMember =
      "${Config.appAuthUrl}/user/search/organization/full";
}
