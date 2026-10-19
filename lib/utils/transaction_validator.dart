
class TransactionValidator {
  static String? validateMerchant(String value) {
    final merchant = value.trim();

    if (merchant.isEmpty) {
      return 'Vui lòng nhập tên cửa hàng';
    }

    if (merchant.length > 150) {
      return 'Tên cửa hàng không được quá 150 ký tự';
    }

    return null;
  }

  static double? parseAmount(String value) {
    var input = value
        .trim()
        .replaceAll(RegExp(r'[^\d.,]'), '');

        if (value.trim().startsWith('-')) {
  return null;
}

    if (input.isEmpty) return null;

    // Hỗ trợ: 700000, 700.000, 700,000
    // và dạng có cả dấu phân tách hàng nghìn.
    if (RegExp(r'^\d{1,3}([.,]\d{3})+$')
        .hasMatch(input)) {
      input = input.replaceAll(RegExp(r'[.,]'), '');
    } else if (RegExp(r'^\d+$').hasMatch(input)) {
      // Số nguyên không có dấu phân tách.
    } else {
      return null;
    }

    final amount = double.tryParse(input);

    if (amount == null ||
        !amount.isFinite ||
        amount <= 0) {
      return null;
    }

    return amount;
  }

  static DateTime? parseDate(String value) {
    final match = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(value.trim());

    if (match == null) return null;

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    final date = DateTime(year, month, day);

    if (date.day != day ||
        date.month != month ||
        date.year != year) {
      return null;
    }

    return date;
  }

  static String? validateAmount(String value) {
    if (parseAmount(value) == null) {
      return 'Số tiền không hợp lệ';
    }

    return null;
  }

  static String? validateDate(String value) {
    if (parseDate(value) == null) {
      return 'Ngày phải có dạng dd/MM/yyyy';
    }

    return null;
  }
}
