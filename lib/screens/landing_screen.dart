import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../theme/page_transitions.dart';
import 'create_session_screen.dart';
import 'join_session_screen.dart';
import 'patient_view_screen.dart';
import 'therapist_dashboard_screen.dart';
import 'camera_test_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);

    // Check if user is in session
    if (sessionProvider.isInSession) {
      if (sessionProvider.userRole == 'therapist') {
        return const TherapistDashboardScreen();
      } else {
        return const PatientViewScreen();
      }
    }

    return const LandingContent();
  }
}

class LandingContent extends StatefulWidget {
  const LandingContent({super.key});

  @override
  State<LandingContent> createState() => _LandingContentState();
}

class _LandingContentState extends State<LandingContent>
    with TickerProviderStateMixin {
  String _currentView = 'landing';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _changeView(String view) {
    setState(() {
      _currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 'create') {
      return CreateSessionScreen(onBack: () => _changeView('landing'));
    } else if (_currentView == 'join') {
      return JoinSessionScreen(onBack: () => _changeView('landing'));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.gradientWarm,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppTheme.spacingXxl),

                    // App icon/logo with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue,
                                  AppTheme.secondaryTeal,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.shadowMedium,
                            ),
                            child: const Icon(
                              Icons.healing,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Title with staggered animation
                    StaggeredListAnimation(
                      index: 0,
                      child: Text(
                        'Physio Platform',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Subtitle
                    StaggeredListAnimation(
                      index: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                        child: Text(
                          'Remote physiotherapy sessions with AI-powered motion tracking',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXxl + AppTheme.spacingL),

                    // Role cards with staggered entrance
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive layout for different screen sizes
                        if (constraints.maxWidth > 600) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 350),
                                  child: StaggeredListAnimation(
                                    index: 2,
                                    child: _RoleCard(
                                      icon: Icons.medical_services_rounded,
                                      title: "I'm a Therapist",
                                      description:
                                          'Create a session and monitor multiple patients with real-time pose tracking',
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.primaryBlue,
                                          Color(0xFF5BA3F5),
                                        ],
                                      ),
                                      onTap: () => _changeView('create'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingL),
                              Flexible(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 350),
                                  child: StaggeredListAnimation(
                                    index: 3,
                                    child: _RoleCard(
                                      icon: Icons.accessibility_new_rounded,
                                      title: "I'm a Patient",
                                      description:
                                          'Join a session using your therapist\'s code and get real-time feedback',
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.successGreen,
                                          Color(0xFF7FDC8F),
                                        ],
                                      ),
                                      onTap: () => _changeView('join'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Vertical layout for smaller screens
                          return Column(
                            children: [
                              StaggeredListAnimation(
                                index: 2,
                                child: _RoleCard(
                                  icon: Icons.medical_services_rounded,
                                  title: "I'm a Therapist",
                                  description:
                                      'Create a session and monitor multiple patients with real-time pose tracking',
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.primaryBlue,
                                      Color(0xFF5BA3F5),
                                    ],
                                  ),
                                  onTap: () => _changeView('create'),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingL),
                              StaggeredListAnimation(
                                index: 3,
                                child: _RoleCard(
                                  icon: Icons.accessibility_new_rounded,
                                  title: "I'm a Patient",
                                  description:
                                      'Join a session using your therapist\'s code and get real-time feedback',
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.successGreen,
                                      Color(0xFF7FDC8F),
                                    ],
                                  ),
                                  onTap: () => _changeView('join'),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Debug: Camera Test Button
                    StaggeredListAnimation(
                      index: 4,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CameraTestScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bug_report, size: 16),
                        label: const Text('🔧 Test Camera (Debug)'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXxl),

                    // Footer with animation
                    StaggeredListAnimation(
                      index: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingL,
                          vertical: AppTheme.spacingM,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 20,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              'Powered by MediaPipe AI',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: _elevationAnimation.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            child: InkWell(
              onTap: widget.onTap,
              onHover: _handleHoverChange,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: _isHovered
                        ? AppTheme.primaryBlue.withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon container with gradient
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradient.colors.first.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Title
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Description
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Action button with gradient
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: widget.gradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: widget.gradient.colors.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingL,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusL),
                            ),
                          ),
                          child: Text(
                            widget.title.contains('Therapist')
                                ? 'Create Session'
                                : 'Join Session',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

