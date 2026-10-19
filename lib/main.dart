
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/camera_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final GlobalKey<TransactionsScreenState> transactionsKey =
      GlobalKey<TransactionsScreenState>();

  final GlobalKey<StatisticsScreenState> statisticsKey =
    GlobalKey<StatisticsScreenState>();

  final GlobalKey<HomeScreenState> homeKey =
    GlobalKey<HomeScreenState>();

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      HomeScreen(key: homeKey),
      TransactionsScreen(key: transactionsKey),
      StatisticsScreen(key: statisticsKey),
      const SettingsScreen(),
    ];
  }

  void selectTab(int index) {
  setState(() {
    selectedIndex = index;
  });

  if (index == 0) {
    homeKey.currentState?.refreshHome();
  }

  if (index == 1) {
    transactionsKey.currentState?.refreshTransactions();
  }

  if (index == 2) {
    statisticsKey.currentState?.refreshStatistics();
  }
}

  Future<void> openCamera() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      selectTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: openCamera,
        child: const Icon(Icons.document_scanner),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, 'Trang chủ', 0),
            _navItem(Icons.receipt_long, 'Giao dịch', 1),
            const SizedBox(width: 48),
            _navItem(Icons.pie_chart, 'Thống kê', 2),
            _navItem(Icons.settings, 'Cài đặt', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    int index,
  ) {
    final active = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => selectTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active
                  ? const Color(0xFF2563EB)
                  : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: active
                    ? const Color(0xFF2563EB)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
