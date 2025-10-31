# untitled1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

**wallets_data  所有钱包**
HiveStorage().getList<Wallet>('wallets_data') ?? []; 

**selected_address 当前选中的地址**
HiveStorage().getValue('selected_address') ?? '';

**currentSelectWallet 当前选中的钱包**
HiveStorage().putObject('currentSelectWallet', wallet);

**currentNetwork  当前选择的网络**
HiveStorage().putValue<String>('currentNetwork', currentSelectNetwork);

final b = await HiveStorage().getBox(boxName: boxWallet);
final raw = b is Box ? (b as Box).get('obj_currentSelectWallet') : await (b as LazyBox).get('obj_currentSelectWallet');
debugPrint('👀 currentSelectWallet rawType = ${raw?.runtimeType}, box=${b.name}');
final c = await HiveStorage().getBox(boxName: boxWallet);
debugPrint('wallet box runtimeType = ${c.runtimeType}'); // 看到类似 Box or Box<dynamic> 即可


====== 可删除box用于调式==========
const oldTxBox = 'transactions_v2'; // 或者用你的 boxTxOld 常量
  try {
    final exists = await Hive.boxExists(oldTxBox);
    if (exists) {
      if (Hive.isBoxOpen(oldTxBox)) {
        await Hive.box(oldTxBox).close(); // 先关再删
      }
      await Hive.deleteBoxFromDisk(oldTxBox);
      debugPrint('🧹 deleted old box: $oldTxBox');
    }
  } catch (e) {
    debugPrint('⚠️ delete $oldTxBox failed: $e');
  }


dart run flutter_launcher_icons   生成app logo图标

dart run build_runner build       hive 生成适配器