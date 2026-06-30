import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/features/home/data/models/menu_item_model.dart';

class MenuGridItem extends StatelessWidget {
  const MenuGridItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MenuItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = AppSpacing.s(context, 52);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.s(context, 12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Image.asset(
              item.iconAsset,
              fit: BoxFit.contain,
              // ponytail: swap PNGs into assets/icons/menu/ — fallback keeps grid working without art
              errorBuilder: (context, error, stackTrace) => Icon(
                item.fallbackIcon ?? Icons.apps,
                size: iconSize * 0.72,
                color: AppColors.brandGreenDark,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s(context, 8)),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppSpacing.s(context, 10),
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
