
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense_transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() =>
      TransactionsScreenState();
}

class TransactionsScreenState
    extends State<TransactionsScreen> {
  late Future<List<ExpenseTransaction>> transactionsFuture;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() {
    transactionsFuture =
        DatabaseHelper.instance.getTransactions();
  }

  void refreshTransactions() {
  if (!mounted) return;

  setState(() {
    loadTransactions();
  });
}

Future<void> confirmDeleteTransaction(int id) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text(
          'Giao dịch này sẽ bị xóa khỏi lịch sử. '
          'Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  if (!mounted || confirmed != true) return;

  await deleteTransaction(id);
}

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);

      if (!mounted) return;

      setState(() {
        loadTransactions();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa giao dịch'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa giao dịch: $e'),
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatMoney(double amount) {
    final digits = amount.toStringAsFixed(0);

    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
      ),
      body: FutureBuilder<List<ExpenseTransaction>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Không thể tải giao dịch: ${snapshot.error}',
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có giao dịch nào được lưu.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                loadTransactions();
              });

              await transactionsFuture;
            },
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.receipt_long),
                    ),
                    title: Text(transaction.merchant),
                    subtitle: Text(
                      '${transaction.category} • '
                      '${formatDate(transaction.date)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${formatMoney(transaction.amount)}đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
  tooltip: 'Xóa giao dịch',
  icon: const Icon(Icons.delete_outline),
  onPressed: () {
    final id = transaction.id;

    if (id != null) {
      confirmDeleteTransaction(id);
    }
  },
),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
