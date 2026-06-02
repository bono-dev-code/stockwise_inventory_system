import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';

// This screen gives business reports from saved local data.
// Reports show that the system does more than basic CRUD by analysing stock, revenue, and profit.
class ReportsScreen extends StatelessWidget {
  final LocalDatabaseService database;

  const ReportsScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    final bestSeller = _bestSellingProduct();
    final neverSoldCount = database.products.where((product) => !database.sales.any((sale) => sale.productId == product.id)).length;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _reportTile('Stock Cost Value', money.format(database.totalStockCostValue), Icons.inventory_rounded),
          _reportTile('Potential Sales Value', money.format(database.totalStockSellingValue), Icons.storefront_rounded),
          _reportTile('Total Revenue', money.format(database.totalRevenue), Icons.payments_rounded),
          _reportTile('Total Profit', money.format(database.totalProfit), Icons.trending_up_rounded),
          _reportTile('Low Stock Products', '${database.lowStockCount}', Icons.warning_rounded),
          _reportTile('Best Seller', bestSeller, Icons.star_rounded),
          _reportTile('Never Sold', '$neverSoldCount product(s)', Icons.remove_shopping_cart_rounded),
          _reportTile('Audit Trail', '${database.stockMovements.length} movement(s)', Icons.history_rounded),
        ]),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
            child: database.products.isEmpty
                ? const Center(child: Text('Reports will appear after you add products and sales.', style: TextStyle(color: AppColors.textMuted)))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: database.products.map((p) => ListTile(
                          title: Text(p.title),
                          subtitle: Text('SKU: ${p.sku} • ${p.category} • Cost value: ${money.format(p.stockCostValue)} • Profit/item: ${money.format(p.profitPerUnit)}', style: const TextStyle(color: AppColors.textMuted)),
                          trailing: Text(p.isLowStock ? 'LOW' : 'OK', style: TextStyle(color: p.isLowStock ? AppColors.warning : AppColors.accentGreen, fontWeight: FontWeight.bold)),
                        )).toList(),
                  ),
          ),
        ),
      ]),
    );
  }

  // Finds the product with the highest quantity sold.
  String _bestSellingProduct() {
    if (database.sales.isEmpty) return 'No sales yet';

    final totals = <String, int>{};
    final names = <String, String>{};

    for (final sale in database.sales) {
      totals[sale.productId] = (totals[sale.productId] ?? 0) + sale.quantitySold;
      names[sale.productId] = sale.productTitle;
    }

    final bestId = totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return '${names[bestId]} (${totals[bestId]} sold)';
  }

  // Builds one report summary card.
  Widget _reportTile(String title, String value, IconData icon) => SizedBox(
        width: 280,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderDark)),
          child: Row(children: [
            Icon(icon, color: AppColors.accentGreen),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
            ])),
          ]),
        ),
      );
}
