import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const designWidth = 402.0;
  static const pageHorizontal = 17.0;
  static const headerHeight = 215.0;
  static const bannerHeight = 200.0;
  static const bottomNavHeight = 80.0;

  static double scale(BuildContext context) =>
      MediaQuery.sizeOf(context).width / designWidth;

  static double s(BuildContext context, double designPx) =>
      designPx * scale(context);
}
