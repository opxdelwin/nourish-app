import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/onboarding/onboarding_action_button.dart';
import '../../../widgets/onboarding/onboarding_step_scaffold.dart';
import '../onboarding_model.dart';

class OnboardingActivityView extends StatefulWidget {
  const OnboardingActivityView({
    super.key,
    required this.model,
    required this.onBack,
    required this.onNext,
  });

  final OnboardingViewModel model;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  State<OnboardingActivityView> createState() => _OnboardingActivityViewState();
}

class _OnboardingActivityViewState extends State<OnboardingActivityView> {
  late String? selectedActivity = widget.model.selectedActivity;

  @override
  Widget build(BuildContext context) {
    final isActivitySelected = selectedActivity != null;

    return OnboardingStepScaffold(
      question: 'How active are you?',
      field: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ActivityOptions(
            model: widget.model,
            onActivitySelected: (activity) {
              setState(() {
                selectedActivity = activity;
              });
            },
          ),
          if (widget.model.activityError != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.model.activityError!,
              textAlign: TextAlign.center,
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
              onPressed: widget.onBack,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: OnboardingActionButton(
              label: 'Next',
              onPressed:
                  widget.model.isSaving || !isActivitySelected
                      ? null
                      : widget.onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityOptions extends StatefulWidget {
  const _ActivityOptions({
    required this.model,
    required this.onActivitySelected,
  });

  final OnboardingViewModel model;
  final Function(String) onActivitySelected;

  @override
  State<_ActivityOptions> createState() => _ActivityOptionsState();
}

class _ActivityOptionsState extends State<_ActivityOptions> {
  late String? selectedActivity = widget.model.selectedActivity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          _activityOptions.entries.map((entry) {
            final isSelected = selectedActivity == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedActivity = entry.key;
                });
                widget.model.selectActivity(entry.key);
                widget.onActivitySelected(entry.key);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.lavenderMist,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.value['title']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value['description']!,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.mutedGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

const Map<String, Map<String, dynamic>>
_activityOptions = <String, Map<String, dynamic>>{
  'sedentary': {'title': 'Sedentary', 'description': 'Little to no exercise'},
  'light': {'title': 'Light Exercise', 'description': '1-3 times a week'},
  'moderate': {'title': 'Moderate Exercise', 'description': '4-5 times a week'},
  'intense': {'title': 'Intense Exercise', 'description': '6-7 times a week'},
  'very_intense': {
    'title': 'Very Intense Exercise',
    'description': 'Daily exercise, physical job, athlete',
  },
};
