import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/theme/app_theme.dart';
import 'package:nextlead/core/utils/connection_test.dart';
import 'package:nextlead/core/utils/airtable_debug.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';
import 'package:nextlead/data/services/note_service.dart';
import 'package:nextlead/data/services/task_service.dart';
import 'package:nextlead/data/services/settings_service.dart';
import 'package:nextlead/data/services/user_service.dart';
import 'package:nextlead/data/services/notification_service.dart';
import 'package:nextlead/data/repositories/lead_repository.dart';
import 'package:nextlead/data/repositories/note_repository.dart';
import 'package:nextlead/data/repositories/task_repository.dart';
import 'package:nextlead/data/repositories/settings_repository.dart';
import 'package:nextlead/data/repositories/user_repository.dart';
import 'package:nextlead/data/repositories/notification_repository.dart';
import 'package:nextlead/providers/auth_provider.dart';
import 'package:nextlead/providers/lead_provider.dart';
import 'package:nextlead/providers/note_provider.dart';
import 'package:nextlead/providers/task_provider.dart';
import 'package:nextlead/providers/settings_provider.dart';
import 'package:nextlead/providers/notification_provider.dart';
import 'package:nextlead/routes/app_routes.dart';

void main() async {
  // Check Airtable configuration
  ConnectionTest.printConfigurationStatus();

  // Run Airtable debug test
  await AirtableDebug.testUsersTable();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);
    final noteService = NoteService(airtableService);
    final taskService = TaskService(airtableService);
    final settingsService = SettingsService(airtableService);
    final userService = UserService(airtableService);
    final notificationService = NotificationService();

    // Initialize repositories
    final leadRepository = LeadRepository(leadService);
    final noteRepository = NoteRepository(noteService);
    final taskRepository = TaskRepository(taskService);
    final settingsRepository = SettingsRepository(settingsService);
    final userRepository = UserRepository(userService);
    final notificationRepository = NotificationRepository(notificationService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => AuthProvider(userRepository)),
        ChangeNotifierProxyProvider<AuthProvider, LeadProvider>(
          create: (_) => LeadProvider(leadRepository),
          update: (context, authProvider, previousLeadProvider) {
            final leadProvider =
                previousLeadProvider ?? LeadProvider(leadRepository);
            // Set the current user ID when the auth provider changes
            leadProvider.setCurrentUserId(authProvider.currentUser?.id);
            return leadProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => NoteProvider(noteRepository)),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider(settingsRepository)),
        ChangeNotifierProvider(
            create: (_) => NotificationProvider(notificationRepository)),
      ],
      child: Consumer<AppTheme>(
        builder: (context, appTheme, _) {
          return MaterialApp(
            title: 'NexLead CRM',
            theme: appTheme.currentTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
