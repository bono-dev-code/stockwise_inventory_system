import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// This widget creates the left navigation menu used by the whole system.
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;

  const Sidebar({super.key, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_rounded, 'Dashboard'),
      (Icons.inventory_2_rounded, 'Products'),
      (Icons.local_shipping_rounded, 'Suppliers'),
      (Icons.shopping_cart_rounded, 'Sales'),
      (Icons.bar_chart_rounded, 'Reports'),
      (Icons.history_rounded, 'Stock History'),
      (Icons.settings_rounded, 'Settings'),
    ];

    return Container(
      width: 230,
      color: AppColors.sidebarDark,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.warehouse_rounded, color: AppColors.accentGreen), SizedBox(width: 10), Text('StockWise', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 35),
        ...List.generate(items.length, (i) {
          final selected = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: selected ? AppColors.accentGreen.withOpacity(.18) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: selected ? Border.all(color: AppColors.accentGreen) : null),
                child: Row(children: [Icon(items[i].$1, color: selected ? AppColors.accentGreen : AppColors.textMuted, size: 20), const SizedBox(width: 12), Text(items[i].$2, style: TextStyle(color: selected ? AppColors.textWhite : AppColors.textMuted, fontWeight: selected ? FontWeight.w700 : FontWeight.w500))]),
              ),
            ),
          );
        }),
        const Spacer(),
        const Text('Local Storage Mode', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ]),
    );
  }
}
