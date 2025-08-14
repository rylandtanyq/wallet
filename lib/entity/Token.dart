class Token {
  final String name;
  final String? apy;
  final String price;
  final String change;

  Token({
    required this.name,
    this.apy,
    required this.price,
    required this.change,
  });
}