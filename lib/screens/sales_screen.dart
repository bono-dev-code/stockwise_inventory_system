import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';

// This screen records sales and automatically reduces stock quantities.
class SalesScreen extends StatefulWidget {
  final LocalDatabaseService database;

  const SalesScreen({super.key, required this.database});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Product? selectedProduct;
  final quantity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');

    if (selectedProduct != null && !widget.database.products.contains(selectedProduct)) {
      selectedProduct = null;
    }

    if (selectedProduct == null && widget.database.products.isNotEmpty) {
      selectedProduct = widget.database.products.first;
    }

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Row(children: [
        Container(
          width: 380,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Record Sale', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            DropdownButtonFormField<Product>(
              value: selectedProduct,
              decoration: const InputDecoration(labelText: 'Select product'),
              items: widget.database.products.map((p) => DropdownMenuItem(value: p, child: Text('${p.title} (${p.quantity} left)'))).toList(),
              onChanged: (p) => setState(() => selectedProduct = p),
            ),
            const SizedBox(height: 12),
            TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity sold')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark), onPressed: _saveSale, child: const Text('Save Sale'))),
            const SizedBox(height: 12),
            const Text('Add products first before recording sales.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Sales Records', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
                child: widget.database.sales.isEmpty
                    ? const Center(child: Text('No sales recorded yet.', style: TextStyle(color: AppColors.textMuted)))
                    : ListView(
                        children: widget.database.sales.reversed.map((s) => ListTile(
                              leading: const Icon(Icons.receipt_long, color: AppColors.accentGreen),
                              title: Text(s.productTitle),
                              subtitle: Text('${s.quantitySold} item(s) • ${DateFormat('dd MMM yyyy, HH:mm').format(s.date)}', style: const TextStyle(color: AppColors.textMuted)),
                              trailing: Text(money.format(s.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                            )).toList(),
                      ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // Saves a sale and gives feedback if the sale cannot be completed.
  void _saveSale() async {
    final product = selectedProduct;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a product before saving a sale.')));
      return;
    }

    final soldQuantity = int.tryParse(quantity.text) ?? 0;

    // recordSale returns the exact saved sale.
    // The receipt uses this object so the prices never show R0.00 unless the product price is actually zero.
    final savedSale = await widget.database.recordSale(product, soldQuantity);
    if (!mounted) return;

    if (savedSale != null) {
      _showReceipt(savedSale);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(savedSale != null ? 'Sale saved, receipt created, and stock reduced.' : 'Sale failed. Check stock quantity.')));
    quantity.clear();
    setState(() {});
  }

  // Shows a simple receipt after a successful sale.
  // This makes the system feel more like a real point-of-sale workflow.
  void _showReceipt(dynamic sale) {
    final money = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('Sale Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${sale.productTitle}'),
            const SizedBox(height: 8),
            Text('Quantity: ${sale.quantitySold}'),
            const SizedBox(height: 8),
            Text('Cost price: ${money.format(sale.unitCost)}'),
            const SizedBox(height: 8),
            Text('Selling price: ${money.format(sale.unitPrice)}'),
            const Divider(height: 24),
            Text('Total: ${money.format(sale.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
            const SizedBox(height: 8),
            Text('Profit: ${money.format(sale.profitAmount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Date: ${DateFormat('dd MMM yyyy, HH:mm').format(sale.date)}", style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
