import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/widgets/section_header.dart';
import 'package:rs_islam_app/features/home/data/models/menu_item_model.dart';
import 'package:rs_islam_app/features/home/presentation/navigation/menu_navigator.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/menu_grid_item.dart';

class MenuLayananSection extends StatelessWidget {
  const MenuLayananSection({super.key, required this.items});

  final List<MenuItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s(context, AppSpacing.pageHorizontal),
      ),
      child: Column(
        children: [
          const SectionHeader(
            title: 'Menu Layanan',
            subtitle: 'Akses layanan rumah sakit dengan mudah',
            icon: Icons.apps_rounded,
          ),
          SizedBox(height: AppSpacing.s(context, 18)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.s(context, 20),
              crossAxisSpacing: AppSpacing.s(context, 8),
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return MenuGridItem(
                item: item,
                onTap: () => MenuNavigator.handle(context, item),
              );
            },
          ),
        ],
      ),
    );
  }
}
