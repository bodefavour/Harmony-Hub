import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_model.dart';
export 'login_model.dart';

/// Modern Login Screen - Spotify/Apple Music inspired
/// Features: Clean design, smooth animations, social login options
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());
    _model.emailTextController ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.passwordTextController ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'login'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    logFirebaseEvent('LOGIN_email_password_signin');

    GoRouter.of(context).prepareAuthEvent();

    final user = await authManager.signInWithEmail(
      email: _model.emailTextController.text,
      password: _model.passwordTextController.text,
    );

    setState(() => _isLoading = false);

    if (user == null) {
      return;
    }

    context.goNamedAuth('homePage', context.mounted);
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);
    logFirebaseEvent('LOGIN_${provider}_signin');

    GoRouter.of(context).prepareAuthEvent();

    final success = await authManager.signInWithGoogle();

    setState(() => _isLoading = false);

    if (success) {
      context.goNamedAuth('homePage', context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.darkBackground,
                    const Color(0xFF1a1a1a),
                    AppTheme.harmonyOrange.withOpacity(0.05),
                  ]
                : [
                    AppTheme.lightBackground,
                    const Color(0xFFf0f0f0),
                    AppTheme.harmonyOrange.withOpacity(0.03),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimaryLight,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.3, end: 0, duration: 300.ms),

                  const SizedBox(height: AppTheme.space32),

                  // Header
                  Text(
                    'Welcome back',
                    style: AppTheme.displayLarge.copyWith(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimaryLight,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: -0.2, end: 0, duration: 400.ms),

                  const SizedBox(height: AppTheme.space8),

                  Text(
                    'Sign in to continue to Harmony Hub',
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondaryLight,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: -0.2, end: 0, duration: 400.ms),

                  const SizedBox(height: AppTheme.space48),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        ModernTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _model.emailTextController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 300.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: AppTheme.space20),

                        // Password Field
                        ModernTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _model.passwordTextController,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark
                                  ? AppTheme.textSecondary
                                  : AppTheme.textSecondaryLight,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: AppTheme.space16),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.pushNamed('forgotPassword');
                            },
                            child: Text(
                              'Forgot password?',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.harmonyOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                        const SizedBox(height: AppTheme.space32),

                        // Login Button
                        ModernButton(
                          text: 'Sign In',
                          onPressed: _isLoading ? null : _handleLogin,
                          isLoading: _isLoading,
                          icon: Icons.login_rounded,
                          width: double.infinity,
                          useGradient: true,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 600.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                            ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.space32),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? AppTheme.textTertiary
                              : AppTheme.textTertiaryLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space16,
                        ),
                        child: Text(
                          'or continue with',
                          style: AppTheme.bodySmall.copyWith(
                            color: isDark
                                ? AppTheme.textSecondary
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? AppTheme.textTertiary
                              : AppTheme.textTertiaryLight,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                  const SizedBox(height: AppTheme.space24),

                  // Social Login Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _SocialLoginButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onPressed: () => _handleSocialLogin('google'),
                          isDark: isDark,
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space16),
                      Expanded(
                        child: _SocialLoginButton(
                          icon: Icons.apple_rounded,
                          label: 'Apple',
                          onPressed: () => _handleSocialLogin('apple'),
                          isDark: isDark,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 800.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms),

                  const SizedBox(height: AppTheme.space24),

                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: AppTheme.bodyMedium.copyWith(
                            color: isDark
                                ? AppTheme.textPrimary
                                : AppTheme.textPrimaryLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed('Signup');
                          },
                          child: Text(
                            'Sign up',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.harmonyOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 900.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Social Login Button Widget
class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isLoading;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isDark,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                size: 24,
              ),
              const SizedBox(width: AppTheme.space8),
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color:
                      isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
