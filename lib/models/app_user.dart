// This class represents one StockWise user account.
// For this Lite version, the account is stored locally using SharedPreferences.
class AppUser {
  final String id;
  final String businessName;
  final String ownerName;
  final String email;
  final String password;

  AppUser({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.password,
  });

  // Converts the user object into a map so it can be saved as JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'businessName': businessName,
        'ownerName': ownerName,
        'email': email,
        'password': password,
      };

  // Converts saved JSON data back into an AppUser object.
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        businessName: json['businessName'],
        ownerName: json['ownerName'],
        email: json['email'],
        password: json['password'],
      );
}
