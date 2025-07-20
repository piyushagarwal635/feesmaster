import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/logo_widget.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({Key? key}) : super(key: key);

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _showBiometricPrompt = false;
  String? _errorMessage;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock admin credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@feesmaster.com': 'admin123',
    'manager@feesmaster.com': 'manager123',
    'supervisor@feesmaster.com': 'super123',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 1500));

      // Check mock credentials
      if (_mockCredentials.containsKey(email.toLowerCase()) &&
          _mockCredentials[email.toLowerCase()] == password) {
        // Success haptic feedback
        HapticFeedback.lightImpact();

        // Show biometric prompt for future logins
        setState(() {
          _showBiometricPrompt = true;
          _isLoading = false;
        });

        // Auto-navigate after showing biometric prompt
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _navigateToDashboard();
          }
        });
      } else {
        // Invalid credentials
        setState(() {
          _errorMessage =
              'Invalid email or password. Please check your credentials and try again.';
          _isLoading = false;
        });

        // Error haptic feedback
        HapticFeedback.mediumImpact();

        // Show error snackbar
        _showErrorSnackBar(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Network error. Please check your connection and try again.';
        _isLoading = false;
      });

      _showErrorSnackBar(_errorMessage!);
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);

    try {
      // Simulate biometric authentication
      await Future.delayed(Duration(milliseconds: 1000));

      // Success haptic feedback
      HapticFeedback.lightImpact();

      _navigateToDashboard();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Biometric authentication failed. Please try again.');
    }
  }

  void _handleSkipBiometric() {
    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard-overview',
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.white,
              size: 4.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.getErrorColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 8.h),

                    // Logo Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: LogoWidget(),
                    ),

                    SizedBox(height: 6.h),

                    // Login Form or Biometric Prompt
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _showBiometricPrompt
                            ? BiometricPromptWidget(
                                onBiometricLogin: _handleBiometricLogin,
                                onSkip: _handleSkipBiometric,
                                isLoading: _isLoading,
                              )
                            : LoginFormWidget(
                                onLogin: _handleLogin,
                                isLoading: _isLoading,
                              ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Security Badge
                    if (!_showBiometricPrompt)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.getSuccessColor(isLight)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2.w),
                            border: Border.all(
                              color: AppTheme.getSuccessColor(isLight)
                                  .withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'security',
                                color: AppTheme.getSuccessColor(isLight),
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'SSL Secured & Encrypted',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.getSuccessColor(isLight),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: 6.h),

                    // Footer
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'FeesMaster Admin v2.1.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '© 2025 FeesMaster. All rights reserved.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),
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
