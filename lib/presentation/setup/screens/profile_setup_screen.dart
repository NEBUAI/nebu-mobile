import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final controller = Get.find<SetupWizardController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = controller.userName.value;
    _emailController.text = controller.userEmail.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Progress indicator
                SetupProgressIndicator(
                  currentStep: controller.currentStep.value + 1,
                  totalSteps: controller.totalSteps,
                ),
                const SizedBox(height: 40),
                
                // Title
                const GradientText(
                  'Create Your Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'Tell us a bit about yourself to personalize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Avatar section
                Center(
                  child: GestureDetector(
                    onTap: _showAvatarOptions,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: controller.avatarUrl.value.isNotEmpty
                            ? null
                            : const LinearGradient(
                                colors: AppTheme.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppTheme.primaryLight,
                          width: 3,
                        ),
                        image: controller.avatarUrl.value.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(controller.avatarUrl.value),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: controller.avatarUrl.value.isEmpty
                          ? const Icon(
                              Icons.person_add,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: _showAvatarOptions,
                  child: Text(
                    'Change Avatar',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Form fields
                Expanded(
                  child: Column(
                    children: [
                      CustomInput(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        onChanged: (value) => controller.userName.value = value,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.person),
                        textInputAction: TextInputAction.next,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CustomInput(
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        controller: _emailController,
                        onChanged: (value) => controller.userEmail.value = value,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                      ),
                      
                      const Spacer(),
                      
                      // Privacy note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryLight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              color: AppTheme.primaryLight,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your information is secure and will only be used to personalize your experience.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action buttons
                Column(
                  children: [
                    CustomButton(
                      text: 'Continue',
                      onPressed: _validateAndContinue,
                      isFullWidth: true,
                      icon: Icons.arrow_forward,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => controller.previousStep(),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndContinue() {
    if (_formKey.currentState!.validate()) {
      controller.nextStep();
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Default avatars
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    controller.avatarUrl.value = 'https://via.placeholder.com/100/6C5CE7/FFFFFF?text=${index + 1}';
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Camera option (placeholder)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera functionality coming soon!'),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery functionality coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
