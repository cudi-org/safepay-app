import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/constants/app_routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary, // Color Oscuro
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
           BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5)
           )
        ]
      ),
      padding: EdgeInsets.only(
          top: 8, bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () =>
                context.goNamed(AppRoutes.activityName), // Home (Activity)
          ),
          _NavBarItem(
            icon: Icons.cloud_queue_rounded, // Branding: Nube
            label: 'Bulut',
            isSelected: currentIndex == 1,
            onTap: () => context.goNamed(AppRoutes.chatName), // Bulut (Chat)
          ),
          _NavBarItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isSelected: currentIndex == 2,
            onTap: () => context
                .goNamed(AppRoutes.settingsName), // Settings (Placeholder)
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.disabled, // Verde agua si seleccionado
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.disabled,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}
