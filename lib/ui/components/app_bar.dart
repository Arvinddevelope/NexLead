import 'package:flutter/material.dart';
import 'package:nextlead/core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showDrawerButton;
  final VoidCallback? onDrawerPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showDrawerButton = false,
    this.onDrawerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: showDrawerButton
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onDrawerPressed,
            )
          : null,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
