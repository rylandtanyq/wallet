import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_record.g.dart';

@JsonSerializable()
@HiveType(typeId: 102)
class TransactionRecord extends HiveObject {
  @HiveField(0)
  final String txHash;

  @HiveField(1)
  final String from;

  @HiveField(2)
  final String to;

  @HiveField(3)
  final String amount;

  @HiveField(4)
  final String tokenSymbol;

  @HiveField(5)
  final int timestamp;

  @HiveField(6)
  final String status; // "success" / "failed" / "pending"

  TransactionRecord({
    required this.txHash,
    required this.from,
    required this.to,
    required this.amount,
    required this.tokenSymbol,
    required this.timestamp,
    this.status = 'success',
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => _$TransactionRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionRecordToJson(this);
}
