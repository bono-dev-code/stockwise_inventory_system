// This class represents a product that the business keeps in stock.
// It stores the important inventory details that a real small business needs.
class Product {
  final String id;
  String sku;
  String title;
  String category;
  int quantity;
  int lowStockLimit;
  double costPrice;
  double sellingPrice;
  String supplierId;
  DateTime lastModified;

  Product({
    required this.id,
    required this.sku,
    required this.title,
    required this.category,
    required this.quantity,
    required this.lowStockLimit,
    required this.costPrice,
    required this.sellingPrice,
    required this.supplierId,
    required this.lastModified,
  });

  // Keeps old screens working by treating price as the selling price.
  double get price => sellingPrice;

  // This helps the dashboard know when the product needs attention.
  bool get isLowStock => quantity <= lowStockLimit;

  // Shows the profit the business makes from selling one item.
  double get profitPerUnit => sellingPrice - costPrice;

  // Shows the total value of this product based on current stock and cost price.
  double get stockCostValue => costPrice * quantity;

  // Shows the possible sales value if all current stock is sold.
  double get stockSellingValue => sellingPrice * quantity;

  // Converts the product into JSON format for local storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'title': title,
        'category': category,
        'quantity': quantity,
        'lowStockLimit': lowStockLimit,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'supplierId': supplierId,
        'lastModified': lastModified.toIso8601String(),
      };

  // Converts saved JSON data back into a Product object.
  // The fallback values allow older saved data to continue working.
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        sku: json['sku'],
        title: json['title'],
        category: json['category'],
        quantity: json['quantity'],
        lowStockLimit: json['lowStockLimit'],
        costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
        sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0,
        supplierId: json['supplierId'] ?? '',
        lastModified: DateTime.parse(json['lastModified']),
      );
}
