// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 1;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      name: fields[0] as String,
      balance: fields[1] as String,
      address: fields[2] as String,
      network: fields[3] as String,
      privateKey: fields[4] as String,
      isExpanded: fields[5] as bool,
      isBackUp: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.balance)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.network)
      ..writeByte(4)
      ..write(obj.privateKey)
      ..writeByte(5)
      ..write(obj.isExpanded)
      ..writeByte(6)
      ..write(obj.isBackUp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
      name: json['name'] as String,
      balance: json['balance'] as String,
      address: json['address'] as String,
      network: json['network'] as String,
      privateKey: json['privateKey'] as String,
      isExpanded: json['isExpanded'] as bool? ?? false,
      isBackUp: json['isBackUp'] as bool? ?? false,
    );

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'name': instance.name,
      'balance': instance.balance,
      'address': instance.address,
      'network': instance.network,
      'privateKey': instance.privateKey,
      'isExpanded': instance.isExpanded,
      'isBackUp': instance.isBackUp,
    };
