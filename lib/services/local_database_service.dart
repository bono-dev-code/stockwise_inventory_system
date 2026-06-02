import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/supplier.dart';
import '../models/stock_movement.dart';

// This service works like a small local database for StockWise Lite.
// It saves users, products, suppliers, sales, and stock movement history inside SharedPreferences.
class LocalDatabaseService extends ChangeNotifier {
  static const _usersKey = 'stockwise_users';
  static const _currentUserKey = 'stockwise_current_user';
  static const _productsKey = 'stockwise_products';
  static const _suppliersKey = 'stockwise_suppliers';
  static const _salesKey = 'stockwise_sales';
  static const _stockMovementsKey = 'stockwise_stock_movements';
  static const _customCategoriesKey = 'stockwise_custom_categories';

  // These starter categories help the user choose quickly, but the user can add more categories.
  final List<String> defaultCategories = const ['Electronics', 'Groceries', 'Clothing', 'Accessories', 'Hardware', 'Stationery', 'Other'];

  // Custom categories are saved separately so a user can create a category before adding many products to it.
  final List<String> customCategories = [];

  final List<AppUser> users = [];
  final List<Product> products = [];
  final List<Supplier> suppliers = [];
  final List<Sale> sales = [];
  final List<StockMovement> stockMovements = [];

  AppUser? currentUser;

  // Loads all locally saved information when the app starts.
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersText = prefs.getString(_usersKey);
    final currentUserId = prefs.getString(_currentUserKey);
    final productText = prefs.getString(_productsKey);
    final supplierText = prefs.getString(_suppliersKey);
    final salesText = prefs.getString(_salesKey);
    final movementsText = prefs.getString(_stockMovementsKey);
    final categoriesText = prefs.getString(_customCategoriesKey);

    users.clear();
    products.clear();
    suppliers.clear();
    sales.clear();
    stockMovements.clear();
    customCategories.clear();

    if (usersText != null) {
      users.addAll((jsonDecode(usersText) as List).map((e) => AppUser.fromJson(e)));
    }

    if (productText != null) {
      products.addAll((jsonDecode(productText) as List).map((e) => Product.fromJson(e)));
    }

    if (supplierText != null) {
      suppliers.addAll((jsonDecode(supplierText) as List).map((e) => Supplier.fromJson(e)));
    }

    if (salesText != null) {
      sales.addAll((jsonDecode(salesText) as List).map((e) => Sale.fromJson(e)));
    }

    if (movementsText != null) {
      stockMovements.addAll((jsonDecode(movementsText) as List).map((e) => StockMovement.fromJson(e)));
    }

    if (categoriesText != null) {
      customCategories.addAll((jsonDecode(categoriesText) as List).map((e) => e.toString()));
    }

    if (currentUserId != null) {
      for (final user in users) {
        if (user.id == currentUserId) {
          currentUser = user;
          break;
        }
      }
    }

