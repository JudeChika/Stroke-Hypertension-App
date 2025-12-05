import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';

/// AuthGate listens to the auth state and returns the right root screen.
/// Use this as the MaterialApp home so the app resumes to the Dashboard when signed in.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      data: (user) {
        if (user != null) {
          // User is signed in — send to dashboard
          return const DashboardScreen();
        } else {
          // Not signed in — show login screen
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) {
        // In case of error, show login screen but log error if you want.
        debugPrint('Auth stream error: $err');
        return const LoginScreen();
      },
    );
  }
}