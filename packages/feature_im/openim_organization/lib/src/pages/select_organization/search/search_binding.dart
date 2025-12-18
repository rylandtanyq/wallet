import 'package:get/get.dart';

import 'search_logic.dart';

class SelectContactsFromSearchOrganizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectContactsFromSearchOrganizationLogic());
  }
}
