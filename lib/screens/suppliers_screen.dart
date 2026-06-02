import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';

// This screen lets the user add and manage suppliers.
// Suppliers now use the same category list as products so the system stays consistent.
// The user can either choose an existing category or create a new category while adding a supplier.
class SuppliersScreen extends StatefulWidget {
  final LocalDatabaseService database;

  const SuppliersScreen({super.key, required this.database});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  static const addNewCategoryOption = 'Add new category';

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final newCategory = TextEditingController();
  final location = TextEditingController();

  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Select the first available category when the screen opens.
    selectedCategory = widget.database.categories.isNotEmpty ? widget.database.categories.first : addNewCategoryOption;
  }

  @override
  void dispose() {
    // Disposes controllers to avoid keeping unused form resources in memory.
    name.dispose();
    phone.dispose();
    email.dispose();
    newCategory.dispose();
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryChoices = [...widget.database.categories, addNewCategoryOption];

    // If the saved selected category no longer exists, choose a safe default.
    if (selectedCategory != null && !categoryChoices.contains(selectedCategory)) {
      selectedCategory = categoryChoices.first;
    }

    final isAddingNewCategory = selectedCategory == addNewCategoryOption;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Suppliers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Click a supplier to view phone, email, category, and location details.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
                child: widget.database.suppliers.isEmpty
                    ? const Center(child: Text('No suppliers yet. Add suppliers used by your business.', style: TextStyle(color: AppColors.textMuted)))
                    : ListView(
                        children: widget.database.suppliers.map((s) => ListTile(
                              onTap: () => _showSupplierDetails(s),
                              leading: const Icon(Icons.local_shipping_rounded, color: AppColors.accentGreen),
                              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${s.phone} • ${s.email}\n${s.category} • ${s.location}', style: const TextStyle(color: AppColors.textMuted)),
                              isThreeLine: true,
                              trailing: IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () => widget.database.deleteSupplier(s.id)),
                            )).toList(),
                      ),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 22),
        Container(
          width: 380,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
          child: ListView(shrinkWrap: true, children: [
            const Text('Add Supplier', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Supplier name')),
            const SizedBox(height: 12),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone number')),
            const SizedBox(height: 12),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Product category'),
              items: categoryChoices.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  if (value != addNewCategoryOption) newCategory.clear();
                });
              },
            ),
            if (isAddingNewCategory) ...[
              const SizedBox(height: 12),
              TextField(
                controller: newCategory,
                decoration: const InputDecoration(labelText: 'New category name'),
              ),
            ],
            const SizedBox(height: 12),
            TextField(controller: location, decoration: const InputDecoration(labelText: 'Supplier location')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark), onPressed: _addSupplier, child: const Text('Save Supplier'))),
          ]),
        ),
      ]),
    );
  }

  // Shows a professional detail popup when the user clicks a supplier.
  void _showSupplierDetails(Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: Text(supplier.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.phone, 'Phone', supplier.phone),
            _detailRow(Icons.email, 'Email', supplier.email),
            _detailRow(Icons.category, 'Category', supplier.category),
            _detailRow(Icons.location_on, 'Location', supplier.location),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  // Builds one readable row inside the supplier detail popup.
  Widget _detailRow(IconData icon, String label, String value) {
    final displayValue = value.trim().isEmpty ? 'Not specified' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.accentGreen, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text('$label: $displayValue', style: const TextStyle(color: AppColors.textWhite))),
      ]),
    );
  }

  // Adds a supplier after checking that a supplier name and category were entered.
  Future<void> _addSupplier() async {
    if (name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier name is required.')));
      return;
    }

    final categoryToSave = selectedCategory == addNewCategoryOption ? newCategory.text.trim() : (selectedCategory ?? '').trim();

    if (categoryToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose a category or add a new category.')));
      return;
    }

    // Save the new category first so it appears later in Products and Suppliers.
    await widget.database.addCategory(categoryToSave);

    await widget.database.addSupplier(Supplier(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.text.trim(),
      phone: phone.text.trim(),
      email: email.text.trim(),
      category: categoryToSave,
      location: location.text.trim(),
    ));

    setState(() {
      name.clear();
      phone.clear();
      email.clear();
      newCategory.clear();
      location.clear();
      selectedCategory = categoryToSave;
    });
  }
}
