import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final bool fullScreen;
  
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 36.0,
    this.color,
    this.backgroundColor,
    this.backgroundOpacity = 0.7,
    this.fullScreen = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final indicatorWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color ?? Theme.of(context).primaryColor,
            strokeWidth: 3.0,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color ?? Theme.of(context).primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
    
    if (fullScreen) {
      return Container(
        color: (backgroundColor ?? Colors.black).withOpacity(backgroundOpacity),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: indicatorWidget,
          ),
        ),
      );
    }
    
    return Center(child: indicatorWidget);
  }
  
  // Static method to show a full-screen loading dialog
  static Future<void> show(BuildContext context, {String? message}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingIndicator(
        message: message,
        fullScreen: true,
      ),
    );
  }
  
  // Static method to hide the loading dialog
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}