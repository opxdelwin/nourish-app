import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'home_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Go to Profile'),
              ),
            ),
          );
        },
      ),
    );
  }
}



