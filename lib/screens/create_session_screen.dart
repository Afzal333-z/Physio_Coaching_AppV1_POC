import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../theme/page_transitions.dart';
import 'therapist_dashboard_screen.dart';

class CreateSessionScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CreateSessionScreen({super.key, required this.onBack});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;
  String? _error;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _errorController;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _errorAnimation = CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter your name';
      });
      _errorController.forward(from: 0);
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
      _errorController.reset();
    });

    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final result = await sessionProvider.createSession(_nameController.text.trim());

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.of(context).pushReplacement(
        PageTransitions.fadeSlideTransition(const TherapistDashboardScreen()),
      );
    } else {
      setState(() {
        _error = result['error'] ?? 'Failed to create session';
        _isCreating = false;
      });
      _errorController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button with animation
                  StaggeredListAnimation(
                    index: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        boxShadow: AppTheme.shadowSoft,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 28),
                        color: AppTheme.primaryBlue,
                        onPressed: widget.onBack,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXxl),

                  // Icon with animation
                  StaggeredListAnimation(
                    index: 1,
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryBlue, Color(0xFF5BA3F5)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowMedium,
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Title
                  StaggeredListAnimation(
                    index: 2,
                    child: Text(
                      'Create Session',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Subtitle
                  StaggeredListAnimation(
                    index: 3,
                    child: Text(
                      'Start a new session to monitor your patients',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXxl),

                  // Form card with animation
                  StaggeredListAnimation(
                    index: 4,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingXl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Details',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacingL),
                              TextField(
                                controller: _nameController,
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: 'Your Name',
                                  hintText: 'Enter your full name',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 28,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                                  ),
                                ),
                                enabled: !_isCreating,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleCreate(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Error message with animation
                  if (_error != null) ...[
                    const SizedBox(height: AppTheme.spacingL),
                    FadeTransition(
                      opacity: _errorAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.2),
                          end: Offset.zero,
                        ).animate(_errorAnimation),
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRose.withOpacity(0.1),
                            border: Border.all(
                              color: AppTheme.errorRose,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppTheme.errorRose,
                                size: 28,
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.errorRose,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppTheme.spacingXl),

                  // Create button with animation
                  StaggeredListAnimation(
                    index: 5,
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryBlue, Color(0xFF5BA3F5)],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          boxShadow: AppTheme.shadowMedium,
                        ),
                        child: ElevatedButton(
                          onPressed: _isCreating ? null : _handleCreate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingL,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusL),
                            ),
                          ),
                          child: _isCreating
                              ? const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_circle_outline, size: 26),
                                    const SizedBox(width: AppTheme.spacingM),
                                    Text(
                                      'Create Session',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Info card with animation
                  StaggeredListAnimation(
                    index: 6,
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.primaryBlue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What\'s Next?',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingS),
                                Text(
                                  'After creating, you\'ll receive a session code to share with your patients (maximum 3).',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                        height: 1.6,
                                      ),
                                ),
                              ],
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
    );
  }
}

