import 'package:feature_main/main_page.dart';
import 'package:feature_wallet/add_wallet_page.dart';
import 'package:feature_wallet/hive/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:shared_utils/image_cache_repo.dart';
import 'package:feature_wallet/hive/tokens.dart';
import 'package:feature_wallet/hive/transaction_record.dart';
import 'package:shared_ui/theme/app_theme.dart';
import 'package:shared_utils/app_routes.dart';
import 'package:shared_setting/i18n/strings.g.dart' as core_i18n;
import 'package:feature_main/i18n/strings.g.dart' as main_i18n;
import 'package:feature_wallet/i18n/strings.g.dart' as wallet_i18n;
import 'package:feature_browser/i18n/strings.g.dart' as browser_i18n;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  core_i18n.LocaleSettings.useDeviceLocale();

  final hiveStorage = HiveStorage();
  await hiveStorage.init(adapters: [WalletAdapter(), TransactionRecordAdapter(), TokensAdapter()]);
  await HiveStorage().ensureOpen(boxWallet);
  await HiveStorage().ensureOpen(boxTokens);
  await HiveStorage().ensureOpen(boxTx, lazy: true);
  final wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet);
  final bool hasWallets = wallets != null && wallets.isNotEmpty;
  await ImageCacheRepo.I.init();

  runApp(
    ProviderScope(
      child: core_i18n.TranslationProvider(child: MyApp(hasWallets: hasWallets)),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool hasWallets;
  const MyApp({super.key, required this.hasWallets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    final coreLocale = core_i18n.LocaleSettings.currentLocale;
    final tag = coreLocale.languageTag;

    main_i18n.LocaleSettings.setLocaleRaw(tag);
    wallet_i18n.LocaleSettings.setLocaleRaw(tag);
    browser_i18n.LocaleSettings.setLocaleRaw(tag);

    return ScreenUtilInit(
      designSize: const Size(375, 667),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          locale: locale,
          supportedLocales: core_i18n.AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          builder: FToastBuilder(),
          debugShowCheckedModeBanner: false,
          title: 'Wallet App',
          home: hasWallets ? const MainPage() : const AddWalletPage(),
          initialRoute: '/',
          getPages: [
            GetPage(name: AppRoutes.main, page: () => const MainPage()),
            GetPage(name: AppRoutes.addWallet, page: () => const AddWalletPage()),
          ],
        );
      },
      child: const MainPage(),
    );
  }
}
