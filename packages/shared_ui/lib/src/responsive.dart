import 'package:flutter/widgets.dart';

EdgeInsets responsivePageInsets(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final horizontal = width < 360
      ? 12.0
      : width < 480
          ? 16.0
          : width < 720
              ? 20.0
              : 24.0;
  final vertical = width < 360 ? 12.0 : 24.0;
  return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
}
