import 'package:flutter/material.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/validators.dart';
import 'package:nextlead/ui/widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call for password reset
        await Future.delayed(const Duration(seconds: 2));

        // Show success message
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });

        // Navigate back to login after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

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
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Icon
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Enter your email and we\'ll send you a link to reset your password',
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
                  decoration: const InputDecoration(
                    labelText: AppTexts.emailLabel,
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // Reset Button
                CustomButton(
                  text: 'Reset Password',
                  onPressed: _isLoading ? () {} : _handleResetPassword,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                // Success Message
                if (_isSuccess)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.statusConverted.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusConverted),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.statusConverted,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Password reset link sent! Please check your email.',
                            style: TextStyle(
                              color: AppColors.statusConverted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
