import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/google_signin_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          context.go(AppConstants.routeHome);
        } else {
          setState(() {
            _errorMessage = 'auth.invalid_credentials'.tr();
            _isLoading = false;
          });
        }
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _errorMessage = 'auth.login_error'.tr();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final googleSignIn = ref.read(googleSignInProvider);

      // Initialize with scopes
      await googleSignIn.initialize();

      // Authenticate using v7 API
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No ID token received from Google');
      }

      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.loginWithGoogle(idToken);

      if (mounted) {
        if (success) {
          context.go(AppConstants.routeHome);
        } else {
          setState(() {
            _errorMessage = 'auth.google_login_error'.tr();
            _isLoading = false;
          });
        }
      }
    } on GoogleSignInException {
      if (mounted) {
        setState(() {
          _errorMessage = 'auth.google_login_cancelled'.tr();
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _errorMessage = 'auth.google_login_error'.tr();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
                    onPressed: () => context.pop(),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'auth.sign_in'.tr(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.grey[800],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'auth.sign_in_subtitle'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 32),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'auth.email'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'auth.email_required'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'auth.email_invalid'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'auth.password'.tr(),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'auth.password_required'.tr();
                    }
                    if (value.length < 6) {
                      return 'auth.password_short'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO(duvet05): Implement forgot password
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('auth.forgot_password_coming_soon'.tr()),
                        ),
                      );
                    },
                    child: Text('auth.forgot_password'.tr()),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign in button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'auth.sign_in'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'auth.or_continue_with'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Google Sign In button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  label: Text(
                    'auth.sign_in_google'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auth.no_account'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppConstants.routeSignUp),
                      child: Text('auth.sign_up'.tr()),
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
