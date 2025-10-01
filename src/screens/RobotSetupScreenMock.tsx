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
import { bluetoothService, BluetoothDevice } from '@/services/bluetoothServiceMock';

// Tipos para el estado del setup
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

const RobotSetupScreenMock: React.FC = () => {
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
  const [selectedWifi, setSelectedWifi] = useState<string>('');
  const [wifiPassword, setWifiPassword] = useState('');
  const [isConfiguring, setIsConfiguring] = useState(false);
  const [setupComplete, setSetupComplete] = useState(false);

  // Pasos del setup
  const setupSteps: SetupStep[] = [
    {
      id: 0,
      title: 'Detectar Robot',
      description: 'Escanea y conecta con tu robot Nebu mediante Bluetooth',
      completed: selectedDevice !== null,
      active: currentStep === 0,
    },
    {
      id: 1,
      title: 'Validar Robot',
      description: 'Verificar que el robot existe en nuestro sistema',
      completed: selectedDevice !== null && !isValidating,
      active: currentStep === 1,
    },
    {
      id: 2,
      title: 'Configurar WiFi',
      description: 'Conecta el robot a tu red WiFi',
      completed: selectedWifi !== '' && wifiPassword !== '',
      active: currentStep === 2,
    },
    {
      id: 3,
      title: '¡Listo!',
      description: 'Tu robot Nebu está configurado y listo para usar',
      completed: setupComplete,
      active: currentStep === 3,
    },
  ];

  // Escaneo Bluetooth con servicio mock
  const startBluetoothScan = async () => {
    try {
      setIsScanning(true);
      setBluetoothDevices([]);

      // Verificar permisos
      const hasPermissions = await bluetoothService.requestPermissions();
      if (!hasPermissions) {
        Alert.alert('Error', 'Se requieren permisos de Bluetooth');
        setIsScanning(false);
        return;
      }

      // Verificar disponibilidad de Bluetooth
      const isAvailable = await bluetoothService.isBluetoothAvailable();
      if (!isAvailable) {
        Alert.alert('Error', 'Bluetooth no está disponible');
        setIsScanning(false);
        return;
      }

      // Iniciar escaneo BLE
      const devices = await bluetoothService.startScan(
        (device) => {
          setBluetoothDevices(prev => {
            const exists = prev.some(d => d.id === device.id);
            if (!exists) {
              return [...prev, device];
            }
            return prev;
          });
        },
        (allDevices) => {
          setBluetoothDevices(allDevices);
          setIsScanning(false);
        }
      );

    } catch (error) {
      console.error('Error during Bluetooth scan:', error);
      Alert.alert('Error', 'Error al escanear dispositivos Bluetooth');
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

      setCurrentStep(1);
      Alert.alert('¡Éxito!', `Conectado exitosamente a ${device.name}`);
    } catch (error) {
      console.error('Error connecting to robot:', error);
      Alert.alert('Error', 'No se pudo conectar al robot');
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
      console.log(`Validating robot ${device.name} in backend...`);
    } catch (error) {
      throw new Error('Robot validation failed');
    } finally {
      setIsValidating(false);
    }
  };

  // Configurar WiFi en el robot
  const configureWiFi = async () => {
    if (!selectedDevice || !selectedWifi || !wifiPassword) {
      Alert.alert('Error', 'Por favor completa todos los campos de WiFi');
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

      setSetupComplete(true);
      setCurrentStep(3);
      Alert.alert(
        '¡Éxito!',
        'WiFi configurado correctamente. El robot está conectado a internet.',
        [
          {
            text: 'Finalizar',
            onPress: () => navigation.goBack(),
          },
        ]
      );
    } catch (error) {
      console.error('Error configuring WiFi:', error);
      Alert.alert('Error', 'Error al configurar WiFi');
    } finally {
      setIsConfiguring(false);
    }
  };

  // Iniciar escaneo al cargar la pantalla
  useEffect(() => {
    startBluetoothScan();

    // Cleanup al desmontar el componente
    return () => {
      if (selectedDevice) {
        bluetoothService.disconnect().catch(console.error);
      }
    };
  }, []);

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getContentStyle = (): ViewStyle => ({
    padding: theme.spacing.lg,
  });

  const renderBluetoothDevices = () => (
    <View>
      <View style={styles.scanHeader}>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          Dispositivos Bluetooth
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
          style={[styles.deviceCard, { backgroundColor: theme.colors.card }]}
        >
          <View style={styles.deviceInfo}>
            <View style={styles.deviceHeader}>
              <Ionicons
                name="hardware-chip"
                size={24}
                color={device.isConnectable ? theme.colors.primary : theme.colors.disabled}
              />
              <View style={styles.deviceDetails}>
                <Text style={[styles.deviceName, { color: theme.colors.text }]}>{device.name}</Text>
                <Text style={[styles.deviceInfo, { color: theme.colors.textSecondary }]}>
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
          No se encontraron dispositivos Nebu
        </Text>
      )}
    </View>
  );

  const renderWiFiConfiguration = () => (
    <View>
      <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
        Configuración de WiFi
      </Text>

      <TextInput
        style={[styles.input, { backgroundColor: theme.colors.card, color: theme.colors.text }]}
        placeholder="Nombre de la red WiFi (SSID)"
        placeholderTextColor={theme.colors.textSecondary}
        value={selectedWifi}
        onChangeText={setSelectedWifi}
        autoCapitalize="none"
        autoCorrect={false}
      />

      <TextInput
        style={[styles.input, { backgroundColor: theme.colors.card, color: theme.colors.text }]}
        placeholder="Contraseña de WiFi"
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
        style={[styles.button, { backgroundColor: theme.colors.primary }]}
      >
        {isConfiguring ? (
          <ActivityIndicator color="#FFFFFF" size="small" />
        ) : (
          <Text style={styles.buttonText}>Configurar WiFi</Text>
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
              Validando Robot
            </Text>
            {isValidating ? (
              <View style={styles.loadingContainer}>
                <ActivityIndicator size="large" color={theme.colors.primary} />
                <Text style={[styles.loadingText, { color: theme.colors.text }]}>
                  Verificando robot en el servidor...
                </Text>
              </View>
            ) : (
              <TouchableOpacity
                onPress={() => setCurrentStep(2)}
                style={[styles.button, { backgroundColor: theme.colors.primary }]}
              >
                <Text style={styles.buttonText}>Continuar a WiFi</Text>
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
              ¡Configuración Completada!
            </Text>
            <Text style={[styles.successMessage, { color: theme.colors.textSecondary }]}>
              Tu robot Nebu está ahora conectado y listo para usar.
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
        title="Configurar Robot Nebu"
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
            ¡Bienvenido a Nebu!
          </GradientText>
          <Text style={[styles.headerDescription, { color: theme.colors.textSecondary }]}>
            Configura tu robot Nebu para conectarlo a tu red WiFi y comenzar a usarlo
          </Text>
        </AnimatedCard>

        <AnimatedCard
          animationType="slideIn"
          delay={400}
          hoverLift={false}
          style={[styles.contentCard, { backgroundColor: theme.colors.card }] as any}
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
  contentCard: {
    borderRadius: 12,
    padding: 20,
    marginBottom: 20,
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
  deviceCard: {
    borderRadius: 8,
    padding: 16,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#E0E0E0',
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
  deviceName: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 4,
  },
  noDevicesText: {
    textAlign: 'center',
    fontSize: 16,
    fontStyle: 'italic',
    marginTop: 20,
  },
  input: {
    borderRadius: 8,
    padding: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    fontSize: 16,
  },
  button: {
    borderRadius: 8,
    padding: 16,
    alignItems: 'center',
    marginBottom: 8,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
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

export default RobotSetupScreenMock;
