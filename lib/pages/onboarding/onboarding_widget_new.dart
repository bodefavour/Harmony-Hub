import '/components/signin_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_model.dart';
export 'onboarding_model.dart';

/// Modern Onboarding Screen - Spotify/Apple Music style
/// Features: Swipeable cards, smooth animations, beautiful design
class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  late OnboardingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.music_note_rounded,
      title: 'Millions of Songs',
      description:
          'Access an endless library of music from around the world. Discover new artists and timeless classics.',
      gradient: const LinearGradient(
        colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPage(
      icon: Icons.favorite_rounded,
      title: 'Personalized For You',
      description:
          'Get custom playlists and recommendations based on your music taste. Your perfect soundtrack awaits.',
      gradient: const LinearGradient(
        colors: [Color(0xFF8E44AD), Color(0xFFE91E63)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPage(
      icon: Icons.offline_bolt_rounded,
      title: 'Listen Offline',
      description:
          'Download your favorite songs and listen without internet. Music everywhere, anytime.',
      gradient: const LinearGradient(
        colors: [Color(0xFF2E77D0), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPage(
      icon: Icons.high_quality_rounded,
      title: 'Premium Sound',
      description:
          'Experience crystal-clear audio quality. Feel every beat, every note, as the artist intended.',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFF7971E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingModel());
    _pageController = PageController();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'onboarding'});
  }

  @override
  void dispose() {
    _model.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - show sign up modal
      _showSignUpModal();
    }
  }

  void _skip() {
    _showSignUpModal();
  }

  Future<void> _showSignUpModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const SigninWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppTheme.darkBackground, AppTheme.darkSurface]
                : [AppTheme.lightBackground, AppTheme.lightSurface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Skip button
              Padding(
                padding: const EdgeInsets.all(AppTheme.space16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    // Skip button
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.spotifyGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.3, end: 0, duration: 400.ms),

              // PageView with onboarding cards
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingCard(
                      page: _pages[index],
                      isDark: isDark,
                    );
                  },
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space24),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppTheme.spotifyGreen,
                    dotColor: isDark
                        ? AppTheme.textTertiary
                        : AppTheme.textTertiaryLight,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                    spacing: 8,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(AppTheme.space24),
                child: Column(
                  children: [
                    ModernButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      icon: _currentPage == _pages.length - 1
                          ? Icons.music_note_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _nextPage,
                      width: double.infinity,
                      useGradient: true,
                    ),
                    const SizedBox(height: AppTheme.space16),
                    ModernButton(
                      text: 'Sign In',
                      onPressed: () {
                        context.pushNamed('login');
                      },
                      isOutline: true,
                      width: double.infinity,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.5, end: 0, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onboarding Card Widget
class _OnboardingCard extends StatelessWidget {
  final OnboardingPage page;
  final bool isDark;

  const _OnboardingCard({
    required this.page,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: page.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.gradient.colors.first.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                duration: 2000.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: AppTheme.space48),

          // Title
          Text(
            page.title,
            style: AppTheme.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: -0.2, end: 0, duration: 600.ms),

          const SizedBox(height: AppTheme.space16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
            child: Text(
              page.description,
              style: AppTheme.bodyLarge.copyWith(
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideX(begin: 0.2, end: 0, duration: 600.ms),
        ],
      ),
    );
  }
}

/// Onboarding Page Model
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
