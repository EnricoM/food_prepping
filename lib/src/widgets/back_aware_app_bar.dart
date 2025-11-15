import 'package:flutter/material.dart';

class BackAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAwareAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.backgroundColor,
    this.elevation,
  });

  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: canPop ? const BackButton() : null,
      automaticallyImplyLeading: !canPop,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

