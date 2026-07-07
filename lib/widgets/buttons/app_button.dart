import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum ButtonVariant { primary, outlined, secondary }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;
  final double borderRadius;
  final String loadingMessage;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.borderRadius = 10.0,
    this.loadingMessage = "Please wait",
  });

  @override
  Widget build(BuildContext context) {
    return _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    final Widget childWidget = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (variant != ButtonVariant.primary && icon != null) ...[
                Icon(icon, size: 20),
                SizedBox(width: 10),
              ],
              Text(label),
              if (variant == ButtonVariant.primary && icon != null) ...[
                SizedBox(width: 10),
                Icon(icon, size: 20),
              ],
            ],
          );

    final onPressedHandler = isLoading
        ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loadingMessage)),
            );
          }
        : onPressed;

    switch (variant) {
      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressedHandler,
          style: _getButtonStyle(),
          child: childWidget,
        );
      case ButtonVariant.secondary:
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressedHandler,
          style: _getButtonStyle(),
          child: childWidget,
        );
    }
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      case ButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
    }
  }
}
