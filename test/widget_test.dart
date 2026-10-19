
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ocr_expense_tracker/screens/home_screen.dart';
import 'package:ocr_expense_tracker/models/expense_transaction.dart';

void main() {
  testWidgets(
    'Kiểm tra giao diện trang chủ',
    (WidgetTester tester) async {
      // Giả lập SQLite chưa có giao dịch.
      Future<List<ExpenseTransaction>> fakeTransactions() async {
        return <ExpenseTransaction>[];
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              loadTransactions: fakeTransactions,
            ),
          ),
        ),
      );

      // Chờ FutureBuilder cập nhật dữ liệu.
      await tester.pump();
      await tester.pump();

      // Kiểm tra nội dung trang chủ.
      expect(
        find.text('Xin chào! 👋'),
        findsOneWidget,
      );

      expect(
        find.text('TỔNG CHI TIÊU THÁNG NÀY'),
        findsOneWidget,
      );

      expect(
        find.text('Tính năng nổi bật'),
        findsOneWidget,
      );

      expect(
        find.text('Quét hóa đơn AI'),
        findsOneWidget,
      );

      expect(
        find.text('Giao dịch gần đây'),
        findsOneWidget,
      );

      // Kiểm tra trạng thái chưa có giao dịch.
      expect(
        find.text('Chưa có giao dịch nào'),
        findsOneWidget,
      );

      // Kiểm tra tổng chi tiêu bằng 0.
      expect(
        find.text('0 đ'),
        findsOneWidget,
      );
    },
  );
}
