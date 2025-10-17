import 'package:bs58/bs58.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
part 'Wallet.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Wallet extends HiveObject {
  @HiveField(0)
  final String name; //钱包名称

  @HiveField(1)
  late String balance; //余额

  @HiveField(2)
  final String address; //钱包地址

  @HiveField(3)
  String network; //钱包网络

  @HiveField(4)
  final String privateKey; //钱包私钥

  @HiveField(5)
  bool isExpanded; //是否展开

  @HiveField(6)
  bool isBackUp; //是否备份

  @HiveField(7)
  final List<String>? mnemonic;

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
  );

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

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
      mnemonic: (reader.read() as List<String>?)?.cast<String>(),
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
    writer.write(obj.mnemonic);
  }
}

extension SolanaSigner on Wallet {
  /// 使用钱包私钥对 message 签名，返回 Base58 签名
  Future<String> signMessage(String message) async {
    final algorithm = Ed25519();
    final messageBytes = utf8.encode(message);

    // 解析 32 字节 Hex 私钥
    final seed = Uint8List.fromList(hex.decode(privateKey));

    // 生成 KeyPair
    final keyPair = await algorithm.newKeyPairFromSeed(seed);

    // 签名
    final signature = await algorithm.sign(messageBytes, keyPair: keyPair);

    // ⚡️ 将 List<int> 转成 Uint8List
    final signatureBytes = Uint8List.fromList(signature.bytes);

    // 返回 Base58 编码签名
    return base58.encode(signatureBytes);
  }

  /// 获取对应公钥 Base58
  Future<String> getPublicKey() async {
    final algorithm = Ed25519();
    final seed = Uint8List.fromList(hex.decode(privateKey));
    final keyPair = await algorithm.newKeyPairFromSeed(seed);
    final simpleKeyPair = await keyPair.extract();

    final publicKeyBytes = Uint8List.fromList(simpleKeyPair.publicKey.bytes);
    return base58.encode(publicKeyBytes);
  }

  Future<String> signMessageBytes(List<int> messageBytes) async {
    final algorithm = Ed25519();
    final seed = Uint8List.fromList(hex.decode(privateKey));
    final keyPair = await algorithm.newKeyPairFromSeed(seed);

    final signature = await algorithm.sign(messageBytes, keyPair: keyPair);
    final signatureBytes = Uint8List.fromList(signature.bytes);

    return base58.encode(signatureBytes); // 或 base64.encode(signatureBytes) 根据 DApp 要求
  }
}
