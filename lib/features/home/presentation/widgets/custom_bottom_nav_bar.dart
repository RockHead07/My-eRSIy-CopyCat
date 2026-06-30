import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';

enum BottomNavItem { home, janjiTemu, riwayat, profil }

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final BottomNavItem current;
  final ValueChanged<BottomNavItem> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.s(context, AppSpacing.bottomNavHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              label: 'Home',
              icon: Icons.home_rounded,
              active: current == BottomNavItem.home,
              onTap: () => onChanged(BottomNavItem.home),
            ),
            _NavItem(
              label: 'Janji Temu',
              icon: Icons.calendar_today_outlined,
              active: current == BottomNavItem.janjiTemu,
              onTap: () => onChanged(BottomNavItem.janjiTemu),
            ),
            _NavItem(
              label: 'Riwayat',
              icon: Icons.history,
              active: current == BottomNavItem.riwayat,
              onTap: () => onChanged(BottomNavItem.riwayat),
            ),
            _NavItem(
              label: 'Profil',
              icon: Icons.person_outline,
              active: current == BottomNavItem.profil,
              onTap: () => onChanged(BottomNavItem.profil),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.brandGreenDark : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s(context, 6),
            vertical: AppSpacing.s(context, 8),
          ),
          child: active
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s(context, 14),
                    vertical: AppSpacing.s(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pillMintBg,
                    borderRadius: BorderRadius.circular(AppSpacing.s(context, 24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: AppSpacing.s(context, 22)),
                      SizedBox(height: AppSpacing.s(context, 2)),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: AppSpacing.s(context, 10),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: AppSpacing.s(context, 22)),
                    SizedBox(height: AppSpacing.s(context, 2)),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: AppSpacing.s(context, 10),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
