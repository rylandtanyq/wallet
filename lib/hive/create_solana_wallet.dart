import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_solana_wallet.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class CreateSolanaWallet {
  CreateSolanaWallet({
    required this.name,
    required this.balance,
    required this.address,
    required this.network,
    required this.privateKey,
    this.isExpanded = false,
    this.isBackUp = false,
  });

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String balance;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String network;

  @HiveField(4)
  final String privateKey;

  @HiveField(5)
  bool isExpanded;

  @HiveField(6)
  bool isBackUp;

  factory CreateSolanaWallet.empty() => CreateSolanaWallet(name: "", balance: "0", address: "", network: "", privateKey: "");

  factory CreateSolanaWallet.fromJson(Map<String, dynamic> json) => _$CreateSolanaWalletFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSolanaWalletToJson(this);
}
