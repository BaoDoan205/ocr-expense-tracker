
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/expense_transaction.dart';

class HomeScreen extends StatefulWidget {
  final Future<List<ExpenseTransaction>> Function()? loadTransactions;

  const HomeScreen({
    super.key,
    this.loadTransactions,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<ExpenseTransaction>> transactionsFuture;

  final NumberFormat money = NumberFormat.decimalPattern('vi');

  @override
  void initState() {
    super.initState();
    refreshHome();
  }

  void refreshHome() {
    if (!mounted) return;

    setState(() {
      transactionsFuture = widget.loadTransactions?.call() ??
    DatabaseHelper.instance.getTransactions();
    });
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ăn uống':
        return Icons.restaurant;
      case 'học tập':
        return Icons.menu_book;
      case 'di chuyển':
        return Icons.directions_car;
      case 'mua sắm':
        return Icons.shopping_bag;
      case 'sức khỏe':
        return Icons.medical_services;
      case 'giải trí':
        return Icons.movie;
      case 'hóa đơn':
        return Icons.receipt_long;
      default:
        return Icons.payments;
    }
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ăn uống':
        return Colors.orange;
      case 'học tập':
        return Colors.blue;
      case 'di chuyển':
        return Colors.green;
      case 'mua sắm':
        return Colors.purple;
      case 'sức khỏe':
        return Colors.red;
      case 'giải trí':
        return Colors.pink;
      case 'hóa đơn':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<ExpenseTransaction>>(
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Không thể tải dữ liệu giao dịch',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: refreshHome,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          final now = DateTime.now();

          final monthlyTransactions = transactions.where((t) {
            return t.date.year == now.year &&
                t.date.month == now.month;
          }).toList();

          final monthlyTotal =
              monthlyTransactions.fold<double>(
            0,
            (sum, t) => sum + t.amount,
          );

          final recentTransactions = [...transactions]
            ..sort((a, b) => b.date.compareTo(a.date));

          final latest = recentTransactions.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              refreshHome();
              await transactionsFuture;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Xin chào! 👋',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Theo dõi chi tiêu của bạn mỗi ngày',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Tổng chi tiêu tháng hiện tại
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF60A5FA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(
                          alpha: 0.15,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TỔNG CHI TIÊU THÁNG NÀY',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${money.format(monthlyTotal)} đ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: Colors.white70,
                            size: 17,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${monthlyTransactions.length} giao dịch trong tháng',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Tính năng nổi bật',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFDBEAFE),
                        child: Icon(
                          Icons.document_scanner,
                          color: Color(0xFF2563EB),
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quét hóa đơn AI',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tự động nhận diện và lưu chi tiêu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Giao dịch gần đây',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${transactions.length} giao dịch',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (latest.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có giao dịch nào',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Nhấn nút quét hóa đơn để bắt đầu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...latest.map((transaction) {
                    final color = getCategoryColor(
                      transaction.category,
                    );

                    final icon = getCategoryIcon(
                      transaction.category,
                    );

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              color.withValues(alpha: 0.12),
                          child: Icon(
                            icon,
                            color: color,
                          ),
                        ),
                        title: Text(
                          transaction.merchant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${transaction.category} • '
                          '${DateFormat('dd/MM/yyyy').format(transaction.date)}',
                        ),
                        trailing: Text(
                          '-${money.format(transaction.amount)} đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
