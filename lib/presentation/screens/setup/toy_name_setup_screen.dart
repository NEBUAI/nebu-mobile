import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ToyNameSetupScreen extends ConsumerStatefulWidget {
  const ToyNameSetupScreen({super.key});

  @override
  ConsumerState<ToyNameSetupScreen> createState() => _ToyNameSetupScreenState();
}

class _ToyNameSetupScreenState extends ConsumerState<ToyNameSetupScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedName() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final String? savedName = prefs.getString('setup_toy_name');
    if (savedName != null && savedName.isNotEmpty) {
      _controller.text = savedName;
    }
  }

  Future<void> _saveToyName() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('setup_toy_name', _controller.text.trim());
  }

  void _showSkipSetupDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('setup.connection.skip_dialog_title'.tr()),
        content: Text('setup.connection.skip_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppConstants.routeHome);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: Text('setup.connection.skip_setup'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Asegura que el teclado no cause overflow
      body: DecoratedBox(
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button and Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                      _buildProgressIndicator(3, 7), // This is now step 3
                      const Spacer(),
                      // Placeholder to balance the row
                      const Opacity(
                        opacity: 0,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Use a scrollable view for the main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Title
                          Text(
                            'setup.toy_name.title'.tr(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'setup.toy_name.subtitle'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 60),

                          // Name input
                          TextFormField(
                            controller: _controller,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'setup.toy_name.hint'.tr(),
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'setup.toy_name.validation_empty'.tr();
                              }
                              if (value.trim().length < 2) {
                                return 'setup.toy_name.validation_short'.tr();
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Buttons
                  // Next button
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Save toy name to storage
                        await _saveToyName();
                        if (mounted) {
                          context.push(AppConstants.routeAgeSetup);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'setup.toy_name.next'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  TextButton(
                    onPressed: _showSkipSetupDialog,
                    child: Text(
                      'setup.connection.skip_setup'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int current, int total) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      total,
      (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: index < current ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: index < current ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );
}
