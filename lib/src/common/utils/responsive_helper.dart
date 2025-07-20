// lib/src/common/utils/responsive_helper.dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 840;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= 840;
}