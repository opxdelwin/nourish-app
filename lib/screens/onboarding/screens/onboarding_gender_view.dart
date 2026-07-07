import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/onboarding/onboarding_action_button.dart';
import '../../../widgets/onboarding/onboarding_step_scaffold.dart';
import '../onboarding_model.dart';

class OnboardingGenderView extends StatelessWidget {
  const OnboardingGenderView({
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
    return OnboardingStepScaffold(
      question: 'What do you identify as?',
      field: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GenderGrid(model: model),
          if (model.genderError != null) ...[
            const SizedBox(height: 12),
            Text(
              model.genderError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OnboardingActionButton(
              label: 'Back',
              variant: OnboardingActionVariant.outlined,
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: OnboardingActionButton(
              label: 'Next',
              onPressed: model.isSaving ? null : onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderGrid extends StatelessWidget {
  const _GenderGrid({required this.model});

  final OnboardingViewModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Wrap(
        spacing: 38,
        runSpacing: 22,
        children: [
          _GenderOption(value: 'male', label: 'Male', model: model),
          _GenderOption(value: 'female', label: 'Female', model: model),
          _GenderOption(value: 'others', label: 'Others', model: model),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.value,
    required this.label,
    required this.model,
  });

  final String value;
  final String label;
  final OnboardingViewModel model;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => model.selectGender(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            // ignore: deprecated_member_use
            groupValue: model.selectedGender,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value == null) return;
              model.selectGender(value);
            },
            activeColor: AppColors.primaryLight,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.charcoal,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
