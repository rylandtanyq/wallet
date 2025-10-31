import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Wallet.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Wallet extends HiveObject {
  @HiveField(0)
  late String name; // 钱包名称

  @HiveField(1)
  late String balance; // 余额

  @HiveField(2)
  final String address; // 钱包地址

  @HiveField(3)
  String network; // 钱包网络

  @HiveField(4)
  final String privateKey; // 钱包私钥

  @HiveField(5)
  bool isExpanded; // 是否展开

  @HiveField(6)
  bool isBackUp; // 是否备份

  @HiveField(7)
  final List<String>? mnemonic; // 助记词

  Wallet({
    required this.name,
    required this.balance,
    required this.address,
    required this.network,
    required this.privateKey,
    this.isExpanded = false,
    this.isBackUp = false,
    this.mnemonic,
  });

  factory Wallet.empty() => Wallet(
    name: '未命名钱包',
    balance: '0',
    address: '0x0000000000000000000000000000000000000000',
    network: 'mainnet',
    privateKey: '',
    isExpanded: false,
    isBackUp: false,
    mnemonic: <String>[],
  );

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);
}
