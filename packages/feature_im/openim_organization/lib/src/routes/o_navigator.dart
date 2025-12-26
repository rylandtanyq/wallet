import 'package:get/get.dart';
import 'package:openim_organization/src/routes/o_pages.dart';
import 'package:openim_common/openim_common.dart';

class ONavigator {
  static Future<T?>? startEnterOrganization<T>({
    DeptInfo? deptInfo,
  }) =>
      Get.toNamed(ORoutes.organization, arguments: {
        'deptInfo': deptInfo,
      });

  static startSearchOrganization() => Get.toNamed(ORoutes.searchOrganization);

  static startSelectContactsFromOrganization() =>
      Get.toNamed(ORoutes.selectContactsFromOrganization);

  static startSelectContactsFromSearchOrganization() =>
      Get.toNamed(ORoutes.selectContactsFromSearchOrganization);
}
