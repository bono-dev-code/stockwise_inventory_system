import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

// This screen allows a new business owner to create a StockWise account.
class RegisterScreen extends StatefulWidget {
  final LocalDatabaseService database;

  const RegisterScreen({super.key, required this.database});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final businessName = TextEditingController();
  final ownerName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.panelDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warehouse_rounded, color: AppColors.accentGreen, size: 34),
                    SizedBox(width: 12),
                    Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Start with an empty inventory and build your own business data.', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 24),
                TextField(controller: businessName, decoration: const InputDecoration(labelText: 'Business name')),
                const SizedBox(height: 12),
                TextField(controller: ownerName, decoration: const InputDecoration(labelText: 'Owner name')),
                const SizedBox(height: 12),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email address')),
                const SizedBox(height: 12),
                TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 12),
                TextField(controller: confirmPassword, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: _createAccount,
                    child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Validates the form and saves the new account locally.
  Future<void> _createAccount() async {
    if (businessName.text.trim().isEmpty || ownerName.text.trim().isEmpty || email.text.trim().isEmpty || password.text.isEmpty) {
      _showMessage('Please complete all required fields.');
      return;
    }

    if (password.text.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    if (password.text != confirmPassword.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessName: businessName.text.trim(),
      ownerName: ownerName.text.trim(),
      email: email.text.trim(),
      password: password.text,
    );

    final error = await widget.database.createAccount(user);
    if (!mounted) return;

    if (error != null) {
      _showMessage(error);
      return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell(database: widget.database)));
  }

  // Shows a short message at the bottom of the screen.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
