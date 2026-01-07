import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for AutofillHints
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import 'login_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      // 1. Prompt the device to save these credentials
      TextInput.finishAutofillContext();

      setState(() => _isLoading = true);

      try {
        await ref.read(authRepositoryProvider).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account Created! Please Login."), backgroundColor: Colors.green),
          );

          // 2. PASS CREDENTIALS to LoginScreen for "Easy Login"
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                initialEmail: _emailController.text.trim(),
                initialPassword: _passwordController.text.trim(),
              ),
            ),
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
              // Header
              Positioned(
                top: 0, left: 0, right: 0, height: size.height * 0.35,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add_outlined, size: 60, color: Colors.white)
                            .animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 10),
                        Text("Create Account", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white))
                            .animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 50, left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Form
              Positioned(
                top: size.height * 0.28, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Form(
                    key: _formKey,
                    // Enable Autofill Saving
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Sign Up", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _nameController,
                            autofillHints: const [AutofillHints.name], // Hint
                            decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryGreen)),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter full name' : null,
                          ),
                          const SizedBox(height: 15),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.newUsername], // "New" username hint
                            decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen)),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                          ),
                          const SizedBox(height: 15),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            autofillHints: const [AutofillHints.newPassword], // "New" password hint
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                          ),
                          const SizedBox(height: 15),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                              ),
                            ),
                            validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryYellow, foregroundColor: AppTheme.textBlack),
                              child: _isLoading ? const CircularProgressIndicator(color: AppTheme.textBlack) : const Text("SIGN UP"),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already a member? "),
                              GestureDetector(
                                onTap: _isLoading ? null : () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                },
                                child: Text("Login", style: TextStyle(color: _isLoading ? Colors.grey : AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
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