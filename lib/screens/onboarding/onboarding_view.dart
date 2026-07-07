import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/db_provider.dart';
import 'onboarding_model.dart';
import 'screens/onboarding_activity_view.dart';
import 'screens/onboarding_age_view.dart';
import 'screens/onboarding_body_metrics_view.dart';
import 'screens/onboarding_gender_view.dart';
import 'screens/onboarding_macros_view.dart';
import 'screens/onboarding_name_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: const _OnboardingFlow(),
    );
  }
}

class _OnboardingFlow extends StatefulWidget {
  const _OnboardingFlow();

  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<OnboardingViewModel>().loadExistingProfile(
        context.read<DbProvider>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OnboardingViewModel>();
    final dbProvider = context.read<DbProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (model.currentStep > 0) {
          model.previousStep();
        } else {
          context.go('/landing');
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
      child: switch (model.currentStep) {
        0 => OnboardingNameView(
          key: const ValueKey('onboarding_name'),
          controller: model.nameController,
          errorText: model.nameError,
          isSaving: model.isSaving,
          onNext: () async {
            await model.saveName(dbProvider);
          },
        ),
        1 => OnboardingAgeView(
          key: const ValueKey('onboarding_age'),
          model: model,
          onBack: model.previousStep,
          onNext: () async {
            await model.saveAge(dbProvider);
          },
        ),
        2 => OnboardingGenderView(
          key: const ValueKey('onboarding_gender'),
          model: model,
          onBack: model.previousStep,
          onNext: () async {
            await model.saveGender(dbProvider);
          },
        ),
        3 => OnboardingBodyMetricsView(
          key: const ValueKey('onboarding_body_metrics'),
          model: model,
          onBack: model.previousStep,
          onNext: () async {
            FocusScope.of(context).unfocus();
            await model.saveBodyMetrics(dbProvider);
          },
        ),
        4 => OnboardingActivityView(
          key: const ValueKey('onboarding_activity'),
          model: model,
          onBack: model.previousStep,
          onNext: () async {
            await model.saveActivity(dbProvider);
          },
        ),
        _ => OnboardingMacrosView(
          key: const ValueKey('onboarding_macros'),
          model: model,
          onBack: model.previousStep,
          onNext: () async {
            final saved = await model.saveMacroGoals(dbProvider);
            if (!context.mounted || !saved) return;

            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isFirstLaunch', false);

            // Re-check mounted after the async await just to be safe
            if (!context.mounted) return;

            context.go('/home');
          },
        ),
      },
    ),);
  }
}
