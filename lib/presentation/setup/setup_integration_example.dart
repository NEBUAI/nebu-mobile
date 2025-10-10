import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_wizard_screen.dart';
import 'setup_wizard_controller.dart';

/// Ejemplo de cómo integrar el Setup Wizard en tu aplicación
class SetupIntegrationExample {
  
  /// Verifica si el setup ya fue completado
  static Future<bool> isSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('setup_completed') ?? false;
  }

  /// Marca el setup como completado
  static Future<void> markSetupAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setup_completed', true);
  }

  /// Inicia el setup wizard
  static void startSetupWizard(BuildContext context) {
    Get.to(
      () => const SetupWizardScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Ejemplo de cómo usar en el main.dart o en una pantalla de splash
  static Widget buildSplashWithSetupCheck() {
    return FutureBuilder<bool>(
      future: isSetupCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isSetupDone = snapshot.data ?? false;
        
        if (!isSetupDone) {
          // Si no se ha completado el setup, mostrar el wizard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            startSetupWizard(context);
          });
        }

        // Mientras tanto, mostrar la pantalla principal o splash
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  'Nebu',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Ejemplo de cómo modificar el SetupWizardController para guardar datos
class ExtendedSetupWizardController extends SetupWizardController {
  
  @override
  void _saveSetupData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Guardar datos del setup
    await prefs.setString('user_name', userName.value);
    await prefs.setString('user_email', userEmail.value);
    await prefs.setString('avatar_url', avatarUrl.value);
    await prefs.setString('selected_language', selectedLanguage.value);
    await prefs.setString('selected_theme', selectedTheme.value);
    await prefs.setBool('notifications_enabled', notificationsEnabled.value);
    await prefs.setBool('voice_enabled', voiceEnabled.value);
    await prefs.setBool('microphone_permission', microphonePermission.value);
    await prefs.setBool('camera_permission', cameraPermission.value);
    await prefs.setBool('notifications_permission', notificationsPermission.value);
    
    // Marcar setup como completado
    await prefs.setBool('setup_completed', true);
    
    super._saveSetupData();
  }
  
  /// Cargar datos del setup desde SharedPreferences
  Future<void> loadSetupData() async {
    final prefs = await SharedPreferences.getInstance();
    
    userName.value = prefs.getString('user_name') ?? '';
    userEmail.value = prefs.getString('user_email') ?? '';
    avatarUrl.value = prefs.getString('avatar_url') ?? '';
    selectedLanguage.value = prefs.getString('selected_language') ?? 'en';
    selectedTheme.value = prefs.getString('selected_theme') ?? 'system';
    notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
    voiceEnabled.value = prefs.getBool('voice_enabled') ?? true;
    microphonePermission.value = prefs.getBool('microphone_permission') ?? false;
    cameraPermission.value = prefs.getBool('camera_permission') ?? false;
    notificationsPermission.value = prefs.getBool('notifications_permission') ?? false;
  }
}

/// Ejemplo de pantalla principal que verifica el setup
class MainScreenWithSetupCheck extends StatefulWidget {
  const MainScreenWithSetupCheck({super.key});

  @override
  State<MainScreenWithSetupCheck> createState() => _MainScreenWithSetupCheckState();
}

class _MainScreenWithSetupCheckState extends State<MainScreenWithSetupCheck> {
  bool _isCheckingSetup = true;
  bool _setupCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkSetupStatus();
  }

  Future<void> _checkSetupStatus() async {
    final isCompleted = await SetupIntegrationExample.isSetupCompleted();
    
    setState(() {
      _setupCompleted = isCompleted;
      _isCheckingSetup = false;
    });

    if (!isCompleted) {
      // Mostrar setup wizard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SetupIntegrationExample.startSetupWizard(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSetup) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_setupCompleted) {
      return const Scaffold(
        body: Center(
          child: Text('Loading setup...'),
        ),
      );
    }

    // Aquí iría tu pantalla principal de la app
    return const Scaffold(
      body: Center(
        child: Text('Main App Screen'),
      ),
    );
  }
}
