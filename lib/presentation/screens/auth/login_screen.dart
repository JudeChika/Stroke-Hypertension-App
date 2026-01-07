import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for AutofillHints
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stroke_hypertension_app/presentation/screens/auth/signup_screen.dart';
import 'package:stroke_hypertension_app/presentation/screens/auth/forgot_password_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  // Add optional parameters to receive data from SignUpScreen
  final String? initialEmail;
  final String? initialPassword;

  const LoginScreen({
    super.key,
    this.initialEmail,
    this.initialPassword
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize with passed values or empty string
    _emailController = TextEditingController(text: widget.initialEmail);
    _passwordController = TextEditingController(text: widget.initialPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Save form to trigger autofill save on success
      TextInput.finishAutofillContext();

      setState(() => _isLoading = true);

      try {
        await ref.read(authRepositoryProvider).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Navigation handled by AuthGate usually, but providing feedback/fallback here
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // --- 1. Header (Same as before) ---
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.35,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_person_outlined, size: 60, color: Colors.white)
                            .animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 10),
                        Text(
                          "Welcome Back",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // --- 2. Form Card with Autofill ---
              Positioned(
                top: size.height * 0.28,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    // Wrap in AutofillGroup to enable OS password managers
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Sign In",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            // Add Autofill Hint
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                            ),
                            validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email' : null,
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            // Add Autofill Hint
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.key_outlined, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                            validator: (value) => (value == null || value.length < 6) ? 'Password must be 6+ characters' : null,
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                              },
                              child: const Text("Forgot Password?", style: TextStyle(color: AppTheme.textGrey)),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryYellow,
                                foregroundColor: AppTheme.textBlack,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: AppTheme.textBlack)
                                  : const Text("LOGIN"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
              ),

              // --- 3. Footer ---
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                      },
                      child: const Text("Sign Up", style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}