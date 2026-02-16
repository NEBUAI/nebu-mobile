import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_notifier.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar en didChangeDependencies donde ref está disponible
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = ref.read(setupWizardProvider);
    _nameController.text = state.userName;
    _emailController.text = state.userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Store the image path
        ref.read(setupWizardProvider.notifier).updateAvatarUrl(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('setup.profile.photo_captured'.tr())),
          );
        }
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('setup.profile.camera_error'.tr())));
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Store the image path
        ref.read(setupWizardProvider.notifier).updateAvatarUrl(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('setup.profile.image_selected'.tr())),
          );
        }
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('setup.profile.gallery_error'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SetupWizardState state = ref.watch(setupWizardProvider);
    final SetupWizardNotifier notifier = ref.read(setupWizardProvider.notifier);
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.pageMargin),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: context.spacing.largePageBottomMargin),
                // Progress indicator
                SetupProgressIndicator(
                  currentStep: state.currentStep + 1,
                  totalSteps: SetupWizardState.totalSteps,
                ),
                SizedBox(height: context.spacing.largePageBottomMargin),

                // Title
                const GradientText(
                  'Create Your Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.spacing.sectionTitleBottomMargin),

                // Subtitle
                Text(
                  'Tell us a bit about yourself to personalize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.textLowPriority,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.spacing.largePageBottomMargin),

                // Avatar section
                Center(
                  child: GestureDetector(
                    onTap: _showAvatarOptions,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: state.avatarUrl.isNotEmpty
                            ? null
                            : LinearGradient(
                                colors: [context.colors.primary, context.colors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: context.colors.primary,
                          width: 3,
                        ),
                        image: state.avatarUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(state.avatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: state.avatarUrl.isEmpty
                          ? Icon(
                              Icons.person_add,
                              size: 40,
                              color: context.colors.textOnFilled,
                            )
                          : null,
                    ),
                  ),
                ),

                SizedBox(height: context.spacing.titleBottomMargin),

                TextButton(
                  onPressed: _showAvatarOptions,
                  child: Text(
                    'Change Avatar',
                    style: TextStyle(
                      color: context.colors.primary,
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
                        onChanged: notifier.updateUserName,
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

                      SizedBox(height: context.spacing.titleBottomMargin),

                      CustomInput(
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        controller: _emailController,
                        onChanged: notifier.updateUserEmail,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!_isValidEmail(value.trim())) {
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
                        padding: EdgeInsets.all(context.spacing.alertPadding),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              color: context.colors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your information is secure and will only be used to personalize your experience.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textLowPriority,
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
                    SizedBox(height: context.spacing.sectionTitleBottomMargin),
                    TextButton(
                      onPressed: notifier.previousStep,
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: context.colors.textLowPriority,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.spacing.titleBottomMargin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndContinue() {
    if (_formKey.currentState!.validate()) {
      ref.read(setupWizardProvider.notifier).nextStep();
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showAvatarOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Avatar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                final colors = [
                  context.colors.primary,
                  Colors.teal,
                  Colors.orange,
                  Colors.pink,
                  Colors.purple,
                  Colors.indigo,
                  Colors.green,
                  Colors.red,
                ];
                final avatarColor = colors[index % colors.length];

                return GestureDetector(
                  onTap: () {
                    // Store avatar as local identifier instead of external URL
                    ref
                        .read(setupWizardProvider.notifier)
                        .updateAvatarUrl('avatar_${index + 1}');
                    Navigator.pop(context);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: avatarColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: avatarColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.person, size: 32, color: avatarColor),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Camera option
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),

            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}
