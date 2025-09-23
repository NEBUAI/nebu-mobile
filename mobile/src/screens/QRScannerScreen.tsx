import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';
import { Header } from '@/components';
import QRCodeScanner from '@/components/QRCodeScanner';
import { robotService } from '@/services/robotService';

const QRScannerScreen: React.FC = () => {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const [isProcessing, setIsProcessing] = useState(false);

  const handleQRScanned = async (data: string) => {
    if (isProcessing) return;
    
    setIsProcessing(true);
    
    try {
      console.log('Processing QR data:', data);
      
      // Extraer device_id del QR
      const deviceId = extractDeviceId(data);
      if (!deviceId) {
        throw new Error('Invalid QR format');
      }

      // Validar que el dispositivo existe en el backend
      const validationResponse = await robotService.validateRobot({
        deviceId,
        deviceName: `Device-${deviceId}`,
        bluetoothId: deviceId,
      });

      if (!validationResponse.isValid) {
        Alert.alert(
          t('qrScanner.error.title'),
          t('qrScanner.error.deviceNotFound'),
          [
            {
              text: t('common.tryAgain'),
              onPress: () => setIsProcessing(false),
            },
            {
              text: t('common.cancel'),
              onPress: () => navigation.goBack(),
            },
          ]
        );
        return;
      }

      // Registrar el dispositivo al usuario
      const registeredDevice = await robotService.registerRobot({
        id: deviceId,
        name: `NEBU-${deviceId}`,
        model: 'NEBU-Robot-v1.0',
        serialNumber: deviceId,
        bluetoothId: deviceId,
        status: 'setup',
      });

      Alert.alert(
        t('qrScanner.success.title'),
        t('qrScanner.success.deviceRegistered', { name: registeredDevice.name }),
        [
          {
            text: t('common.continue'),
            onPress: () => {
              // Navegar a configuración del dispositivo
              navigation.navigate('DeviceSetup' as never, { device: registeredDevice } as never);
            },
          },
        ]
      );

    } catch (error) {
      console.error('Error processing QR:', error);
      Alert.alert(
        t('qrScanner.error.title'),
        t('qrScanner.error.processingFailed'),
        [
          {
            text: t('common.tryAgain'),
            onPress: () => setIsProcessing(false),
          },
          {
            text: t('common.cancel'),
            onPress: () => navigation.goBack(),
          },
        ]
      );
    }
  };

  const extractDeviceId = (data: string): string | null => {
    // Extraer device_id del QR
    // Formato esperado: "NEBU-XXXX-XXXX" o similar
    const match = data.match(/^([A-Z0-9]{4}-[A-Z0-9]{4})$/);
    return match ? match[1] : null;
  };

  const handleClose = () => {
    navigation.goBack();
  };

  if (isProcessing) {
    return (
      <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
        <Header title={t('qrScanner.title')} onBack={handleClose} />
        <View style={styles.processingContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
          <Text style={[styles.processingText, { color: theme.colors.text }]}>
            {t('qrScanner.processing')}
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <QRCodeScanner
        onQRScanned={handleQRScanned}
        onClose={handleClose}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  processingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  processingText: {
    marginTop: 16,
    fontSize: 16,
    textAlign: 'center',
  },
});

export default QRScannerScreen;
