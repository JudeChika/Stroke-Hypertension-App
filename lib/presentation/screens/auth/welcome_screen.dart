import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stroke_hypertension_app/presentation/screens/auth/signup_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import 'login_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient decoration (Sleek touch)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ).animate().scale(duration: 1000.ms, curve: Curves.easeOut),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Theme Toggle (Top Right) ---
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: AppTheme.primaryGreen,
                      ),
                      onPressed: () {
                        // Toggle Logic
                        ref.read(themeProvider.notifier).toggleTheme(!isDarkMode);
                      },
                    ),
                  ),

                  const Spacer(flex: 1),

                  // --- Hero Image / Logo Area ---
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreenLight.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.monitor_heart_outlined,
                        size: 80,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms),

                  const SizedBox(height: 40),

                  // --- Title & Description ---
                  Text(
                    "Health First",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  Text(
                    "Monitor your blood pressure and detect stroke risks early with AI-powered precision.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ).animate().fadeIn(delay: 400.ms),

                  const Spacer(flex: 2),

                  // --- Buttons ---
                  // 1. Sign Up (Primary - Yellow for Action)
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Sign Up Screen
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryYellow, // Yellow
                      foregroundColor: AppTheme.textBlack, // Black text on Yellow
                    ),
                    child: const Text("Create Account"),
                  ).animate().slideY(begin: 1.0, delay: 500.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 16),

                  // 2. Login (Secondary - Outlined/Green)
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to Login Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: const Text("Login"),
                  ).animate().slideY(begin: 1.0, delay: 600.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}