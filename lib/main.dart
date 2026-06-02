import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/local_database_service.dart';
import 'theme/app_colors.dart';

// This is the starting point of the StockWise Lite application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StockWiseApp());
}

// This widget controls the main MaterialApp and loads local data.
class StockWiseApp extends StatefulWidget {
  const StockWiseApp({super.key});

  @override
  State<StockWiseApp> createState() => _StockWiseAppState();
}

class _StockWiseAppState extends State<StockWiseApp> {
  final LocalDatabaseService database = LocalDatabaseService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  // Loads saved local data before showing login or the main system.
  Future<void> _loadAppData() async {
    await database.loadData();
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: database,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StockWise Lite',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.bgDark,
            fontFamily: 'Arial',
            brightness: Brightness.dark,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.panelDark,
              labelStyle: const TextStyle(color: AppColors.textMuted),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderDark), borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accentGreen), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          home: isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accentGreen)))
              : database.currentUser == null
                  ? LoginScreen(database: database)
                  : MainShell(database: database),
        );
      },
    );
  }
}
