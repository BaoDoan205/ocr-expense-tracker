
import '../models/receipt_data.dart';

class ReceiptParser {
  static ReceiptData parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return ReceiptData(
      merchant: _extractMerchant(lines),
      date: _extractDate(lines),
      total: _extractTotal(lines),
      rawText: rawText,
    );
  }

  static String _extractMerchant(List<String> lines) {
    final merchantPattern = RegExp(
      r'(cửa hàng|siêu thị|shop|mart|store|nhà hàng|quán)',
      caseSensitive: false,
    );

    for (final line in lines) {
      if (merchantPattern.hasMatch(line)) {
        return line;
      }
    }

    return 'Chưa xác định';
  }

  static DateTime? _extractDate(List<String> lines) {
    final datePattern = RegExp(
      r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b'
      r'|\b(\d{1,2})/(\d{1,2})/(\d{4})\b',
    );

    // Ưu tiên ngày giao dịch thay vì ngày in.
    final ordered = [
      ...lines.where((line) =>
          line.toLowerCase().contains('ngày:')),
      ...lines.where((line) =>
          !line.toLowerCase().contains('ngày:')),
    ];

    for (final line in ordered) {
      final match = datePattern.firstMatch(line);
      if (match == null) continue;

      int year;
      int month;
      int day;

      if (match.group(1) != null) {
        year = int.parse(match.group(1)!);
        month = int.parse(match.group(2)!);
        day = int.parse(match.group(3)!);
      } else {
        day = int.parse(match.group(4)!);
        month = int.parse(match.group(5)!);
        year = int.parse(match.group(6)!);
      }

      final date = DateTime(year, month, day);

      if (date.year == year &&
          date.month == month &&
          date.day == day) {
        return date;
      }
    }

    return null;
  }

  static double? _extractTotal(List<String> lines) {
    final amountPattern = RegExp(
      r'\d{1,3}(?:[.,]\d{3})+|\d{4,}',
    );

    final totalKeywords = RegExp(
      r'(tổng tiền|thanh toán|thành tiền|total|phải trả)',
      caseSensitive: false,
    );

    double? parseAmount(String line) {
      final matches = amountPattern.allMatches(line);

      for (final match in matches) {
        final value = match.group(0)!
            .replaceAll('.', '')
            .replaceAll(',', '');

        final amount = double.tryParse(value);

        if (amount != null && amount > 0) {
          return amount;
        }
      }

      return null;
    }

    // Ưu tiên số tiền nằm cạnh nhãn tổng tiền.
    for (var i = 0; i < lines.length; i++) {
      if (!totalKeywords.hasMatch(lines[i])) continue;

      final sameLine = parseAmount(lines[i]);
      if (sameLine != null) return sameLine;

      if (i + 1 < lines.length) {
        final nextLine = parseAmount(lines[i + 1]);
        if (nextLine != null) return nextLine;
      }
    }

    // Dự phòng: tìm số tiền lớn nhất trong dòng
    // chỉ chứa giá trị tiền, không lấy số trong ngày.
    final candidates = <double>[];

    for (final line in lines) {
      if (!RegExp(r'^\s*[\d.,]+\s*(đ|₫|vnd)?\s*$',
              caseSensitive: false)
          .hasMatch(line)) {
        continue;
      }

      final amount = parseAmount(line);
      if (amount != null) candidates.add(amount);
    }

    if (candidates.isEmpty) return null;

    candidates.sort();
    return candidates.last;
  }
}
