import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/google_signin_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any previous auth errors (e.g. from login screen)
    ref.read(authProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No ID token received from Google');
      }

      await ref.read(authProvider.notifier).loginWithGoogle(idToken);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth.google_signup_failed_detail'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;

    // Note: Navigation is handled automatically by the router's redirect logic
    // We only need to show error messages here

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: context.spacing.pageEdgeInsets,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.spacing.sectionTitleBottomMargin),

                  // Back button
                  _BackButton(onPressed: () => context.pop()),

                  SizedBox(height: context.spacing.paragraphBottomMargin),

                  // Header
                  Text(
                    'auth.create_account'.tr(),
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: context.colors.textNormal,
                    ),
                  ),
                  SizedBox(height: context.spacing.titleBottomMarginSm),
                  Text(
                    'auth.create_account_subtitle'.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      color: context.colors.grey400,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Error message
                  if (authState.hasError && !authState.isLoading) ...[
                    _ErrorBanner(
                      message: authState.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                    ),
                    SizedBox(height: context.spacing.titleBottomMargin),
                  ],

                  // Name row
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextField(
                          controller: _firstNameController,
                          label: 'auth.first_name'.tr(),
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth.required'.tr();
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CustomTextField(
                          controller: _lastNameController,
                          label: 'auth.last_name'.tr(),
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth.required'.tr();
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.spacing.titleBottomMargin),

                  // Email field
                  _CustomTextField(
                    controller: _emailController,
                    label: 'auth.email'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
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

                  SizedBox(height: context.spacing.titleBottomMargin),

                  // Password field
                  _CustomTextField(
                    controller: _passwordController,
                    label: 'auth.password'.tr(),
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
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

                  SizedBox(height: context.spacing.titleBottomMargin),

                  // Confirm Password field
                  _CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'auth.confirm_password'.tr(),
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'auth.confirm_password_required'.tr();
                      }
                      if (value != _passwordController.text) {
                        return 'auth.passwords_dont_match'.tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: context.spacing.paragraphBottomMargin),

                  // Sign up button
                  _PrimaryButton(
                    text: 'auth.create_account'.tr(),
                    isLoading: authState.isLoading,
                    onPressed: _handleEmailSignUp,
                  ),

                  SizedBox(height: context.spacing.panelPadding),

                  // Divider
                  _OrDivider(),

                  SizedBox(height: context.spacing.panelPadding),

                  // Google button
                  _GoogleButton(
                    text: 'auth.continue_with_google'.tr(),
                    isLoading: authState.isLoading,
                    onPressed: _handleGoogleSignUp,
                  ),

                  SizedBox(height: context.spacing.paragraphBottomMargin),

                  // Sign in link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${'auth.already_have_account'.tr()} ",
                          style: textTheme.bodyMedium?.copyWith(
                            color: context.colors.grey400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'auth.sign_in'.tr(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.spacing.panelPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ Reusable Components ============

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.grey900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: context.colors.grey200,
          ),
        ),
      );
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textCapitalization: textCapitalization,
      style: textTheme.bodyLarge?.copyWith(color: context.colors.textNormal),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(color: context.colors.grey400),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: context.colors.grey500,
          size: 22,
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  color: context.colors.grey500,
                  size: 22,
                ),
              )
            : null,
        filled: true,
        fillColor: context.colors.grey900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colors.grey800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary100, context.colors.primary],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(context.colors.textOnFilled),
                    ),
                  )
                : Text(
                    text,
                    style: textTheme.titleMedium?.copyWith(
                      color: context.colors.textOnFilled,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.grey800, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                height: 22,
                width: 22,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.g_mobiledata,
                  size: 28,
                  color: context.colors.grey300,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: textTheme.titleMedium?.copyWith(
                  color: context.colors.grey200,
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Divider(color: context.colors.grey700, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'auth.or'.tr(),
            style: textTheme.bodySmall?.copyWith(
              color: context.colors.grey400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colors.grey700, thickness: 1)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      decoration: BoxDecoration(
        color: context.colors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: context.colors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
