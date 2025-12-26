import 'package:get/get.dart';

import '../pages/organization/organization_binding.dart';
import '../pages/organization/organization_view.dart';
import '../pages/organization/search/search_binding.dart';
import '../pages/organization/search/search_view.dart';
import '../pages/select_organization/search/search_binding.dart';
import '../pages/select_organization/search/search_view.dart';
import '../pages/select_organization/select_organization_binding.dart';
import '../pages/select_organization/select_organization_view.dart';

part 'o_routes.dart';

class OPages {
  /// 左滑关闭页面用于android
  static _pageBuilder({
    required String name,
    required GetPageBuilder page,
    Bindings? binding,
    bool preventDuplicates = true,
  }) =>
      GetPage(
        name: name,
        page: page,
        binding: binding,
        transition: Transition.cupertino,
        popGesture: true,
        preventDuplicates: true,
      );

  static final pages = <GetPage>[
    _pageBuilder(
      name: ORoutes.organization,
      page: () => OrganizationPage(),
      binding: OrganizationBinding(),
    ),
    _pageBuilder(
      name: ORoutes.searchOrganization,
      page: () => SearchOrganizationPage(),
      binding: SearchOrganizationBinding(),
    ),
    _pageBuilder(
      name: ORoutes.selectContactsFromOrganization,
      page: () => SelectContactsFromOrganizationPage(),
      binding: SelectContactsFromOrganizationBinding(),
    ),
    _pageBuilder(
      name: ORoutes.selectContactsFromSearchOrganization,
      page: () => SelectContactsFromSearchOrganizationPage(),
      binding: SelectContactsFromSearchOrganizationBinding(),
    ),
  ];
}
