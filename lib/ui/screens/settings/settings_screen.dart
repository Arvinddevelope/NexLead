import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/providers/auth_provider.dart';
import 'package:nextlead/providers/notification_provider.dart';
import 'package:nextlead/providers/settings_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/components/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load user data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize controllers with user data
    _nameController.text = settingsProvider.userName.isNotEmpty
        ? settingsProvider.userName
        : authProvider.userName;
    _emailController.text = settingsProvider.userEmail.isNotEmpty
        ? settingsProvider.userEmail
        : authProvider.userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // Handle navigation based on index
      switch (index) {
        case 0: // Dashboard
          Navigator.pushNamed(context, AppRoutes.dashboard);
          break;
        case 1: // Leads
          Navigator.pushNamed(context, AppRoutes.leads);
          break;
        case 2: // Tasks
          Navigator.pushNamed(context, AppRoutes.tasks);
          break;
        case 3: // Notes
          Navigator.pushNamed(context, AppRoutes.notes);
          break;
        case 4: // Settings
          // Already on settings screen
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.settingsTitle),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to notifications screen
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.statusLost,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppTexts.profile,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppTexts.nameLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: AppTexts.emailLabel,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: settingsProvider.isLoading
                        ? null
                        : () {
                            _saveProfile(settingsProvider);
                          },
                    child: settingsProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(AppTexts.saveSettings),
                  ),
                ),
                if (settingsProvider.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      settingsProvider.errorMessage,
                      style: const TextStyle(color: AppColors.statusLost),
                    ),
                  ),
                const SizedBox(height: 32),
                const Text(
                  AppTexts.theme,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(AppTexts.darkMode),
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) {
                    settingsProvider.toggleDarkMode();
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 32),
                const Text(
                  AppTexts.notifications,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(AppTexts.enableNotifications),
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.toggleNotifications();
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 32),
                // Contact Support Section
                const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gray300.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCommunicationButton(
                        context: context,
                        icon: Icons.call,
                        label: 'Call',
                        color: AppColors.primary,
                        onTap: () => _launchCaller('+919876543210'),
                      ),
                      _buildCommunicationButton(
                        context: context,
                        icon: Icons.message,
                        label: 'WhatsApp',
                        color: Colors.green,
                        onTap: () => _launchWhatsApp('+919876543210',
                            'Hello, I need help with the NexLead app.'),
                      ),
                      _buildCommunicationButton(
                        context: context,
                        icon: Icons.email,
                        label: 'Email',
                        color: Colors.red,
                        onTap: () => _launchEmail(
                            'support@nexlead.com',
                            'Support Request',
                            'Hello, I need help with the NexLead app.'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle logout
                      _confirmLogout(context, authProvider);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.statusLost),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.statusLost),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildCommunicationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _launchCaller(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await launchUrl(launchUri)) {
        // Successfully launched
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching phone dialer: $e')),
      );
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    // Remove any non-digit characters from phone number
    String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Add country code 91 if not already present and number length suggests Indian number
    // Indian mobile numbers are 10 digits, so if we have 10 digits, add 91 prefix
    if (cleanPhoneNumber.length == 10) {
      cleanPhoneNumber = '91$cleanPhoneNumber';
    }

    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: cleanPhoneNumber,
      queryParameters: {'text': message},
    );
    try {
      if (await launchUrl(launchUri)) {
        // Successfully launched
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching WhatsApp: $e')),
      );
    }
  }

  Future<void> _launchEmail(String email, String subject, String body) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    try {
      if (await launchUrl(launchUri)) {
        // Successfully launched
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching email client: $e')),
      );
    }
  }

  Future<void> _saveProfile(SettingsProvider settingsProvider) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: AppColors.statusLost,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email cannot be empty'),
          backgroundColor: AppColors.statusLost,
        ),
      );
      return;
    }

    // Simple email validation
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.statusLost,
        ),
      );
      return;
    }

    try {
      await settingsProvider.updateProfile(
        _nameController.text.trim(),
        _emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.statusConverted,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: AppColors.statusLost,
        ),
      );
    }
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
                // Handle actual logout
                authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
