import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import '/auth/supabase_auth/auth_util.dart';

class ForgotPasswordWidgetNew extends StatefulWidget {
  const ForgotPasswordWidgetNew({super.key});

  @override
  State<ForgotPasswordWidgetNew> createState() =>
      _ForgotPasswordWidgetNewState();
}

class _ForgotPasswordWidgetNewState extends State<ForgotPasswordWidgetNew> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await authManager.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                ),
        ),
        child: SafeArea(
          child:
              _emailSent ? _buildSuccessView(isDark) : _buildFormView(isDark),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.space24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ).animate().fadeIn(duration: 300.ms),

            SizedBox(height: AppTheme.space48),

            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowShadow,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 50,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOut),

            SizedBox(height: AppTheme.space32),

            // Title
            Text(
              'Forgot Password?',
              style: AppTheme.displayLarge.copyWith(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            SizedBox(height: AppTheme.space16),

            // Description
            Text(
              'No worries! Enter your email address and we\'ll send you a link to reset your password.',
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

            SizedBox(height: AppTheme.space48),

            // Email Field
            ModernTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

            SizedBox(height: AppTheme.space32),

            // Send Reset Link Button
            ModernButton(
              text: 'Send Reset Link',
              onPressed: _isLoading ? null : _sendResetEmail,
              isLoading: _isLoading,
              icon: Icons.send,
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            SizedBox(height: AppTheme.space24),

            // Back to Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: Colors.grey,
                ),
                SizedBox(width: AppTheme.space8),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back to Sign In',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.harmonyOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D084), Color(0xFF1DB954)],
              ),
              shape: BoxShape.circle,
              boxShadow: AppTheme.glowShadow,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOut),

          SizedBox(height: AppTheme.space32),

          // Title
          Text(
            'Check Your Email',
            style: AppTheme.displayLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

          SizedBox(height: AppTheme.space16),

          // Message
          Text(
            'We\'ve sent a password reset link to',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          SizedBox(height: AppTheme.space8),

          Text(
            _emailController.text,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.harmonyOrange,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),

          SizedBox(height: AppTheme.space48),

          // Info Card
          Container(
            padding: EdgeInsets.all(AppTheme.space20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withOpacity(0.3)
                  : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.harmonyOrange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.harmonyOrange,
                  size: 32,
                ),
                SizedBox(height: AppTheme.space12),
                Text(
                  'Didn\'t receive the email?',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppTheme.space8),
                Text(
                  'Check your spam folder or try resending the link.',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

          SizedBox(height: AppTheme.space32),

          // Resend Button
          ModernButton(
            text: 'Resend Email',
            onPressed: () {
              setState(() => _emailSent = false);
            },
            isOutline: true,
            icon: Icons.refresh,
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .scale(begin: const Offset(0.9, 0.9)),

          SizedBox(height: AppTheme.space16),

          // Back to Login Button
          ModernButton(
            text: 'Back to Sign In',
            onPressed: () {
              Navigator.pop(context);
            },
            isOutline: true,
          )
              .animate()
              .fadeIn(delay: 700.ms)
              .scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }
}
