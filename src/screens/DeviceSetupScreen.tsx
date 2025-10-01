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
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Header, Button, AnimatedCard, StatusBadge } from '@/components';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';
import { bluetoothService, BluetoothDevice } from '@/services/bluetoothService';
import { robotService, RobotDevice } from '@/services/robotService';
import { wifiService, WiFiNetwork } from '@/services/wifiService';

interface DeviceSetupScreenProps {
  device: RobotDevice;
}

const DeviceSetupScreen: React.FC = () => {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const route = useRoute();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const { device } = route.params as DeviceSetupScreenProps;

  const [currentStep, setCurrentStep] = useState(0);
  const [isScanning, setIsScanning] = useState(false);
  const [bluetoothDevices, setBluetoothDevices] = useState<BluetoothDevice[]>([]);
  const [selectedBluetoothDevice, setSelectedBluetoothDevice] = useState<BluetoothDevice | null>(null);
  const [isConnecting, setIsConnecting] = useState(false);
  const [wifiNetworks, setWifiNetworks] = useState<WiFiNetwork[]>([]);
  const [selectedWifi, setSelectedWifi] = useState<string>('');
  const [wifiPassword, setWifiPassword] = useState('');
  const [isConfiguring, setIsConfiguring] = useState(false);
  const [setupComplete, setSetupComplete] = useState(false);

  const setupSteps = [
    {
      id: 0,
      title: t('deviceSetup.step1.title'),
      description: t('deviceSetup.step1.description'),
      completed: selectedBluetoothDevice !== null,
      active: currentStep === 0,
    },
    {
      id: 1,
      title: t('deviceSetup.step2.title'),
      description: t('deviceSetup.step2.description'),
      completed: selectedBluetoothDevice !== null && !isConnecting,
      active: currentStep === 1,
    },
    {
      id: 2,
      title: t('deviceSetup.step3.title'),
      description: t('deviceSetup.step3.description'),
      completed: selectedWifi !== '' && wifiPassword !== '',
      active: currentStep === 2,
    },
    {
      id: 3,
      title: t('deviceSetup.step4.title'),
      description: t('deviceSetup.step4.description'),
      completed: setupComplete,
      active: currentStep === 3,
    },
  ];

  useEffect(() => {
    // Iniciar escaneo Bluetooth automáticamente
    startBluetoothScan();
  }, []);

  const startBluetoothScan = async () => {
    try {
      setIsScanning(true);
      setBluetoothDevices([]);

      // Verificar permisos
      const hasPermissions = await bluetoothService.requestPermissions();
      if (!hasPermissions) {
        Alert.alert(
          t('deviceSetup.error.title'),
          t('deviceSetup.error.permissionsRequired')
        );
        setIsScanning(false);
        return;
      }

      // Verificar disponibilidad de Bluetooth
      const isAvailable = await bluetoothService.isBluetoothAvailable();
      if (!isAvailable) {
        Alert.alert(
          t('deviceSetup.error.title'),
          t('deviceSetup.error.bluetoothNotAvailable')
        );
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
      Alert.alert(
        t('deviceSetup.error.title'),
        t('deviceSetup.error.scanFailed')
      );
      setIsScanning(false);
    }
  };

  const handleBluetoothDeviceSelect = async (bluetoothDevice: BluetoothDevice) => {
    setIsConnecting(true);
    setSelectedBluetoothDevice(bluetoothDevice);

    try {
      // Conectar al dispositivo Bluetooth
      const connected = await bluetoothService.connectToDevice(bluetoothDevice);
      if (!connected) {
        throw new Error('Failed to connect to device');
      }

      // Verificar capacidades del dispositivo
      const hasCapabilities = await bluetoothService.verifyNebuCapabilities(bluetoothDevice.id);
      if (!hasCapabilities) {
        console.warn('Device does not have all required capabilities');
      }

      setCurrentStep(1);
      Alert.alert(
        t('deviceSetup.success.title'),
        t('deviceSetup.success.connected', { name: bluetoothDevice.name })
      );

    } catch (error) {
      console.error('Error connecting to device:', error);
      Alert.alert(
        t('deviceSetup.error.title'),
        t('deviceSetup.error.connectionFailed')
      );
      setSelectedBluetoothDevice(null);
    } finally {
      setIsConnecting(false);
    }
  };

  const scanWiFiNetworks = async () => {
    try {
      setCurrentStep(2);
      
      // Simular escaneo de redes WiFi
      // En una implementación real, esto se haría via Bluetooth
      const mockNetworks: WiFiNetwork[] = [
        { ssid: 'Mi_WiFi_5G', security: 'WPA2', rssi: -45, frequency: 5000 },
        { ssid: 'Mi_WiFi', security: 'WPA2', rssi: -60, frequency: 2400 },
        { ssid: 'Vecino_WiFi', security: 'WPA2', rssi: -75, frequency: 2400 },
        { ssid: 'Cafe_Libre', security: 'Open', rssi: -80, frequency: 2400 },
      ];

      setWifiNetworks(mockNetworks);
      
    } catch (error) {
      console.error('Error scanning WiFi networks:', error);
      Alert.alert(
        t('deviceSetup.error.title'),
        t('deviceSetup.error.wifiScanFailed')
      );
    }
  };

  const handleWiFiSelect = (ssid: string) => {
    setSelectedWifi(ssid);
    setWifiPassword('');
  };

  const configureWiFi = async () => {
    if (!selectedWifi || !wifiPassword) {
      Alert.alert(
        t('deviceSetup.error.title'),
        t('deviceSetup.error.wifiCredentialsRequired')
      );
      return;
    }

    setIsConfiguring(true);

    try {
      // Configurar WiFi via Bluetooth
      const success = await bluetoothService.configureWiFi(selectedWifi, wifiPassword);
      if (!success) {
        throw new Error('WiFi configuration failed');
      }

      // Actualizar estado del dispositivo
      await robotService.updateRobot(device.id, {
        status: 'online',
      });

      setSetupComplete(true);
      setCurrentStep(3);

      Alert.alert(
        t('deviceSetup.success.title'),
        t('deviceSetup.success.wifiConfigured'),
        [
          {
            text: t('common.continue'),
            onPress: () => {
              // Navegar de vuelta a la gestión de dispositivos
              navigation.navigate('DeviceManagement' as never);
            },
          },
        ]
      );

    } catch (error) {
      console.error('Error configuring WiFi:', error);
      Alert.alert(
        t('deviceSetup.error.title'),
        t('deviceSetup.error.wifiConfigurationFailed')
      );
    } finally {
      setIsConfiguring(false);
    }
  };

  const renderStepIndicator = () => (
    <View style={styles.stepIndicator}>
      {setupSteps.map((step, index) => (
        <View key={step.id} style={styles.stepItem}>
          <View
            style={[
              styles.stepCircle,
              {
                backgroundColor: step.completed
                  ? theme.colors.success
                  : step.active
                  ? theme.colors.primary
                  : theme.colors.border,
              },
            ]}
          >
            {step.completed ? (
              <Ionicons name="checkmark" size={16} color="white" />
            ) : (
              <Text style={[styles.stepNumber, { color: 'white' }]}>
                {step.id + 1}
              </Text>
            )}
          </View>
          <View style={styles.stepContent}>
            <Text style={[styles.stepTitle, { color: theme.colors.text }]}>
              {step.title}
            </Text>
            <Text style={[styles.stepDescription, { color: theme.colors.textSecondary }]}>
              {step.description}
            </Text>
          </View>
        </View>
      ))}
    </View>
  );

  const renderBluetoothDevices = () => (
    <View style={styles.section}>
      <View style={styles.sectionHeader}>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
          {t('deviceSetup.bluetoothDevices')}
        </Text>
        <TouchableOpacity
          onPress={startBluetoothScan}
          disabled={isScanning}
          style={[styles.scanButton, { backgroundColor: theme.colors.primary }]}
        >
          {isScanning ? (
            <ActivityIndicator color="white" size="small" />
          ) : (
            <Ionicons name="refresh" size={20} color="white" />
          )}
        </TouchableOpacity>
      </View>

      {bluetoothDevices.map((bluetoothDevice) => (
        <TouchableOpacity
          key={bluetoothDevice.id}
          onPress={() => handleBluetoothDeviceSelect(bluetoothDevice)}
          disabled={!bluetoothDevice.isConnectable || isConnecting}
          style={[
            styles.deviceCard,
            {
              backgroundColor: theme.colors.surface,
              borderColor: selectedBluetoothDevice?.id === bluetoothDevice.id
                ? theme.colors.primary
                : theme.colors.border,
            },
          ]}
        >
          <View style={styles.deviceDetails}>
            <Ionicons
              name="bluetooth"
              size={24}
              color={bluetoothDevice.isConnectable ? theme.colors.primary : theme.colors.disabled}
            />
            <View style={styles.deviceDetails}>
              <Text style={[styles.deviceName, { color: theme.colors.text }]}>
                {bluetoothDevice.name}
              </Text>
              <Text style={[styles.deviceInfoText, { color: theme.colors.textSecondary }]}>
                RSSI: {bluetoothDevice.rssi} dBm
              </Text>
            </View>
          </View>
          {bluetoothDevice.isConnectable && (
            <Ionicons
              name="chevron-forward"
              size={20}
              color={theme.colors.textSecondary}
            />
          )}
        </TouchableOpacity>
      ))}

      {bluetoothDevices.length === 0 && !isScanning && (
        <View style={styles.emptyState}>
          <Ionicons name="bluetooth-outline" size={48} color={theme.colors.textSecondary} />
          <Text style={[styles.emptyText, { color: theme.colors.textSecondary }]}>
            {t('deviceSetup.noDevicesFound')}
          </Text>
        </View>
      )}
    </View>
  );

  const renderWiFiNetworks = () => (
    <View style={styles.section}>
      <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
        {t('deviceSetup.wifiNetworks')}
      </Text>

      {wifiNetworks.map((network) => (
        <TouchableOpacity
          key={network.ssid}
          onPress={() => handleWiFiSelect(network.ssid)}
          style={[
            styles.wifiCard,
            {
              backgroundColor: theme.colors.surface,
              borderColor: selectedWifi === network.ssid
                ? theme.colors.primary
                : theme.colors.border,
            },
          ]}
        >
          <View style={styles.wifiInfo}>
            <Ionicons
              name="wifi"
              size={24}
              color={theme.colors.primary}
            />
            <View style={styles.wifiDetails}>
              <Text style={[styles.wifiSSID, { color: theme.colors.text }]}>
                {network.ssid}
              </Text>
              <Text style={[styles.wifiSecurity, { color: theme.colors.textSecondary }]}>
                {network.security}
              </Text>
            </View>
          </View>
          {selectedWifi === network.ssid && (
            <Ionicons name="checkmark-circle" size={24} color={theme.colors.primary} />
          )}
        </TouchableOpacity>
      ))}

      {selectedWifi && (
        <View style={styles.passwordSection}>
          <Text style={[styles.passwordLabel, { color: theme.colors.text }]}>
            {t('deviceSetup.wifiPassword')}
          </Text>
          <TextInput
            style={[styles.passwordInput, { 
              backgroundColor: theme.colors.surface,
              borderColor: theme.colors.border,
              color: theme.colors.text,
            }]}
            value={wifiPassword}
            onChangeText={setWifiPassword}
            placeholder={t('deviceSetup.wifiPasswordPlaceholder')}
            placeholderTextColor={theme.colors.textSecondary}
            secureTextEntry
            autoCapitalize="none"
          />
        </View>
      )}
    </View>
  );

  const renderCurrentStep = () => {
    switch (currentStep) {
      case 0:
        return renderBluetoothDevices();
      case 1:
        return (
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
              {t('deviceSetup.connecting')}
            </Text>
            <View style={styles.connectingContainer}>
              <ActivityIndicator size="large" color={theme.colors.primary} />
              <Text style={[styles.connectingText, { color: theme.colors.text }]}>
                {t('deviceSetup.connectingToDevice', { name: selectedBluetoothDevice?.name })}
              </Text>
            </View>
          </View>
        );
      case 2:
        return renderWiFiNetworks();
      case 3:
        return (
          <View style={styles.section}>
            <View style={styles.successContainer}>
              <Ionicons name="checkmark-circle" size={64} color={theme.colors.success} />
              <Text style={[styles.successTitle, { color: theme.colors.text }]}>
                {t('deviceSetup.success.title')}
              </Text>
              <Text style={[styles.successMessage, { color: theme.colors.textSecondary }]}>
                {t('deviceSetup.success.setupComplete', { name: device.name })}
              </Text>
            </View>
          </View>
        );
      default:
        return null;
    }
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Header 
        title={t('deviceSetup.title')}
      />
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        {renderStepIndicator()}
        {renderCurrentStep()}
        
        {currentStep === 2 && selectedWifi && wifiPassword && (
          <Button
            title={t('deviceSetup.configureWiFi')}
            onPress={configureWiFi}
            loading={isConfiguring}
            style={styles.configureButton}
          />
        )}
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
  scrollContent: {
    padding: 16,
  },
  stepIndicator: {
    marginBottom: 24,
  },
  stepItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
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
    fontSize: 14,
    fontWeight: '600',
  },
  stepContent: {
    flex: 1,
  },
  stepTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  stepDescription: {
    fontSize: 14,
    lineHeight: 20,
  },
  section: {
    marginBottom: 24,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  scanButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  deviceCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    borderWidth: 2,
    marginBottom: 8,
  },
  deviceInfo: {
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
    fontWeight: '600',
    marginBottom: 4,
  },
  deviceInfoText: {
    fontSize: 14,
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 32,
  },
  emptyText: {
    marginTop: 8,
    fontSize: 16,
    textAlign: 'center',
  },
  connectingContainer: {
    alignItems: 'center',
    paddingVertical: 32,
  },
  connectingText: {
    marginTop: 16,
    fontSize: 16,
    textAlign: 'center',
  },
  wifiCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    borderWidth: 2,
    marginBottom: 8,
  },
  wifiInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  wifiDetails: {
    marginLeft: 12,
    flex: 1,
  },
  wifiSSID: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  wifiSecurity: {
    fontSize: 14,
  },
  passwordSection: {
    marginTop: 16,
  },
  passwordLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  passwordInput: {
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 12,
    fontSize: 16,
  },
  successContainer: {
    alignItems: 'center',
    paddingVertical: 32,
  },
  successTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 8,
    textAlign: 'center',
  },
  successMessage: {
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 24,
  },
  configureButton: {
    marginTop: 16,
  },
});

export default DeviceSetupScreen;

