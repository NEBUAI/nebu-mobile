import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/google_signin_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any previous auth errors (e.g. from signup screen)
    ref.read(authProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(
      text: _identifierController.text.contains('@')
          ? _identifierController.text.trim()
          : '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        var isSending = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text('auth.forgot_password_title'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('auth.forgot_password_body'.tr()),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'auth.forgot_password_email_hint'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          return;
                        }

                        setDialogState(() => isSending = true);
                        final success = await ref
                            .read(authProvider.notifier)
                            .requestPasswordReset(email);
                        if (!ctx.mounted) {
                          return;
                        }
                        Navigator.pop(ctx);

                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'auth.forgot_password_success'.tr()),
                                backgroundColor: context.colors.success,
                              ),
                            );
                            _showResetPasswordDialog();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('auth.forgot_password_error'.tr()),
                                backgroundColor: context.colors.error,
                              ),
                            );
                          }
                        }
                      },
                child: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('auth.forgot_password_send'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetPasswordDialog() {
    final tokenController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        var isSubmitting = false;
        String? errorText;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text('auth.reset_password_title'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('auth.reset_password_body'.tr()),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tokenController,
                    decoration: InputDecoration(
                      hintText: 'auth.reset_password_token_hint'.tr(),
                      prefixIcon: const Icon(Icons.key_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'auth.reset_password_new_password_hint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'auth.reset_password_confirm_hint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorText!,
                      style: TextStyle(color: context.colors.error, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final token = tokenController.text.trim();
                        final password = passwordController.text;
                        final confirm = confirmController.text;

                        if (token.isEmpty) {
                          return;
                        }
                        if (password.length < 8) {
                          setDialogState(() {
                            errorText =
                                'auth.reset_password_too_short'.tr();
                          });
                          return;
                        }
                        if (password != confirm) {
                          setDialogState(() {
                            errorText =
                                'auth.reset_password_mismatch'.tr();
                          });
                          return;
                        }

                        setDialogState(() {
                          isSubmitting = true;
                          errorText = null;
                        });

                        final success = await ref
                            .read(authProvider.notifier)
                            .resetPassword(
                                token: token, newPassword: password);
                        if (!ctx.mounted) {
                          return;
                        }
                        Navigator.pop(ctx);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'auth.reset_password_success'.tr()
                                    : 'auth.reset_password_error'.tr(),
                              ),
                              backgroundColor:
                                  success ? context.colors.success : context.colors.error,
                            ),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('auth.reset_password_submit'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
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
          SnackBar(content: Text('auth.google_signin_failed_detail'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                  _BackButton(onPressed: () => context.pop()),
                  SizedBox(height: context.spacing.paragraphBottomMargin),
                  Text(
                    'auth.welcome_back'.tr(),
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: context.colors.textNormal,
                    ),
                  ),
                  SizedBox(height: context.spacing.titleBottomMarginSm),
                  Text(
                    'auth.sign_in_subtitle_long'.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      color: context.colors.grey400,
                    ),
                  ),
                  SizedBox(height: context.spacing.largePageBottomMargin),
                  if (authState.hasError && !authState.isLoading)
                    _ErrorBanner(
                      message: authState.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                    ),
                  SizedBox(height: context.spacing.titleBottomMargin),
                  _CustomTextField(
                    controller: _identifierController,
                    label: 'auth.username_or_email'.tr(),
                    hintText: 'auth.username_or_email_hint'.tr(),
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'auth.username_or_email_required'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.spacing.titleBottomMargin),
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
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _showForgotPasswordDialog,
                      child: Text(
                        'auth.forgot_password'.tr(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.spacing.paragraphBottomMargin),
                  _PrimaryButton(
                    text: 'auth.sign_in'.tr(),
                    isLoading: authState.isLoading,
                    onPressed: _handleEmailLogin,
                  ),
                  SizedBox(height: context.spacing.panelPadding),
                  _OrDivider(),
                  SizedBox(height: context.spacing.panelPadding),
                  _GoogleButton(
                    text: 'auth.continue_with_google'.tr(),
                    isLoading: authState.isLoading,
                    onPressed: _handleGoogleSignIn,
                  ),
                  SizedBox(height: context.spacing.paragraphBottomMargin),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'auth.no_account'.tr()} ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: context.colors.grey400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.signUp.path),
                          child: Text(
                            'auth.sign_up'.tr(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
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
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: textTheme.bodyLarge?.copyWith(color: context.colors.textNormal),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(color: context.colors.grey500),
        labelStyle: textTheme.bodyMedium?.copyWith(color: context.colors.grey400),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
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
          borderSide: BorderSide(color: context.colors.grey700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
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
  final VoidCallback? onPressed;

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
  final VoidCallback? onPressed;

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
            border: Border.all(color: context.colors.grey700, width: 1.5),
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
              color: context.colors.grey500,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.error),
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
