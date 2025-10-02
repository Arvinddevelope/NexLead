import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/providers/auth_provider.dart';
import 'package:nextlead/providers/settings_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      settingsProvider.userName.isEmpty
                          ? 'User'
                          : settingsProvider.userName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      settingsProvider.userEmail,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Drawer Items
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text(AppTexts.dashboardTitle),
            onTap: () {
              Navigator.pop(context);
              // Navigate to dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text(AppTexts.leadsTitle),
            onTap: () {
              Navigator.pop(context);
              // Navigate to leads
            },
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text(AppTexts.tasksTitle),
            onTap: () {
              Navigator.pop(context);
              // Navigate to tasks
            },
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text(AppTexts.notesTitle),
            onTap: () {
              Navigator.pop(context);
              // Navigate to notes
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(AppTexts.settingsTitle),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          const Spacer(),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle logout
                  _confirmLogout(context, authProvider);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                authProvider.logout();
                // Navigate to login screen
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
