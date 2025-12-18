import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tokens.g.dart';

@JsonSerializable()
@HiveType(typeId: 103)
class Tokens extends HiveObject {
  @HiveField(0)
  final String image;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final String price;

  @HiveField(4)
  final String number;

  @HiveField(5)
  final bool toadd;

  @HiveField(6)
  final String tokenAddress;

  Tokens({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.number,
    required this.toadd,
    required this.tokenAddress,
  });

  factory Tokens.empty() => Tokens(image: '', title: '', subtitle: '', price: '', number: '', toadd: false, tokenAddress: '');

  factory Tokens.fromJson(Map<String, dynamic> json) => _$TokensFromJson(json);

  Map<String, dynamic> toJson() => _$TokensToJson(this);
}