    notifyListeners();
  }

  // Saves all app data after changes are made.
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users.map((e) => e.toJson()).toList()));
    await prefs.setString(_productsKey, jsonEncode(products.map((e) => e.toJson()).toList()));
    await prefs.setString(_suppliersKey, jsonEncode(suppliers.map((e) => e.toJson()).toList()));
    await prefs.setString(_salesKey, jsonEncode(sales.map((e) => e.toJson()).toList()));
    await prefs.setString(_stockMovementsKey, jsonEncode(stockMovements.map((e) => e.toJson()).toList()));
    await prefs.setString(_customCategoriesKey, jsonEncode(customCategories));
    if (currentUser != null) {
      await prefs.setString(_currentUserKey, currentUser!.id);
    } else {
      await prefs.remove(_currentUserKey);
    }
    notifyListeners();
  }

  // Creates a new account after checking that the email is not already used.
  Future<String?> createAccount(AppUser user) async {
    final emailExists = users.any((u) => u.email.toLowerCase() == user.email.toLowerCase());
    if (emailExists) return 'An account with this email already exists.';

    users.add(user);
    currentUser = user;
    await saveData();
    return null;
  }

  // Checks the login details against the locally saved accounts.
  Future<bool> login(String email, String password) async {
    for (final user in users) {
      final sameEmail = user.email.toLowerCase() == email.toLowerCase();
      final samePassword = user.password == password;
      if (sameEmail && samePassword) {
        currentUser = user;
        await saveData();
        return true;
      }
    }
    return false;
  }

  // Logs the current user out without deleting business data.
  Future<void> logout() async {
    currentUser = null;
    await saveData();
  }

  // Adds a new product entered by the user and records the first stock movement.
  Future<void> addProduct(Product product) async {
    products.add(product);
    _addStockMovement(product, 'Product Added', product.quantity, product.quantity, 'New product created with opening stock.');
    await saveData();
  }

  // Updates an existing product after editing.
  // If the quantity changes, the system records the difference in stock history.
  Future<void> updateProduct(Product product) async {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      final oldQuantity = products[index].quantity;
      final change = product.quantity - oldQuantity;
      products[index] = product;
      if (change != 0) {
        _addStockMovement(product, 'Manual Adjustment', change, product.quantity, 'Product quantity was edited manually.');
      }
      await saveData();
    }
  }

  // Deletes a product from the local list and records that it was removed.
  Future<void> deleteProduct(String id) async {
    final index = products.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final product = products[index];
      _addStockMovement(product, 'Product Deleted', -product.quantity, 0, 'Product was removed from the system.');
      products.removeAt(index);
      await saveData();
    }
  }

  // Adds a new category typed by the user.
  // This prevents the system from being limited to the starter category list only.
  Future<void> addCategory(String category) async {
    final cleanCategory = category.trim();
    if (cleanCategory.isEmpty) return;

    final exists = categories.any((c) => c.toLowerCase() == cleanCategory.toLowerCase());
    if (!exists) {
      customCategories.add(cleanCategory);
      await saveData();
    }
  }

  // Adds a supplier entered by the user.
  Future<void> addSupplier(Supplier supplier) async {
    suppliers.add(supplier);
    await saveData();
  }

  // Deletes a supplier and leaves existing products unchanged.
  Future<void> deleteSupplier(String id) async {
    suppliers.removeWhere((s) => s.id == id);
    await saveData();
  }

  // Records a sale and automatically reduces the product stock quantity.
  // The method returns the saved Sale object so the receipt can show the exact saved prices, revenue, and profit.
  Future<Sale?> recordSale(Product product, int quantity) async {
    if (quantity <= 0) return null;

    // Always use the latest product from the database list.
    // This prevents old screen copies from using old prices such as R0.00 after a product was edited.
    final index = products.indexWhere((p) => p.id == product.id);
    if (index < 0) return null;

    final savedProduct = products[index];
    if (savedProduct.quantity < quantity) return null;

    savedProduct.quantity -= quantity;
    savedProduct.lastModified = DateTime.now();

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: savedProduct.id,
      productTitle: savedProduct.title,
      quantitySold: quantity,
      unitCost: savedProduct.costPrice,
      unitPrice: savedProduct.sellingPrice,
      totalAmount: savedProduct.sellingPrice * quantity,
      profitAmount: savedProduct.profitPerUnit * quantity,
      date: DateTime.now(),
    );

    _addStockMovement(savedProduct, 'Sale', -quantity, savedProduct.quantity, 'Stock reduced after a sale was recorded.');
    sales.add(sale);

    await saveData();
    return sale;
  }

  // Adds one stock movement item to the audit trail.
  void _addStockMovement(Product product, String type, int quantityChange, int quantityAfter, String note) {
    stockMovements.add(StockMovement(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      productId: product.id,
      productTitle: product.title,
      type: type,
      quantityChange: quantityChange,
      quantityAfter: quantityAfter,
      note: note,
      date: DateTime.now(),
    ));
  }

  // Counts products that are currently at or below the low stock limit.
  int get lowStockCount => products.where((p) => p.isLowStock).length;

  // Returns all categories currently used by products, custom categories, and the default list.
  List<String> get categories {
    final values = <String>{...defaultCategories, ...customCategories};
    for (final product in products) {
      if (product.category.trim().isNotEmpty) values.add(product.category.trim());
    }
    return values.toList()..sort();
  }

  // Counts unique product categories for the dashboard.
  int get totalCategories => categories.length;

  // Calculates total revenue from all saved sales.
  double get totalRevenue => sales.fold(0, (sum, s) => sum + s.totalAmount);

  // Calculates total profit from all saved sales.
  double get totalProfit => sales.fold(0, (sum, s) => sum + s.profitAmount);

  // Calculates what the current stock cost the business to buy.
  double get totalStockCostValue => products.fold(0, (sum, p) => sum + p.stockCostValue);

  // Calculates the possible sales value of the current stock.
  double get totalStockSellingValue => products.fold(0, (sum, p) => sum + p.stockSellingValue);

  // Calculates the total amount made today from saved sales.
  double get todaySalesTotal {
    final now = DateTime.now();
    return sales.where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day).fold(0, (sum, s) => sum + s.totalAmount);
  }

  // Calculates today's profit from saved sales.
  double get todayProfitTotal {
    final now = DateTime.now();
    return sales.where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day).fold(0, (sum, s) => sum + s.profitAmount);
  }

  // Creates a simple SKU based on the category and current time.
  // The user can still edit it before saving the product.
  String generateSku(String category) {
    final cleanCategory = category.trim().isEmpty ? 'STK' : category.trim().toUpperCase();
    final prefix = cleanCategory.replaceAll(RegExp(r'[^A-Z0-9]'), '').padRight(3, 'X').substring(0, 3);
    final number = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return '$prefix-$number';
  }
}

