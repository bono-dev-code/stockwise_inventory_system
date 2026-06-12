import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';
import 'add_product_screen.dart';

// This screen lists all products and allows searching, filtering, viewing, editing, and deleting.
// The user can  click a product row to see full product details and linked supplier details.
class ProductsScreen extends StatefulWidget {
  final LocalDatabaseService database;

  const ProductsScreen({super.key, required this.database});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String search = '';
  String categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    final categories = ['All', ...widget.database.categories];

    // Filter products by search text and selected category.
    final items = widget.database.products.where((p) {
      final supplier = _findSupplier(p);
      final supplierName = supplier?.name.toLowerCase() ?? '';
      final matchesSearch = p.title.toLowerCase().contains(search.toLowerCase()) ||
          p.sku.toLowerCase().contains(search.toLowerCase()) ||
          p.category.toLowerCase().contains(search.toLowerCase()) ||
          supplierName.contains(search.toLowerCase());
      final matchesCategory = categoryFilter == 'All' || p.category == categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Products', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            width: 210,
            child: DropdownButtonFormField<String>(
              value: categoryFilter,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => categoryFilter = v ?? 'All'),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search products, SKU, supplier'),
            ),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark),
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('Tip: click any product row to view all product and supplier details.', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
            child: items.isEmpty
                ? const Center(child: Text('No products yet. Click Add Product to create your first item.', style: TextStyle(color: AppColors.textMuted)))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 26,
                        headingRowColor: WidgetStateProperty.all(AppColors.panelLight),
                        columns: const [
                          DataColumn(label: Text('SKU')),
                          DataColumn(label: Text('Title')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Supplier')),
                          DataColumn(label: Text('QTY')),
                          DataColumn(label: Text('Cost')),
                          DataColumn(label: Text('Selling')),
                          DataColumn(label: Text('Profit/Item')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: items.map((p) {
                          final supplier = _findSupplier(p);
                          return DataRow(
                            // This makes the full row clickable so the user can inspect the product properly.
                            onSelectChanged: (_) => _showProductDetails(p),
                            cells: [
                              DataCell(Text(p.sku), onTap: () => _showProductDetails(p)),
                              DataCell(Text(p.title), onTap: () => _showProductDetails(p)),
                              DataCell(Text(p.category), onTap: () => _showProductDetails(p)),
                              DataCell(Text(supplier?.name ?? 'No supplier'), onTap: () => _showProductDetails(p)),
                              DataCell(Text('${p.quantity}'), onTap: () => _showProductDetails(p)),
                              DataCell(Text(money.format(p.costPrice)), onTap: () => _showProductDetails(p)),
                              DataCell(Text(money.format(p.sellingPrice)), onTap: () => _showProductDetails(p)),
                              DataCell(Text(money.format(p.profitPerUnit), style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold)), onTap: () => _showProductDetails(p)),
                              DataCell(Text(p.isLowStock ? 'LOW STOCK' : 'IN STOCK', style: TextStyle(color: p.isLowStock ? AppColors.warning : AppColors.accentGreen, fontWeight: FontWeight.bold)), onTap: () => _showProductDetails(p)),
                              DataCell(Row(children: [
                                IconButton(tooltip: 'View details', onPressed: () => _showProductDetails(p), icon: const Icon(Icons.visibility, color: AppColors.accentGreen)),
                                IconButton(onPressed: () => _openForm(product: p), icon: const Icon(Icons.edit, color: AppColors.textMuted)),
                                IconButton(onPressed: () => _confirmDelete(p), icon: const Icon(Icons.delete, color: AppColors.danger)),
                              ])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }

  // Finds the supplier connected to a product using the supplier ID saved on the product.
  Supplier? _findSupplier(Product product) {
    for (final supplier in widget.database.suppliers) {
      if (supplier.id == product.supplierId) return supplier;
    }
    return null;
  }

  // Opens a professional details popup showing product information and supplier information together.
  void _showProductDetails(Product product) {
    final money = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    final date = DateFormat('dd MMM yyyy, HH:mm').format(product.lastModified);
    final supplier = _findSupplier(product);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(children: [
          const Icon(Icons.inventory_2, color: AppColors.accentGreen),
          const SizedBox(width: 10),
          Expanded(child: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold))),
        ]),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              _sectionTitle('Product Details'),
              _detailRow('SKU Code', product.sku),
              _detailRow('Category', product.category),
              _detailRow('Quantity in Stock', '${product.quantity}'),
              _detailRow('Low Stock Limit', '${product.lowStockLimit}'),
              _detailRow('Stock Status', product.isLowStock ? 'LOW STOCK' : 'IN STOCK', valueColor: product.isLowStock ? AppColors.warning : AppColors.accentGreen),
              _detailRow('Last Modified', date),
              const SizedBox(height: 16),
              _sectionTitle('Pricing and Profit'),
              _detailRow('Cost Price', money.format(product.costPrice)),
              _detailRow('Selling Price', money.format(product.sellingPrice)),
              _detailRow('Profit per Item', money.format(product.profitPerUnit), valueColor: product.profitPerUnit < 0 ? AppColors.danger : AppColors.accentGreen),
              _detailRow('Current Stock Cost Value', money.format(product.stockCostValue)),
              _detailRow('Potential Stock Sales Value', money.format(product.stockSellingValue)),
              const SizedBox(height: 16),
              _sectionTitle('Supplier Details'),
              if (supplier == null) ...[
                const Text('No supplier is linked to this product yet.', style: TextStyle(color: AppColors.textMuted)),
              ] else ...[
                _detailRow('Supplier Name', supplier.name),
                _detailRow('Phone Number', supplier.phone.isEmpty ? 'Not provided' : supplier.phone),
                _detailRow('Email Address', supplier.email.isEmpty ? 'Not provided' : supplier.email),
                _detailRow('Supplier Category', supplier.category.isEmpty ? 'Not provided' : supplier.category),
                _detailRow('Location', supplier.location.isEmpty ? 'Not provided' : supplier.location),
              ],
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark),
            onPressed: () {
              Navigator.pop(context);
              _openForm(product: product);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Product'),
          ),
        ],
      ),
    );
  }

  // Small heading used inside the product details popup.
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
    );
  }

  // Reusable row used to keep the details popup clean and consistent.
  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.panelLight, borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 190, child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
        Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: valueColor))),
      ]),
    );
  }

  // Asks before deleting because deleting stock is a serious business action.
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.database.deleteProduct(product.id);
              if (mounted) setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  // Opens the product form in add mode or edit mode.
  void _openForm({Product? product}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductScreen(database: widget.database, product: product))).then((_) => setState(() {}));
  }
}
