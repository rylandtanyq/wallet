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
