import 'package:flutter/material.dart';
import '../core/utils/navigation.dart';
import 'add_transaction/add_transaction_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'statistics/statistics_screen.dart';
import 'transactions/transactions_screen.dart';

/// Kerangka navigasi: 4 tujuan bottom navigation + FAB tambah transaksi.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state tiap tab (scroll, filter, dll.)
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(onGoTo: _go),
          const TransactionsScreen(),
          const StatisticsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _index <= 1
          ? FloatingActionButton(
              tooltip: 'Tambah transaksi',
              onPressed: () => pushPage(context, const AddTransactionScreen()),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insight'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
