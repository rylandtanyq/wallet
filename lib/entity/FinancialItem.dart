class FinancialItem {
  final String name;
  final String amount;
  final String time;
  final String price;
  final String change;
  final bool isPositive;

  FinancialItem({
    required this.name,
    required this.amount,
    required this.time,
    required this.price,
    required this.change,
    required this.isPositive,
  });
}