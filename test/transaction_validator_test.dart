
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/utils/transaction_validator.dart';

void main() {
  group('TransactionValidator', () {
    test('Chấp nhận tên cửa hàng hợp lệ', () {
      expect(
        TransactionValidator.validateMerchant(
          'Siêu thị Mini',
        ),
        isNull,
      );
    });

    test('Từ chối tên cửa hàng rỗng', () {
      expect(
        TransactionValidator.validateMerchant('  '),
        isNotNull,
      );
    });

    test('Đọc số tiền 700.000', () {
      expect(
        TransactionValidator.parseAmount('700.000'),
        700000,
      );
    });

    test('Đọc số tiền 700,000', () {
      expect(
        TransactionValidator.parseAmount('700,000'),
        700000,
      );
    });

    test('Từ chối số tiền âm', () {
      expect(
        TransactionValidator.parseAmount('-100'),
        isNull,
      );
    });

    test('Từ chối số tiền bằng 0', () {
      expect(
        TransactionValidator.parseAmount('0'),
        isNull,
      );
    });

    test('Đọc ngày hợp lệ', () {
      final date = TransactionValidator.parseDate(
        '13/05/2022',
      );

      expect(date?.day, 13);
      expect(date?.month, 5);
      expect(date?.year, 2022);
    });

    test('Từ chối ngày không tồn tại', () {
      expect(
        TransactionValidator.parseDate('31/02/2026'),
        isNull,
      );
    });
  });
}
