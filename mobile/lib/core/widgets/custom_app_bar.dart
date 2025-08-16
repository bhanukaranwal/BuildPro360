import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final bool automaticallyImplyLeading;
  final Widget? bottom;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.textColor,
    this.elevation = 4.0,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Theme.of(context).appBarTheme.foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom != null 
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: bottom!,
            ) 
          : null,
    );
  }
  
  @override
  Size get preferredSize => bottom != null 
      ? const Size.fromHeight(112.0) 
      : const Size.fromHeight(56.0);
}