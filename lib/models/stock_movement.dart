// This class stores every important stock change in the system.
// It works like an audit trail so the business can see what happened to stock.
class StockMovement {
  final String id;
  final String productId;
  final String productTitle;
  final String type;
  final int quantityChange;
  final int quantityAfter;
  final String note;
  final DateTime date;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.type,
    required this.quantityChange,
    required this.quantityAfter,
    required this.note,
    required this.date,
  });

  // Converts the stock movement into JSON so it can be saved locally.
  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productTitle': productTitle,
        'type': type,
        'quantityChange': quantityChange,
        'quantityAfter': quantityAfter,
        'note': note,
        'date': date.toIso8601String(),
      };

  // Converts saved JSON data back into a StockMovement object.
  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
        id: json['id'],
        productId: json['productId'],
        productTitle: json['productTitle'],
        type: json['type'],
        quantityChange: json['quantityChange'],
        quantityAfter: json['quantityAfter'],
        note: json['note'] ?? '',
        date: DateTime.parse(json['date']),
      );
}
