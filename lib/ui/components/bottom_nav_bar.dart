import 'package:flutter/material.dart';
import 'package:nextlead/core/constants/app_texts.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: AppTexts.dashboardTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: AppTexts.leadsTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_outlined),
          activeIcon: Icon(Icons.task),
          label: AppTexts.tasksTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note_outlined),
          activeIcon: Icon(Icons.note),
          label: AppTexts.notesTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: AppTexts.settingsTitle,
        ),
      ],
    );
  }
}
