import 'package:flutter/material.dart';
import '../services/local_database_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

// This screen shows account, storage, and app information.
class SettingsScreen extends StatelessWidget {
  final LocalDatabaseService database;

  const SettingsScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final user = database.currentUser;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Card(
          color: AppColors.panelDark,
          child: ListTile(
            leading: const Icon(Icons.business, color: AppColors.accentGreen),
            title: Text(user?.businessName ?? 'No business selected'),
            subtitle: Text('Owner: ${user?.ownerName ?? 'Unknown'} • ${user?.email ?? ''}', style: const TextStyle(color: AppColors.textMuted)),
          ),
        ),
        const Card(
          color: AppColors.panelDark,
          child: ListTile(
            leading: Icon(Icons.storage, color: AppColors.accentGreen),
            title: Text('Storage Mode'),
            subtitle: Text('Local storage first. Firebase can be added later.', style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
        const Card(
          color: AppColors.panelDark,
          child: ListTile(
            leading: Icon(Icons.info, color: AppColors.accentGreen),
            title: Text('Version'),
            subtitle: Text('1.1.0 with account creation and empty starter data', style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 220,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () async {
              await database.logout();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(database: database)));
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
      ]),
    );
  }
}
