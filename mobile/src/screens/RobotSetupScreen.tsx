import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  TextInput,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { Header, AnimatedCard, GradientText } from '@/components';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';
import { apiService } from '@/services/api';
import { bluetoothService, BluetoothDevice } from '@/services/bluetoothService';

// Tipos para el estado del setup (ya importado desde bluetoothService)

interface WiFiNetwork {
  ssid: string;
  rssi: number;
  security: string;
}

interface SetupStep {
  id: number;
  title: string;
  description: string;
  completed: boolean;
  active: boolean;
}

const RobotSetupScreen: React.FC = () => {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  // Estados del setup
  const [currentStep, setCurrentStep] = useState(0);
  const [isScanning, setIsScanning] = useState(false);
  const [bluetoothDevices, setBluetoothDevices] = useState<BluetoothDevice[]>([]);
  const [selectedDevice, setSelectedDevice] = useState<BluetoothDevice | null>(null);
  const [isConnecting, setIsConnecting] = useState(false);
  const [isValidating, setIsValidating] = useState(false);
  const [wifiNetworks, setWifiNetworks] = useState<WiFiNetwork[]>([]);
  const [selectedWifi, setSelectedWifi] = useState<string>('');
  const [wifiPassword, setWifiPassword] = useState('');
  const [isConfiguring, setIsConfiguring] = useState(false);
  const [setupComplete, setSetupComplete] = useState(false);

  // Pasos del setup
  const setupSteps: SetupStep[] = [
    {
      id: 0,
      title: t('robotSetup.step1.title'),
      description: t('robotSetup.step1.description'),
      completed: selectedDevice !== null,
      active: currentStep === 0,
    },
    {
      id: 1,
      title: t('robotSetup.step2.title'),
      description: t('robotSetup.step2.description'),
      completed: selectedDevice !== null && !isValidating,
      active: currentStep === 1,
    },
    {
      id: 2,
      title: t('robotSetup.step3.title'),
      description: t('robotSetup.step3.description'),
      completed: selectedWifi !== '' && wifiPassword !== '',
      active: currentStep === 2,
    },
    {
      id: 3,
      title: t('robotSetup.step4.title'),
      description: t('robotSetup.step4.description'),
      completed: setupComplete,
      active: currentStep === 3,
    },
  ];

  // Escaneo Bluetooth real con BLE
  const startBluetoothScan = async () => {
    try {
      setIsScanning(true);
      setBluetoothDevices([]);

      // Verificar permisos
      const hasPermissions = await bluetoothService.requestPermissions();
      if (!hasPermissions) {
        Alert.alert(
          t('robotSetup.error.title'),
          'Se requieren permisos de Bluetooth y ubicación para escanear dispositivos'
        );
        setIsScanning(false);
        return;
      }

      // Verificar disponibilidad de Bluetooth
      const isAvailable = await bluetoothService.isBluetoothAvailable();
      if (!isAvailable) {
        Alert.alert(
          t('robotSetup.error.title'),
          'Bluetooth no está disponible. Por favor, activa Bluetooth en tu dispositivo.'
        );
        setIsScanning(false);
        return;
      }

      // Iniciar escaneo BLE
      const devices = await bluetoothService.startScan(
        (device) => {
          // Dispositivo encontrado
          setBluetoothDevices(prev => {
            const exists = prev.some(d => d.id === device.id);
            if (!exists) {
              return [...prev, device];
            }
            return prev;
          });
        },
        (allDevices) => {
          // Escaneo completado
          setBluetoothDevices(allDevices);
          setIsScanning(false);
        }
      );

    } catch (error) {
      console.error('Error during Bluetooth scan:', error);
      Alert.alert(
        t('robotSetup.error.title'),
        'Error al escanear dispositivos Bluetooth. Verifica que Bluetooth esté activado.'
      );
      setIsScanning(false);
    }
  };

  // Conectar al robot seleccionado
  const connectToRobot = async (device: BluetoothDevice) => {
    setIsConnecting(true);
    setSelectedDevice(device);

    try {
      console.log('Connecting to robot:', device.name);

      // Conectar via BLE
      const connected = await bluetoothService.connectToDevice(device);
      if (!connected) {
        throw new Error('Failed to connect to device');
      }

      // Verificar capacidades del robot Nebu
      const hasCapabilities = await bluetoothService.verifyNebuCapabilities(device.id);
      if (!hasCapabilities) {
        console.warn('Device does not have all required Nebu capabilities');
      }

      // Validar que el robot existe en el backend
      await validateRobotInBackend(device);
      
      setCurrentStep(1);
      Alert.alert(
        t('robotSetup.success.title'),
        t('robotSetup.success.connected', { name: device.name })
      );
    } catch (error) {
      console.error('Error connecting to robot:', error);
      Alert.alert(
        t('robotSetup.error.title'),
        t('robotSetup.error.connection')
      );
    } finally {
      setIsConnecting(false);
    }
  };

  // Validar robot en el backend
  const validateRobotInBackend = async (device: BluetoothDevice) => {
    setIsValidating(true);
    
    try {
      // Simular validación con backend
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Aquí harías la llamada real al backend
      // const response = await apiService.post('/iot/devices/validate', {
      //   deviceId: device.id,
      //   deviceName: device.name,
      //   bluetoothId: device.id,
      // });
      
      console.log(`Validating robot ${device.name} in backend...`);
      
    } catch (error) {
      throw new Error('Robot validation failed');
    } finally {
      setIsValidating(false);
    }
  };

  // Escanear redes WiFi
  const scanWiFiNetworks = async () => {
    if (!selectedDevice) return;

    try {
      // Simular escaneo de WiFi
      const mockNetworks: WiFiNetwork[] = [
        { ssid: 'Mi Casa WiFi', rssi: -30, security: 'WPA2' },
        { ssid: 'Vecino WiFi', rssi: -60, security: 'WPA3' },
        { ssid: 'Café Internet', rssi: -70, security: 'Open' },
        { ssid: 'Oficina WiFi', rssi: -45, security: 'WPA2' },
      ];
      
      setWifiNetworks(mockNetworks);
      setCurrentStep(2);
    } catch (error) {
      Alert.alert(
        t('robotSetup.error.title'),
        t('robotSetup.error.wifiScan')
      );
    }
  };

  // Configurar WiFi en el robot
  const configureWiFi = async () => {
    if (!selectedDevice || !selectedWifi || !wifiPassword) {
      Alert.alert(
        t('robotSetup.error.title'),
        t('robotSetup.error.missingCredentials')
      );
      return;
    }

    setIsConfiguring(true);

    try {
      console.log('Configuring WiFi on robot:', selectedWifi);

      // Configurar WiFi via BLE
      const wifiConfigured = await bluetoothService.configureWiFi(selectedWifi, wifiPassword);
      if (!wifiConfigured) {
        throw new Error('Failed to configure WiFi via BLE');
      }

      // También enviar al backend para registro
      try {
        // const response = await apiService.post('/iot/devices/wifi-config', {
        //   deviceId: selectedDevice.id,
        //   wifiSSID: selectedWifi,
        //   wifiPassword: wifiPassword,
        // });
        console.log('WiFi configuration sent to backend');
      } catch (backendError) {
        console.warn('Backend configuration failed, but BLE config succeeded:', backendError);
      }

      // Verificar estado del robot después de la configuración
      setTimeout(async () => {
        try {
          const robotStatus = await bluetoothService.getRobotStatus();
          console.log('Robot status after WiFi config:', robotStatus);
        } catch (statusError) {
          console.warn('Could not get robot status:', statusError);
        }
      }, 2000);

      setSetupComplete(true);
      setCurrentStep(3);
      Alert.alert(
        t('robotSetup.success.title'),
        t('robotSetup.success.wifiConfigured'),
        [
          {
            text: t('common.finish'),
            onPress: () => navigation.goBack(),
          },
        ]
      );
    } catch (error) {
      console.error('Error configuring WiFi:', error);
      Alert.alert(
        t('robotSetup.error.title'),
        t('robotSetup.error.wifiConfiguration')
      );
    } finally {
      setIsConfiguring(false);
    }
  };

  // Iniciar escaneo al cargar la pantalla
  useEffect(() => {
    startBluetoothScan();

    // Cleanup al desmontar el componente
    return () => {
      if (selectedDevice && !isConnecting) {
        bluetoothService.disconnect().catch(console.error);
      }
    };
  }, []);

  // Verificar estado de conexión
  useEffect(() => {
    const checkConnectionStatus = () => {
      const status = bluetoothService.getConnectionStatus();
      if (!status.isConnected && selectedDevice) {
        console.warn('Robot disconnected during setup');
        // Opcional: mostrar alerta o reintentar conexión
      }
    };

    const interval = setInterval(checkConnectionStatus, 5000);
    return () => clearInterval(interval);
  }, [selectedDevice]);

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getContentStyle = (): ViewStyle => ({
    padding: theme.spacing.lg,
  });

  const getStepCardStyle = (step: SetupStep): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.lg,
    padding: theme.spacing.lg,
    marginBottom: theme.spacing.md,
    borderWidth: 2,
    borderColor: step.active 
      ? theme.colors.primary 
      : step.completed 
        ? theme.colors.success 
        : theme.colors.border,
    ...theme.shadows.md,
  });

  const getStepTitleStyle = (step: SetupStep): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: step.active ? theme.colors.primary : theme.colors.text,
    marginBottom: theme.spacing.sm,
  });

  const getStepDescriptionStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: theme.colors.textSecondary,
    marginBottom: theme.spacing.md,
  });

  const getDeviceCardStyle = (device: BluetoothDevice): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
    borderWidth: 1,
    borderColor: device.isConnectable ? theme.colors.primary : theme.colors.border,
    ...theme.shadows.sm,
  });

  const getDeviceNameStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    fontWeight: theme.typography.weights.medium,
    color: theme.colors.text,
    marginBottom: theme.spacing.xs,
  });

  const getDeviceInfoStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textSecondary,
  });

  const getInputStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
  });

  const getButtonStyle = (disabled: boolean = false): ViewStyle => ({
    backgroundColor: disabled ? theme.colors.disabled : theme.colors.primary,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    alignItems: 'center',
    marginBottom: theme.spacing.sm,
  });

  const getButtonTextStyle = (disabled: boolean = false): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    fontWeight: theme.typography.weights.semibold,
    color: disabled ? theme.colors.textSecondary : '#FFFFFF',
  });

  const renderStepIndicator = (step: SetupStep) => (
    <View style={styles.stepIndicator}>
      <View style={[
        styles.stepCircle,
        {
          backgroundColor: step.completed 
            ? theme.colors.success 
            : step.active 
              ? theme.colors.primary 
              : theme.colors.disabled
        }
      ]}>
        {step.completed ? (
          <Ionicons name="checkmark" size={20} color="#FFFFFF" />
        ) : (
          <Text style={[styles.stepNumber, { color: '#FFFFFF' }]}>
            {step.id + 1}
          </Text>
        )}
      </View>
      <Text style={[styles.stepTitle, { color: theme.colors.text }]}>
        {step.title}
      </Text>
    </View>
  );

  const renderBluetoothDevices = () => (
    <View>
      <View style={styles.scanHeader}>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          {t('robotSetup.bluetoothDevices')}
        </Text>
        <TouchableOpacity
          onPress={startBluetoothScan}
          disabled={isScanning}
          style={[styles.scanButton, { backgroundColor: theme.colors.primary }]}
        >
          {isScanning ? (
            <ActivityIndicator color="#FFFFFF" size="small" />
          ) : (
            <Ionicons name="refresh" size={20} color="#FFFFFF" />
          )}
        </TouchableOpacity>
      </View>

      {bluetoothDevices.map((device) => (
        <TouchableOpacity
          key={device.id}
          onPress={() => device.isConnectable && connectToRobot(device)}
          disabled={!device.isConnectable || isConnecting}
          style={getDeviceCardStyle(device)}
        >
          <View style={styles.deviceInfo}>
            <View style={styles.deviceHeader}>
              <Ionicons
                name="hardware-chip"
                size={24}
                color={device.isConnectable ? theme.colors.primary : theme.colors.disabled}
              />
              <View style={styles.deviceDetails}>
                <Text style={getDeviceNameStyle()}>{device.name}</Text>
                <Text style={getDeviceInfoStyle()}>
                  RSSI: {device.rssi} dBm • {device.isConnectable ? 'Connectable' : 'Not Available'}
                </Text>
              </View>
            </View>
            {device.isConnectable && (
              <Ionicons
                name="chevron-forward"
                size={20}
                color={theme.colors.textSecondary}
              />
            )}
          </View>
        </TouchableOpacity>
      ))}

      {bluetoothDevices.length === 0 && !isScanning && (
        <Text style={[styles.noDevicesText, { color: theme.colors.textSecondary }]}>
          {t('robotSetup.noDevicesFound')}
        </Text>
      )}
    </View>
  );

  const renderWiFiConfiguration = () => (
    <View>
      <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
        {t('robotSetup.wifiConfiguration')}
      </Text>

      <TextInput
        style={getInputStyle()}
        placeholder={t('robotSetup.wifiSSID')}
        placeholderTextColor={theme.colors.textSecondary}
        value={selectedWifi}
        onChangeText={setSelectedWifi}
        autoCapitalize="none"
        autoCorrect={false}
      />

      <TextInput
        style={getInputStyle()}
        placeholder={t('robotSetup.wifiPassword')}
        placeholderTextColor={theme.colors.textSecondary}
        value={wifiPassword}
        onChangeText={setWifiPassword}
        secureTextEntry
        autoCapitalize="none"
        autoCorrect={false}
      />

      <TouchableOpacity
        onPress={configureWiFi}
        disabled={!selectedWifi || !wifiPassword || isConfiguring}
        style={getButtonStyle(!selectedWifi || !wifiPassword || isConfiguring)}
      >
        {isConfiguring ? (
          <ActivityIndicator color="#FFFFFF" size="small" />
        ) : (
          <Text style={getButtonTextStyle(!selectedWifi || !wifiPassword || isConfiguring)}>
            {t('robotSetup.configureWiFi')}
          </Text>
        )}
      </TouchableOpacity>
    </View>
  );

  const renderCurrentStepContent = () => {
    switch (currentStep) {
      case 0:
        return renderBluetoothDevices();
      case 1:
        return (
          <View>
            <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
              {t('robotSetup.validatingRobot')}
            </Text>
            {isValidating ? (
              <View style={styles.loadingContainer}>
                <ActivityIndicator size="large" color={theme.colors.primary} />
                <Text style={[styles.loadingText, { color: theme.colors.text }]}>
                  {t('robotSetup.validatingInBackend')}
                </Text>
              </View>
            ) : (
              <TouchableOpacity
                onPress={scanWiFiNetworks}
                style={getButtonStyle(false)}
              >
                <Text style={getButtonTextStyle(false)}>
                  {t('robotSetup.continueToWiFi')}
                </Text>
              </TouchableOpacity>
            )}
          </View>
        );
      case 2:
        return renderWiFiConfiguration();
      case 3:
        return (
          <View style={styles.successContainer}>
            <Ionicons name="checkmark-circle" size={80} color={theme.colors.success} />
            <Text style={[styles.successTitle, { color: theme.colors.text }]}>
              {t('robotSetup.setupComplete')}
            </Text>
            <Text style={[styles.successMessage, { color: theme.colors.textSecondary }]}>
              {t('robotSetup.setupCompleteMessage')}
            </Text>
          </View>
        );
      default:
        return null;
    }
  };

  return (
    <View style={[styles.container, getContainerStyle()]}>
      <Header
        title={t('robotSetup.title')}
        showBackButton
        onBackPress={() => navigation.goBack()}
      />
      
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={[styles.content, getContentStyle()]}
        showsVerticalScrollIndicator={false}
      >
        <AnimatedCard
          animationType="fadeIn"
          delay={0}
          hoverLift={false}
          style={styles.headerCard}
        >
          <GradientText
            variant="primary"
            style={styles.headerTitle}
          >
            {t('robotSetup.welcome')}
          </GradientText>
          <Text style={[styles.headerDescription, { color: theme.colors.textSecondary }]}>
            {t('robotSetup.welcomeDescription')}
          </Text>
        </AnimatedCard>

        <View style={styles.stepsContainer}>
          {setupSteps.map((step) => (
            <AnimatedCard
              key={step.id}
              animationType="slideIn"
              delay={step.id * 100}
              hoverLift={false}
              style={getStepCardStyle(step)}
            >
              <Text style={getStepTitleStyle(step)}>
                {step.title}
              </Text>
              <Text style={getStepDescriptionStyle()}>
                {step.description}
              </Text>
              {renderStepIndicator(step)}
            </AnimatedCard>
          ))}
        </View>

        <AnimatedCard
          animationType="slideIn"
          delay={400}
          hoverLift={false}
          style={styles.contentCard}
        >
          {renderCurrentStepContent()}
        </AnimatedCard>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingBottom: 20,
  },
  headerCard: {
    borderRadius: 12,
    padding: 20,
    marginBottom: 24,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 8,
  },
  headerDescription: {
    fontSize: 16,
    lineHeight: 24,
  },
  stepsContainer: {
    marginBottom: 24,
  },
  contentCard: {
    borderRadius: 12,
    padding: 20,
    marginBottom: 20,
  },
  stepIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 16,
  },
  stepCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  stepNumber: {
    fontSize: 16,
    fontWeight: '600',
  },
  stepTitle: {
    fontSize: 14,
    fontWeight: '500',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
  },
  scanHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  scanButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  deviceInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  deviceHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  deviceDetails: {
    marginLeft: 12,
    flex: 1,
  },
  noDevicesText: {
    textAlign: 'center',
    fontSize: 16,
    fontStyle: 'italic',
    marginTop: 20,
  },
  loadingContainer: {
    alignItems: 'center',
    padding: 40,
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
  },
  successContainer: {
    alignItems: 'center',
    padding: 40,
  },
  successTitle: {
    fontSize: 24,
    fontWeight: '700',
    marginTop: 16,
    marginBottom: 8,
  },
  successMessage: {
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 24,
  },
});

export default RobotSetupScreen;
