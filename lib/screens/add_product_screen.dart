import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';

// This screen is used for both adding a new product and editing an existing one.
// It now includes real inventory fields: category, SKU, cost price, and selling price.
class AddProductScreen extends StatefulWidget {
  final LocalDatabaseService database;
  final Product? product;

  const AddProductScreen({super.key, required this.database, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final sku = TextEditingController();
  final title = TextEditingController();
  final customCategory = TextEditingController();
  final quantity = TextEditingController();
  final lowLimit = TextEditingController(text: '5');
  final costPrice = TextEditingController();
  final sellingPrice = TextEditingController();
  String supplierId = '';
  String selectedCategory = 'Accessories';
  static const String addNewCategoryOption = '+ Add new category';

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    // If a product was passed in, the form opens in edit mode.
    if (p != null) {
      sku.text = p.sku;
      title.text = p.title;
      selectedCategory = widget.database.categories.contains(p.category) ? p.category : addNewCategoryOption;
      customCategory.text = widget.database.categories.contains(p.category) ? '' : p.category;
      quantity.text = '${p.quantity}';
      lowLimit.text = '${p.lowStockLimit}';
      costPrice.text = '${p.costPrice}';
      sellingPrice.text = '${p.sellingPrice}';
      supplierId = p.supplierId;
    } else {
      selectedCategory = widget.database.categories.contains('Accessories') ? 'Accessories' : widget.database.categories.first;
      sku.text = widget.database.generateSku(selectedCategory);
      if (widget.database.suppliers.isNotEmpty) supplierId = widget.database.suppliers.first.id;
    }
  }

  @override
  void dispose() {
    sku.dispose();
    title.dispose();
    customCategory.dispose();
    quantity.dispose();
    lowLimit.dispose();
    costPrice.dispose();
    sellingPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryChoices = [...widget.database.categories, addNewCategoryOption];
    final profitPreview = _parseMoney(sellingPrice.text) - _parseMoney(costPrice.text);

    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.bgDark, title: Text(widget.product == null ? 'Add Product' : 'Edit Product')),
      body: Center(
        child: Container(
          width: 720,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderDark)),
          child: ListView(shrinkWrap: true, children: [
            Row(children: [
              Expanded(child: TextField(controller: sku, decoration: const InputDecoration(labelText: 'SKU code'))),
              const SizedBox(width: 10),
              OutlinedButton.icon(onPressed: _generateSku, icon: const Icon(Icons.qr_code_2), label: const Text('Generate')),
            ]),
            const SizedBox(height: 12),
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Product title')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categoryChoices.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() {
                selectedCategory = v ?? 'Other';
                if (widget.product == null) sku.text = widget.database.generateSku(_finalCategory);
              }),
            ),
            if (selectedCategory == addNewCategoryOption) ...[
              const SizedBox(height: 12),
              TextField(controller: customCategory, decoration: const InputDecoration(labelText: 'New category name')),
              const SizedBox(height: 6),
              const Text('This category will be saved and will appear in the category list next time.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: lowLimit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Low stock limit'))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: costPrice, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Cost price'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: sellingPrice, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Selling price'))),
            ]),
            const SizedBox(height: 10),
            Text('Profit per item: R${profitPreview.toStringAsFixed(2)}', style: TextStyle(color: profitPreview < 0 ? AppColors.danger : AppColors.accentGreen, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: supplierId.isEmpty ? null : supplierId,
              decoration: const InputDecoration(labelText: 'Supplier optional'),
              items: widget.database.suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => supplierId = v ?? ''),
            ),
            const SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark), onPressed: _save, child: const Text('Save Product')),
          ]),
        ),
      ),
    );
  }

  // Returns either the selected category or the custom category typed by the user.
  String get _finalCategory => selectedCategory == addNewCategoryOption && customCategory.text.trim().isNotEmpty ? customCategory.text.trim() : selectedCategory;

  // Generates a professional SKU from the chosen category.
  void _generateSku() {
    setState(() => sku.text = widget.database.generateSku(_finalCategory));
  }

  // Validates the form and sends the product to the local database service.
  Future<void> _save() async {
    final cost = _parseMoney(costPrice.text);
    final selling = _parseMoney(sellingPrice.text);

    if (sku.text.trim().isEmpty || title.text.trim().isEmpty || _finalCategory.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter SKU, title, and category.')));
      return;
    }

    if (selectedCategory == addNewCategoryOption && customCategory.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the new category name.')));
      return;
    }

    if (selling < cost) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selling price should not be lower than cost price.')));
      return;
    }

    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sku: sku.text.trim(),
      title: title.text.trim(),
      category: _finalCategory,
      quantity: int.tryParse(quantity.text) ?? 0,
      lowStockLimit: int.tryParse(lowLimit.text) ?? 5,
      costPrice: cost,
      sellingPrice: selling,
      supplierId: supplierId,
      lastModified: DateTime.now(),
    );

    await widget.database.addCategory(_finalCategory);

    if (widget.product == null) {
      await widget.database.addProduct(product);
    } else {
      await widget.database.updateProduct(product);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  // Accepts normal numbers and values typed with R or commas, for example R120.50 or 1,200.50.
  double _parseMoney(String value) {
    final cleanValue = value.replaceAll('R', '').replaceAll(',', '').trim();
    return double.tryParse(cleanValue) ?? 0;
  }
}
