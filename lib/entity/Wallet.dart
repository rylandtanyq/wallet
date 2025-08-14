import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Wallet.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Wallet extends HiveObject{
  @HiveField(0)
  final String name;  //钱包名称

  @HiveField(1)
  late final String balance;  //余额

  @HiveField(2)
  final String address;  //钱包地址

  @HiveField(3)
  final String network;  //钱包网络

  @HiveField(4)
  final String privateKey;  //钱包私钥

  @HiveField(5)
  bool isExpanded;    //是否展开

  @HiveField(6)
  bool isBackUp;    //是否备份

  Wallet({
    required this.name,
    required this.balance,
    required this.address,
    required this.network,
    required this.privateKey,
    this.isExpanded = false,
    this.isBackUp = false,
  });

  factory Wallet.empty() => Wallet(
    name: '未命名钱包',
    balance: '0',
    address: '0x0000000000000000000000000000000000000000',
    network: 'mainnet',
    privateKey: '',
    isExpanded: false,
    isBackUp: false,
  );

  factory Wallet.fromJson(Map<String, dynamic> json) =>
      _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);
}

// 注册 Hive 适配器
class WalletHiveAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 1;

  @override
  Wallet read(BinaryReader reader) {
    return Wallet(
      name: reader.read(),
      balance: reader.read(),
      address: reader.read(),
      network: reader.read(),
      privateKey: reader.read(),
      isExpanded: reader.read(),
      isBackUp: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer.write(obj.name);
    writer.write(obj.balance);
    writer.write(obj.address);
    writer.write(obj.network);
    writer.write(obj.privateKey);
    writer.write(obj.isExpanded);
    writer.write(obj.isBackUp);
  }
}