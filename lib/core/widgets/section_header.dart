import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSpacing.s(context, 36),
          height: AppSpacing.s(context, 36),
          decoration: BoxDecoration(
            color: AppColors.pillMintBg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon ?? Icons.grid_view_rounded,
            color: AppColors.brandGreenDark,
            size: AppSpacing.s(context, 20),
          ),
        ),
        SizedBox(width: AppSpacing.s(context, 10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSpacing.s(context, 16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandGreenDark,
                ),
              ),
              SizedBox(height: AppSpacing.s(context, 2)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppSpacing.s(context, 11),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailingWidget != null) trailingWidget,
      ],
    );
  }
}
