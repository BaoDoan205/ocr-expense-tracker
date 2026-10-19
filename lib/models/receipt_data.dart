class ReceiptData {
  final String merchant;
  final DateTime? date;
  final double? total;
  final String rawText;

  const ReceiptData({
    required this.merchant,
    required this.date,
    required this.total,
    required this.rawText,
  });
}
