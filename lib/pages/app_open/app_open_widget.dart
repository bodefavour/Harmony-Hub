import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_open_model.dart';
export 'app_open_model.dart';

/// Modern Welcome Screen - Spotify/Apple Music inspired
/// Features: Beautiful gradients, smooth animations, engaging UI
class AppOpenWidget extends StatefulWidget {
  const AppOpenWidget({super.key});

  @override
  State<AppOpenWidget> createState() => _AppOpenWidgetState();
}

class _AppOpenWidgetState extends State<AppOpenWidget>
    with TickerProviderStateMixin {
  late AppOpenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppOpenModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'appOpen'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
                    AppTheme.spotifyGreen.withOpacity(0.1),
                  ]
                : [
                    AppTheme.lightBackground,
                    const Color(0xFFf0f0f0),
                    AppTheme.spotifyGreen.withOpacity(0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo and Tagline Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .scale(
                            duration: 2000.ms,
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withOpacity(0.3),
                          ),

                      const SizedBox(height: AppTheme.space32),

                      // App Name
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: Text(
                          'Harmony Hub',
                          style: AppTheme.displayLarge.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(
                            begin: -0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: AppTheme.space16),

                      // Tagline
                      Text(
                        'Where music meets your soul',
                        style: AppTheme.headlineMedium.copyWith(
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: AppTheme.space48),

                      // Feature Pills
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppTheme.space12,
                        runSpacing: AppTheme.space12,
                        children: [
                          _FeaturePill(
                            icon: Icons.library_music_rounded,
                            label: 'Millions of songs',
                            isDark: isDark,
                          ),
                          _FeaturePill(
                            icon: Icons.favorite_rounded,
                            label: 'Personalized playlists',
                            isDark: isDark,
                          ),
                          _FeaturePill(
                            icon: Icons.high_quality_rounded,
                            label: 'High quality audio',
                            isDark: isDark,
                          ),
                        ]
                            .animate(interval: 100.ms)
                            .fadeIn(duration: 400.ms, delay: 600.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            ),
                      ),
                    ],
                  ),
                ),

                // Bottom Action Buttons
                Column(
                  children: [
                    // Get Started Button
                    ModernButton(
                      text: 'Get Started',
                      icon: Icons.music_note_rounded,
                      onPressed: () {
                        logFirebaseEvent('APP_OPEN_get_started_pressed');
                        context.pushNamed('onboarding');
                      },
                      width: double.infinity,
                      useGradient: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(
                          begin: 0.5,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.space16),

                    // Sign In Button
                    ModernButton(
                      text: 'Sign In',
                      onPressed: () {
                        logFirebaseEvent('APP_OPEN_sign_in_pressed');
                        context.pushNamed('login');
                      },
                      isOutline: true,
                      width: double.infinity,
                    ).animate().fadeIn(duration: 400.ms, delay: 900.ms).slideY(
                          begin: 0.5,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.space24),

                    // Footer Text
                    Text(
                      'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                      style: AppTheme.caption.copyWith(
                        color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
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

/// Feature Pill Widget
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard.withOpacity(0.5) : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: AppTheme.spotifyGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.spotifyGreen,
          ),
          const SizedBox(width: AppTheme.space8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color:
                  isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
