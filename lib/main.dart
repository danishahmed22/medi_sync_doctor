import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisync_doctor/core/router/app_router.dart';
import 'package:medisync_doctor/core/theme/app_theme.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';

// IMPORTANT: Once you run 'flutterfire configure', uncomment the next line:
import 'package:medisync_doctor/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style for dark theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF060D1F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    // Initialise Firebase.
    // If you have NOT run 'flutterfire configure' yet, it will look for 
    // google-services.json (Android) or GoogleService-Info.plist (iOS).
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Uncomment after running flutterfire configure
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // For a clinical app, we'd ideally show a 'Maintenance' or 'Connection Error' screen 
    // if Firebase is required for the app to function at all.
  }

  // Initialise SharedPreferences once and inject via ProviderScope.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MediSyncApp(),
    ),
  );
}

class MediSyncApp extends ConsumerWidget {
  const MediSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MediSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
