import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_card.dart';

// This screen gives the business owner a quick summary of inventory, sales, and profit.
// It includes simple analytics so the app feels like real business software.
class DashboardScreen extends StatelessWidget {
  final LocalDatabaseService database;
  final Function(int) goToPage;

  const DashboardScreen({super.key, required this.database, required this.goToPage});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    final lowStockProducts = database.products.where((p) => p.isLowStock).toList();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(database.currentUser?.businessName ?? 'StockWise Business', style: const TextStyle(color: AppColors.textMuted)),
          ]),
          ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark), onPressed: () => goToPage(1), icon: const Icon(Icons.add), label: const Text('Add Product')),
        ]),
        const SizedBox(height: 22),
        GridView.count(crossAxisCount: 5, crossAxisSpacing: 14, mainAxisSpacing: 14, shrinkWrap: true, childAspectRatio: 1.65, children: [
          DashboardCard(title: 'Total Products', value: '${database.products.length}', icon: Icons.inventory_2_rounded),
          DashboardCard(title: 'Categories', value: '${database.totalCategories}', icon: Icons.category_rounded),
          DashboardCard(title: 'Low Stock', value: '${database.lowStockCount}', icon: Icons.warning_rounded, iconColor: AppColors.warning),
          DashboardCard(title: 'Revenue', value: money.format(database.totalRevenue), icon: Icons.payments_rounded),
          DashboardCard(title: 'Profit', value: money.format(database.totalProfit), icon: Icons.trending_up_rounded),
        ]),
        const SizedBox(height: 22),
        Expanded(
          child: Row(children: [
            Expanded(flex: 2, child: _AnalyticsPanel(database: database, money: money)),
            const SizedBox(width: 18),
            Expanded(child: _LowStockPanel(lowStockProducts: lowStockProducts)),
          ]),
        ),
      ]),
    );
  }
}

// Displays small business analytics without using loud colours or complicated charts.
class _AnalyticsPanel extends StatelessWidget {
  final LocalDatabaseService database;
  final NumberFormat money;

  const _AnalyticsPanel({required this.database, required this.money});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <String, int>{};
    for (final product in database.products) {
      categoryTotals[product.category] = (categoryTotals[product.category] ?? 0) + product.quantity;
    }
    final maxStock = categoryTotals.values.isEmpty ? 1 : categoryTotals.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Analytics Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Revenue, profit, and category stock distribution.', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _MetricBox(title: 'Stock Cost Value', value: money.format(database.totalStockCostValue))),
          const SizedBox(width: 12),
          Expanded(child: _MetricBox(title: 'Potential Stock Sales', value: money.format(database.totalStockSellingValue))),
          const SizedBox(width: 12),
          Expanded(child: _MetricBox(title: 'Today Profit', value: money.format(database.todayProfitTotal))),
        ]),
        const SizedBox(height: 20),
        const Text('Stock by Category', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: categoryTotals.isEmpty
              ? const Center(child: Text('Analytics will appear after products are added.', style: TextStyle(color: AppColors.textMuted)))
              : ListView(
                  children: categoryTotals.entries.map((entry) {
                    final widthFactor = entry.value / maxStock;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Text(entry.key), const Spacer(), Text('${entry.value} item(s)', style: const TextStyle(color: AppColors.textMuted))]),
                        const SizedBox(height: 6),
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: widthFactor, minHeight: 10, backgroundColor: AppColors.bgDark, color: AppColors.accentGreen)),
                      ]),
                    );
                  }).toList(),
                ),
        ),
      ]),
    );
  }
}

// Small reusable metric box used inside the analytics panel.
class _MetricBox extends StatelessWidget {
  final String title;
  final String value;

  const _MetricBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.panelLight, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// Shows low stock items in a clean alert list.
class _LowStockPanel extends StatelessWidget {
  final List<Product> lowStockProducts;

  const _LowStockPanel({required this.lowStockProducts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.all(18), child: Text('Low Stock Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        Expanded(
          child: lowStockProducts.isEmpty
              ? const Center(child: Text('No low-stock alerts yet.', style: TextStyle(color: AppColors.textMuted)))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: lowStockProducts.map((p) => ListTile(
                        leading: const Icon(Icons.warning_rounded, color: AppColors.warning),
                        title: Text(p.title),
                        subtitle: Text('SKU: ${p.sku} • ${p.category}', style: const TextStyle(color: AppColors.textMuted)),
                        trailing: Text('${p.quantity} left', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                      )).toList(),
                ),
        ),
      ]),
    );
  }
}
