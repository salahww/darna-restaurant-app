import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/auth/presentation/screens/role_based_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:darna/l10n/app_localizations.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/order/presentation/providers/location_provider.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Load environment variables
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        debugPrint('Failed to load .env file: $e');
      }

      // UI Overlay Style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      // Orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Firebase Initialization
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('Firebase initialized successfully');

        // App Check Debug Provider
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        
        // Initialize Notifications
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        await NotificationService().initialize();
        debugPrint('✅ Notifications initialized');
      } catch (e) {
        debugPrint('Firebase initialization failed: $e');
      }

      runApp(
        const ProviderScope(
          child: DarnaApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught Error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

// ... (imports)

/// Main application widget
class DarnaApp extends ConsumerStatefulWidget {
  const DarnaApp({super.key});

  @override
  ConsumerState<DarnaApp> createState() => _DarnaAppState();
}

class _DarnaAppState extends ConsumerState<DarnaApp> {
  @override
  void initState() {
    super.initState();
    // Initialize location provider ONCE after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(locationProvider.notifier).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Darna',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      
      // Localization
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Router configuration
      routerConfig: appRouter,
    );
  }
}

