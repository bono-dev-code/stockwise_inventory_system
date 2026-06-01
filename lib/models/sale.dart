// This class represents one completed sale transaction.
// It stores revenue and profit so the reports can show business performance.
class Sale {
  final String id;
  final String productId;
  final String productTitle;
  final int quantitySold;
  final double unitCost;
  final double unitPrice;
  final double totalAmount;
  final double profitAmount;
  final DateTime date;

  Sale({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.quantitySold,
    required this.unitCost,
    required this.unitPrice,
    required this.totalAmount,
    required this.profitAmount,
    required this.date,
  });

  // Converts the sale into JSON format for local storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productTitle': productTitle,
        'quantitySold': quantitySold,
        'unitCost': unitCost,
        'unitPrice': unitPrice,
        'totalAmount': totalAmount,
        'profitAmount': profitAmount,
        'date': date.toIso8601String(),
      };

  // Converts saved JSON data back into a Sale object.
  // Fallbacks protect the app if the user had sales saved from an older version.
  factory Sale.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantitySold'] as int;
    final total = (json['totalAmount'] as num).toDouble();
    final unitPrice = (json['unitPrice'] as num?)?.toDouble() ?? (quantity == 0 ? 0 : total / quantity);
    final unitCost = (json['unitCost'] as num?)?.toDouble() ?? 0;
    return Sale(
      id: json['id'],
      productId: json['productId'],
      productTitle: json['productTitle'],
      quantitySold: quantity,
      unitCost: unitCost,
      unitPrice: unitPrice,
      totalAmount: total,
      profitAmount: (json['profitAmount'] as num?)?.toDouble() ?? ((unitPrice - unitCost) * quantity),
      date: DateTime.parse(json['date']),
    );
  }
}
