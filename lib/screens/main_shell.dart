import 'package:flutter/material.dart';
import '../services/local_database_service.dart';
import '../widgets/sidebar.dart';
import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'suppliers_screen.dart';
import 'sales_screen.dart';
import 'reports_screen.dart';
import 'stock_movements_screen.dart';
import 'settings_screen.dart';

// This is the main layout after login.
// It keeps the sidebar on the left and changes the page on the right.
class MainShell extends StatefulWidget {
  final LocalDatabaseService database;

  const MainShell({super.key, required this.database});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(database: widget.database, goToPage: (i) => setState(() => selectedIndex = i)),
      ProductsScreen(database: widget.database),
      SuppliersScreen(database: widget.database),
      SalesScreen(database: widget.database),
      ReportsScreen(database: widget.database),
      StockMovementsScreen(database: widget.database),
      SettingsScreen(database: widget.database),
    ];

    return Scaffold(
      body: Row(
        children: [
          Sidebar(selectedIndex: selectedIndex, onSelected: (i) => setState(() => selectedIndex = i)),
          // This listener rebuilds the active page whenever products, sales, or reports change.
          // It fixes dashboard values not refreshing after a sale is saved.
          Expanded(
            child: AnimatedBuilder(
              animation: widget.database,
              builder: (context, _) => screens[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
