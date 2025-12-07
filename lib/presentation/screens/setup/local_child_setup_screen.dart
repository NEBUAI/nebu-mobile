import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';

/// Screen for local child configuration (without device connection)
/// Allows users to set up child information and custom prompts locally
class LocalChildSetupScreen extends ConsumerStatefulWidget {
  const LocalChildSetupScreen({super.key});

  @override
  ConsumerState<LocalChildSetupScreen> createState() =>
      _LocalChildSetupScreenState();
}

class _LocalChildSetupScreenState extends ConsumerState<LocalChildSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  final _customPromptController = TextEditingController();

  String? _selectedAge;
  String? _selectedPersonality;
  bool _isSaving = false;

  final List<Map<String, String>> _ageGroups = [
    {'value': '3-5', 'label': '3-5 years', 'icon': '👶'},
    {'value': '6-8', 'label': '6-8 years', 'icon': '🧒'},
    {'value': '9-12', 'label': '9-12 years', 'icon': '👦'},
    {'value': '13+', 'label': '13+ years', 'icon': '👨'},
  ];

  final List<Map<String, String>> _personalities = [
    {'value': 'friendly', 'label': 'Friendly & Cheerful', 'icon': '😊'},
    {'value': 'curious', 'label': 'Curious & Adventurous', 'icon': '🔍'},
    {'value': 'calm', 'label': 'Calm & Patient', 'icon': '😌'},
    {'value': 'energetic', 'label': 'Energetic & Playful', 'icon': '⚡'},
    {'value': 'creative', 'label': 'Creative & Imaginative', 'icon': '🎨'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = ref.read(sharedPreferencesProvider);

    final savedName = prefs.getString('local_child_name');
    final savedAge = prefs.getString('local_child_age');
    final savedPersonality = prefs.getString('local_child_personality');
    final savedPrompt = prefs.getString('local_custom_prompt');

    if (savedName != null) _childNameController.text = savedName;
    if (savedPrompt != null) _customPromptController.text = savedPrompt;

    setState(() {
      _selectedAge = savedAge;
      _selectedPersonality = savedPersonality;
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an age group'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPersonality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a personality'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = ref.read(sharedPreferencesProvider);

      // Save child information
      await prefs.setString('local_child_name', _childNameController.text.trim());
      await prefs.setString('local_child_age', _selectedAge!);
      await prefs.setString('local_child_personality', _selectedPersonality!);

      // Save custom prompt
      final customPrompt = _customPromptController.text.trim();
      if (customPrompt.isNotEmpty) {
        await prefs.setString('local_custom_prompt', customPrompt);
      } else {
        // Generate default prompt based on selections
        final defaultPrompt = _generateDefaultPrompt();
        await prefs.setString('local_custom_prompt', defaultPrompt);
      }

      // Mark setup as completed locally
      await prefs.setBool('setup_completed_locally', true);

      ref.read(loggerProvider).i(
        '✅ [LOCAL_SETUP] Child data saved locally: '
        'name=${_childNameController.text}, age=$_selectedAge, '
        'personality=$_selectedPersonality',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child information saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      context.go(AppRoutes.home.path);
    } catch (e) {
      ref.read(loggerProvider).e('❌ [LOCAL_SETUP] Error saving data: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _generateDefaultPrompt() {
    final childName = _childNameController.text.trim();
    final age = _selectedAge ?? 'young';
    final personality = _personalities
        .firstWhere(
          (p) => p['value'] == _selectedPersonality,
          orElse: () => _personalities[0],
        )['label'];

    return '''You are Nebu, a friendly AI companion for children.

Child Information:
- Name: $childName
- Age Group: $age years old
- Personality Preference: $personality

Your role:
- Be supportive, encouraging, and age-appropriate
- Help with learning and creativity
- Answer questions in a simple, understandable way
- Keep conversations fun and engaging
- Ensure safety and provide positive guidance

Communication style:
- Use simple, clear language suitable for a $age year old
- Be $personality in your interactions
- Encourage curiosity and learning
- Always maintain a positive, supportive tone''';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildHeader(context),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            'Child Information',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryLight,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Set up Nebu for your child without connecting a device',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Child Name
                          TextFormField(
                            controller: _childNameController,
                            decoration: InputDecoration(
                              labelText: "Child's Name",
                              hintText: 'Enter your child\'s name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Age Selection
                          Text(
                            'Age Group',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _ageGroups.map((age) {
                              final isSelected = _selectedAge == age['value'];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedAge = age['value'];
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryLight
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryLight
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        age['icon']!,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        age['label']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 32),

                          // Personality Selection
                          Text(
                            'Preferred Personality',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ...(_personalities.map((personality) {
                            final isSelected =
                                _selectedPersonality == personality['value'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedPersonality = personality['value'];
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryLight.withOpacity(0.1)
                                        : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryLight
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        personality['icon']!,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          personality['label']!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppTheme.primaryLight
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: AppTheme.primaryLight,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })),

                          const SizedBox(height: 32),

                          // Custom Prompt (Optional)
                          Text(
                            'Custom Instructions (Optional)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Add any special instructions or preferences for how Nebu should interact with your child',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _customPromptController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText:
                                  'e.g., Focus on science topics, avoid scary stories, encourage reading...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Save Button
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Save & Continue',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Text(
            'Local Setup',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      );
}
