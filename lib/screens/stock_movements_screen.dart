import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';

// This screen shows the full stock movement history.
// It helps the business track who changed stock, when it changed, and why it changed.
class StockMovementsScreen extends StatefulWidget {
  final LocalDatabaseService database;

  const StockMovementsScreen({super.key, required this.database});

  @override
  State<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends State<StockMovementsScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final movements = widget.database.stockMovements.reversed
        .where((m) => m.productTitle.toLowerCase().contains(search.toLowerCase()) || m.type.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Stock Movement History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            width: 310,
            child: TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search product or movement type'),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        const Text('Audit trail for product additions, sales, manual stock edits, and deleted products.', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.borderDark)),
            child: movements.isEmpty
                ? const Center(child: Text('No stock movements yet. Add products or record sales to create history.', style: TextStyle(color: AppColors.textMuted)))
                : SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 28,
                      headingRowColor: WidgetStateProperty.all(AppColors.panelLight),
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Change')),
                        DataColumn(label: Text('After')),
                        DataColumn(label: Text('Note')),
                      ],
                      rows: movements.map((m) {
                        final isPositive = m.quantityChange >= 0;
                        return DataRow(cells: [
                          DataCell(Text(DateFormat('dd MMM yyyy, HH:mm').format(m.date))),
                          DataCell(Text(m.productTitle)),
                          DataCell(Text(m.type)),
                          DataCell(Text('${isPositive ? '+' : ''}${m.quantityChange}', style: TextStyle(color: isPositive ? AppColors.accentGreen : AppColors.warning, fontWeight: FontWeight.bold))),
                          DataCell(Text('${m.quantityAfter}')),
                          DataCell(SizedBox(width: 260, child: Text(m.note, overflow: TextOverflow.ellipsis))),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}
