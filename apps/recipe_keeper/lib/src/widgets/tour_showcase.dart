import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class TourShowcase extends StatelessWidget {
  const TourShowcase({
    super.key,
    required this.globalKey,
    required this.title,
    required this.description,
    required this.child,
    this.shapeBorder,
    this.onTargetClick,
  });

  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final ShapeBorder? shapeBorder;
  final VoidCallback? onTargetClick;

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: globalKey,
      title: title,
      description: description,
      targetShapeBorder: shapeBorder ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      overlayOpacity: 0.75,
      tooltipBackgroundColor: Theme.of(context).colorScheme.surface,
      textColor: Theme.of(context).colorScheme.onSurface,
      // descTextColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      descTextStyle: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      onTargetClick: onTargetClick,
      child: child,
    );
  }
}



