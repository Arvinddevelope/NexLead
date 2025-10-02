import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/validators.dart';
import 'package:nextlead/providers/auth_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isCheckingUser = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _checkUserAndRedirect() async {
    if (_emailController.text.isEmpty) return;

    // Validate email format first
    final emailError = Validators.validateEmail(_emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: AppColors.statusLost,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingUser = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if user exists
      final userExists =
          await authProvider.userExists(_emailController.text.trim());

      if (userExists) {
        // User exists, proceed with login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User found. Please enter your password to login.'),
              backgroundColor: AppColors.statusConverted,
            ),
          );
        }
      } else {
        // User doesn't exist, redirect to signup
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New user detected. Redirecting to signup...'),
              backgroundColor: AppColors.primary,
            ),
          );

          // Delay slightly to show the message before redirecting
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushNamed(context, AppRoutes.signup);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking user: ${e.toString()}'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
    } finally {
      setState(() {
        _isCheckingUser = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Navigate to dashboard on successful login
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.statusLost,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // App Logo/Title
                const Icon(
                  Icons.account_circle,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                const Text(
                  AppTexts.loginTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  AppTexts.loginSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppTexts.emailLabel,
                    prefixIcon: const Icon(Icons.email),
                    suffixIcon: _isCheckingUser
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    // Auto-check user when email is entered
                    if (value.length > 5 && value.contains('@')) {
                      // Debounce the check
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted && _emailController.text == value) {
                          _checkUserAndRedirect();
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppTexts.passwordLabel,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: Validators.validatePassword,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: const Text(AppTexts.forgotPassword),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppTexts.loginButton,
                      onPressed: authProvider.isLoading || _isCheckingUser
                          ? () {}
                          : _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppTexts.noAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: const Text(AppTexts.signupNow),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
