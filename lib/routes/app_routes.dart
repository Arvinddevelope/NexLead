import 'package:flutter/material.dart';
import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/models/task_model.dart';
import 'package:nextlead/ui/screens/auth/login_screen.dart';
import 'package:nextlead/ui/screens/auth/signup_screen.dart';
import 'package:nextlead/ui/screens/auth/forgot_password_screen.dart';
import 'package:nextlead/ui/screens/dashboard/dashboard_screen.dart';
import 'package:nextlead/ui/screens/leads/lead_list_screen.dart';
import 'package:nextlead/ui/screens/leads/lead_detail_screen.dart';
import 'package:nextlead/ui/screens/leads/lead_form_screen.dart';
import 'package:nextlead/ui/screens/tasks/task_list_screen.dart';
import 'package:nextlead/ui/screens/tasks/task_form_screen.dart';
import 'package:nextlead/ui/screens/notes/note_list_screen.dart';
import 'package:nextlead/ui/screens/notifications/notification_screen.dart';
import 'package:nextlead/ui/screens/settings/settings_screen.dart';
import 'package:nextlead/ui/screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String leads = '/leads';
  static const String leadDetail = '/lead-detail';
  static const String leadForm = '/lead-form';
  static const String tasks = '/tasks';
  static const String taskForm = '/task-form';
  static const String notes = '/notes';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case leads:
        return MaterialPageRoute(builder: (_) => const LeadListScreen());
      case leadDetail:
        final args = routeSettings.arguments as Lead;
        return MaterialPageRoute(
          builder: (_) => LeadDetailScreen(lead: args),
        );
      case leadForm:
        final args = routeSettings.arguments as Lead?;
        return MaterialPageRoute(
          builder: (_) => LeadFormScreen(lead: args),
        );
      case tasks:
        return MaterialPageRoute(builder: (_) => const TaskListScreen());
      case taskForm:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final task = args['task'] as Task?;
        final leadId = args['leadId'] as String;
        return MaterialPageRoute(
          builder: (_) => TaskFormScreen(task: task, leadId: leadId),
        );
      case notes:
        return MaterialPageRoute(builder: (_) => const NoteListScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}
