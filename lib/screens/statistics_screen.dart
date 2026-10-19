
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense_transaction.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/expense_bar_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() =>
      StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<ExpenseTransaction>> transactionsFuture;

  @override
  void initState() {
    super.initState();
    refreshStatistics();
  }

  void refreshStatistics() {
    if (!mounted) return;

    setState(() {
      transactionsFuture =
          DatabaseHelper.instance.getTransactions();
    });
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
        title: const Text('Thống kê chi tiêu'),
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
                'Không thể tải thống kê: ${snapshot.error}',
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text('Chưa có dữ liệu thống kê'),
            );
          }

          final total = transactions.fold<double>(
            0,
            (sum, transaction) =>
                sum + transaction.amount,
          );

          final categoryTotals = <String, double>{};

          for (final transaction in transactions) {
            categoryTotals.update(
              transaction.category,
              (value) => value + transaction.amount,
              ifAbsent: () => transaction.amount,
            );
          }

          final today = DateTime.now();
          final startDate = DateTime(
            today.year,
            today.month,
            today.day,
          ).subtract(const Duration(days: 6));

          final dailyTotals = List<double>.filled(7, 0);
          final dailyLabels = <String>[];

          for (int i = 0; i < 7; i++) {
            final date = startDate.add(
              Duration(days: i),
            );

            dailyLabels.add(
              '${date.day}/${date.month}',
            );
          }

          for (final transaction in transactions) {
            final date = DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            );

            final index = date.difference(startDate).inDays;

            if (index >= 0 && index < 7) {
              dailyTotals[index] += transaction.amount;
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              refreshStatistics();
              await transactionsFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Tổng chi tiêu',
                        '${formatMoney(total)}đ',
                        Icons.payments,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        'Số giao dịch',
                        '${transactions.length}',
                        Icons.receipt_long,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi tiêu theo danh mục',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ExpensePieChart(
                          data: categoryTotals,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi tiêu 7 ngày gần nhất',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ExpenseBarChart(
                          values: dailyTotals,
                          labels: dailyLabels,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
