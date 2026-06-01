// This class stores supplier details used by the business.
// A supplier can now also store a location so the user knows where the supplier is based.
class Supplier {
  final String id;
  String name;
  String phone;
  String email;
  String category;
  String location;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.category,
    required this.location,
  });

  // Converts the supplier into JSON format for local storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'category': category,
        'location': location,
      };

  // Converts saved JSON data back into a Supplier object.
  // The location fallback keeps older saved supplier records working.
  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'],
        name: json['name'],
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        category: json['category'] ?? '',
        location: json['location'] ?? 'Not specified',
      );
}
