import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

/// Center-aligned text field used across the onboarding flow.
///
/// Wraps [TextField] with the project's input styling (border, hint color,
/// content padding, error styling) so individual step views only need to
/// pass in controller / hint / validation.
class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      textAlign: TextAlign.center,
      // === USER INPUT STYLE ===
      style: const TextStyle(
        fontFamily: 'Chivo',
        fontSize: 14,                // Matches Size: 14px
        fontWeight: FontWeight.w300, // Matches Weight: 300 / Light
        letterSpacing: 14 * 0.01,    // Matches Letter spacing: 1% (Font size * percentage)
        color: AppColors.ink,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        // === PLACEHOLDER HINT STYLE ===
        hintStyle: const TextStyle(
          fontFamily: 'Chivo',
          fontSize: 14,              // Matches Size: 14px
          fontWeight: FontWeight.w300, // Matches Weight: 300 / Light
          letterSpacing: 14 * 0.01,  // Matches Letter spacing: 1%
          color: AppColors.coolGray,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: _border(AppColors.coolGray.withValues(alpha: 0.55)),
        focusedBorder: _border(AppColors.primary),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: color, width: 0.8),
    );
  }
}
