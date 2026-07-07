import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. ADDED THIS IMPORT

import 'router.dart';
import 'providers.dart';
import 'providers/theme_provider.dart';
import 'providers/shared_preferences_provider.dart';
import 'theme/app_colors.dart';

// === UNIFIED IMPORTS ===
import 'backend/db_service.dart';
import 'backend/hive_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  // === UNIFIED DATABASE INITIALIZATION ===
  await DbService.instance.init();
  await HiveService.init();
  // -------------------------------------

  // Preload SharedPreferencesProvider to avoid flicker and ensure availability
  final sharedPrefsProvider = SharedPreferencesProvider();
  await sharedPrefsProvider.loadSettings();

  final rawPrefs = await SharedPreferences.getInstance();
  final isFirstLaunch = rawPrefs.getBool('isFirstLaunch') ?? true;

  // 2. CREATE THE ROUTER HERE (Only happens exactly once on startup)
  final appRouter = createRouter(isFirstLaunch);

  // 3. PASS THE ROUTER TO THE APP (Instead of the boolean)
  runApp(MyApp(prefs: sharedPrefsProvider, router: appRouter));
}

class MyApp extends StatelessWidget {
  final SharedPreferencesProvider prefs;
  final GoRouter router;
  const MyApp({super.key, required this.prefs,required this.router});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      config: const ToastificationConfig(
        alignment: Alignment.bottomCenter,
        maxToastLimit: 1,
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<SharedPreferencesProvider>.value(value: prefs),
          ...providers, // Auth, Db, Theme (proxy)
        ],
        child: Consumer2<SharedPreferencesProvider, ThemeProvider>(
          builder: (context, sp, theme, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Nourish App',
              themeMode: theme.themeMode,
              theme: ThemeData.light().copyWith(
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              ),
              darkTheme: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  brightness: Brightness.dark,
                ),
              ),

              locale: Locale(
                ['en'].contains(sp.preferredLanguage)
                    ? sp.preferredLanguage
                    : 'en',
              ),
              supportedLocales: const [Locale('en')],

              // <-- 3. FIXED THIS: Kept only the dynamic router and removed the duplicate
              routerConfig: router,
              builder: (context, child) => child!,
            );
          },
        ),
      ),
    );
  }
}