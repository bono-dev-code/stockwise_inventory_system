import 'package:flutter/material.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';
import 'register_screen.dart';

// This screen requires the user to login before using StockWise.
class LoginScreen extends StatefulWidget {
  final LocalDatabaseService database;

  const LoginScreen({super.key, required this.database});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 430,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: AppColors.panelDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.borderDark)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.warehouse_rounded, color: AppColors.accentGreen, size: 34), SizedBox(width: 12), Text('StockWise Lite', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 10),
            const Text('Login to manage your own business inventory.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 28),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 14),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.bgDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: _login, child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)))),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(database: widget.database))),
                child: const Text('Create a new account'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // Checks if the entered email and password match a locally saved account.
  Future<void> _login() async {
    final success = await widget.database.login(emailController.text.trim(), passwordController.text);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell(database: widget.database)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid login details. Create an account first.')));
    }
  }
}
