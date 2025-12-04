import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Wrap the entire app in ProviderScope for Riverpod to work
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider for changes
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Stroke & Hypertension Detector',
      debugShowCheckedModeBanner: false,

      // --- Theme Configuration ---
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentThemeMode, // Dynamic switching happens here

      // --- Entry Point ---
      home: const WelcomeScreen(),
    );
  }
}
