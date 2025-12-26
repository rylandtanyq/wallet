import 'package:get/get.dart';

import 'select_organization_logic.dart';

class SelectContactsFromOrganizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectContactsFromOrganizationLogic());
  }
}
