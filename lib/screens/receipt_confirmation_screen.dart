
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense_transaction.dart';
import '../models/receipt_data.dart';
import '../utils/transaction_validator.dart';

class ReceiptConfirmationScreen extends StatefulWidget {
  final ReceiptData receipt;

  const ReceiptConfirmationScreen({
    super.key,
    required this.receipt,
  });

  @override
  State<ReceiptConfirmationScreen> createState() =>
      _ReceiptConfirmationScreenState();
}

class _ReceiptConfirmationScreenState
    extends State<ReceiptConfirmationScreen> {
  late final TextEditingController merchantController;
  late final TextEditingController dateController;
  late final TextEditingController totalController;

  String selectedCategory = 'Khác';
  bool isSaving = false;

  final categories = const [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Hóa đơn',
    'Giải trí',
    'Sức khỏe',
    'Giáo dục',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();

    merchantController = TextEditingController(
      text: widget.receipt.merchant,
    );

    final date = widget.receipt.date;

    dateController = TextEditingController(
      text: date == null
          ? ''
          : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}',
    );

    totalController = TextEditingController(
      text: widget.receipt.total?.toStringAsFixed(0) ?? '',
    );
  }

  DateTime? parseDate(String input) {
    final match = RegExp(
      r'^(\d{2})/(\d{2})/(\d{4})$',
    ).firstMatch(input.trim());

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

  Future<void> saveTransaction() async {
    if (isSaving) return;

    final merchant = merchantController.text.trim();

final merchantError =
    TransactionValidator.validateMerchant(merchant);

final dateError =
    TransactionValidator.validateDate(dateController.text);

final amountError =
    TransactionValidator.validateAmount(totalController.text);

if (merchantError != null ||
    dateError != null ||
    amountError != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        merchantError ??
            dateError ??
            amountError ??
            'Dữ liệu không hợp lệ',
      ),
    ),
  );
  return;
}

final date = TransactionValidator.parseDate(
  dateController.text,
)!;

final amount = TransactionValidator.parseAmount(
  totalController.text,
)!;

    setState(() {
      isSaving = true;
    });

    try {
      final transaction = ExpenseTransaction(
        merchant: merchant,
        date: date,
        amount: amount,
        category: selectedCategory,
        rawText: widget.receipt.rawText,
      );

      await DatabaseHelper.instance.insertTransaction(
        transaction,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu giao dịch thành công!'),
        ),
      );

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu giao dịch thất bại: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    merchantController.dispose();
    dateController.dispose();
    totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận hóa đơn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Thông tin giao dịch',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: merchantController,
              decoration: const InputDecoration(
                labelText: 'Tên cửa hàng',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Ngày (dd/MM/yyyy)',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tổng tiền (VNĐ)',
                prefixIcon: Icon(Icons.payments),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục chi tiêu',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: isSaving ? null : saveTransaction,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                isSaving
                    ? 'Đang lưu...'
                    : 'Lưu giao dịch',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
