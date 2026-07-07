import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/onboarding/onboarding_action_button.dart';
import '../onboarding_model.dart';

class OnboardingMacrosView extends StatelessWidget {
  const OnboardingMacrosView({
    super.key,
    required this.model,
    required this.onBack,
    required this.onNext,
  });

  final OnboardingViewModel model;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // REMOVED: padding from here
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  // ADDED: Padding widget wrapped around the Column
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 48, 18, 28),
                    child: Column(
                      children: [
                        const Text(
                          'Almost done!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'We have calculated optimal macros for you:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.charcoal,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'You can edit them if you like!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.charcoal,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 50),
                        _MacroField(
                          label: 'Calories',
                          suffix: 'kcal',
                          controller: model.caloriesController,
                        ),
                        const SizedBox(height: 38),
                        _MacroField(
                          label: 'Protein',
                          suffix: 'g',
                          controller: model.proteinController,
                        ),
                        const SizedBox(height: 38),
                        _MacroField(
                          label: 'Carbohydrates',
                          suffix: 'g',
                          controller: model.carbsController,
                        ),
                        const SizedBox(height: 38),
                        _MacroField(
                          label: 'Fats',
                          suffix: 'g',
                          controller: model.fatController,
                        ),
                        if (model.macroError != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            model.macroError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                        // Spacer will now correctly push the footer to the bottom
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: OnboardingActionButton(
                                label: 'Back',
                                variant: OnboardingActionVariant.outlined,
                                onPressed: onBack,
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              child: OnboardingActionButton(
                                label: 'Start',
                                icon: Icons.chevron_right,
                                onPressed: model.isSaving ? null : onNext,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({
    required this.label,
    required this.suffix,
    required this.controller,
  });

  final String label;
  final String suffix;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 282,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              widthFactor: 1,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.coolGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 128,
            maxWidth: 128,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Align(
              widthFactor: 1,
              alignment: Alignment.centerRight,
              child: Text(
                suffix,
                style: const TextStyle(
                  color: AppColors.charcoal,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxWidth: 48,
          ),
          hintText: '0',
          hintStyle: const TextStyle(
            color: AppColors.coolGray,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          contentPadding: const EdgeInsets.only(top: 13, bottom: 13),
          enabledBorder: _border(AppColors.coolGray.withValues(alpha: 0.65)),
          focusedBorder: _border(AppColors.primary),
        ),
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
