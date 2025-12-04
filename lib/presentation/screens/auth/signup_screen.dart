import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import 'login_screen.dart'; // Navigate here after signup

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FIXED: Sign Up Logic with Navigation to Login ---
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Call the Repository via Riverpod
        await ref.read(authRepositoryProvider).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Account created successfully! Please login.'),
              backgroundColor: AppTheme.primaryGreen,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to Login Screen (replacing current screen)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        // Show Error SnackBar with detailed message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
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
              // --- 1. The Green Curved Header ---
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.30,
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
                        const Icon(Icons.person_add_alt_1_outlined, size: 50, color: Colors.white)
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 10),
                        Text(
                          "Join Health First",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 2. The Back Button (Top Left) ---
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // --- 3. The Form Card ---
              Positioned(
                top: size.height * 0.24,
                left: 20,
                right: 20,
                bottom: 20,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Create Account",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),

                          // --- Full Name ---
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primaryGreen),
                            ),
                            validator: (value) =>
                            value != null && value.trim().isNotEmpty ? null : 'Name is required',
                          ).animate().slideX(begin: -0.2, duration: 300.ms),

                          const SizedBox(height: 15),

                          // --- Email ---
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ).animate().slideX(begin: -0.2, delay: 100.ms, duration: 300.ms),

                          const SizedBox(height: 15),

                          // --- Password ---
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ).animate().slideX(begin: -0.2, delay: 200.ms, duration: 300.ms),

                          const SizedBox(height: 15),

                          // --- Confirm Password ---
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ).animate().slideX(begin: -0.2, delay: 300.ms, duration: 300.ms),

                          const SizedBox(height: 30),

                          // --- Sign Up Button ---
                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryYellow,
                                foregroundColor: AppTheme.textBlack,
                              ),
                              child: _isLoading
                                  ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.textBlack,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text("CREATING ACCOUNT..."),
                                ],
                              )
                                  : const Text("REGISTER"),
                            ),
                          ).animate().slideY(begin: 0.5, delay: 400.ms, curve: Curves.easeOut),

                          const SizedBox(height: 20),

                          // --- Footer Link to Login ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already a member? "),
                              GestureDetector(
                                onTap: _isLoading ? null : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: _isLoading ? Colors.grey : AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}