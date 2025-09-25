import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { Header, Button, AnimatedCard, StatusBadge, FloatingActionButton } from '@/components';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';
import { robotService, RobotDevice } from '@/services/robotService';
import { bluetoothService } from '@/services/bluetoothService';

const DeviceManagementScreen: React.FC = () => {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const [devices, setDevices] = useState<RobotDevice[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [selectedDevice, setSelectedDevice] = useState<RobotDevice | null>(null);

  useEffect(() => {
    loadDevices();
  }, []);

  const loadDevices = async () => {
    try {
      setIsLoading(true);
      const userDevices = await robotService.getUserRobots();
      setDevices(userDevices);
    } catch (error) {
      console.error('Error loading devices:', error);
      Alert.alert(
        t('deviceManagement.error.title'),
        t('deviceManagement.error.loadDevices')
      );
    } finally {
      setIsLoading(false);
    }
  };

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await loadDevices();
    setIsRefreshing(false);
  };

  const handleAddDevice = () => {
    // Navegar al escáner QR
    (navigation as any).navigate('QRScanner');
  };

  const handleDevicePress = (device: RobotDevice) => {
    setSelectedDevice(device);
    // Navegar a configuración del dispositivo
    (navigation as any).navigate('DeviceSetup', { device });
  };

  const handleConnectDevice = async (device: RobotDevice) => {
    try {
      // Verificar si Bluetooth está disponible
      const isAvailable = await bluetoothService.isBluetoothAvailable();
      if (!isAvailable) {
        Alert.alert(
          t('deviceManagement.error.title'),
          t('deviceManagement.error.bluetoothNotAvailable')
        );
        return;
      }

      // Escanear dispositivos Bluetooth
      const bluetoothDevices = await bluetoothService.startScan();
      const matchingDevice = bluetoothDevices.find(bd => 
        bd.name.includes(device.name) || bd.id === device.bluetoothId
      );

      if (matchingDevice) {
        // Conectar al dispositivo
        const connected = await bluetoothService.connectToDevice(matchingDevice);
        if (connected) {
          Alert.alert(
            t('deviceManagement.success.title'),
            t('deviceManagement.success.connected', { name: device.name })
          );
        } else {
          throw new Error('Connection failed');
        }
      } else {
        Alert.alert(
          t('deviceManagement.error.title'),
          t('deviceManagement.error.deviceNotFound')
        );
      }
    } catch (error) {
      console.error('Error connecting to device:', error);
      Alert.alert(
        t('deviceManagement.error.title'),
        t('deviceManagement.error.connectionFailed')
      );
    }
  };

  const handleDeleteDevice = (device: RobotDevice) => {
    Alert.alert(
      t('deviceManagement.delete.title'),
      t('deviceManagement.delete.message', { name: device.name }),
      [
        {
          text: t('common.cancel'),
          style: 'cancel',
        },
        {
          text: t('common.delete'),
          style: 'destructive',
          onPress: async () => {
            try {
              const success = await robotService.deleteRobot(device.id);
              if (success) {
                await loadDevices();
                Alert.alert(
                  t('deviceManagement.success.title'),
                  t('deviceManagement.success.deleted', { name: device.name })
                );
              }
            } catch (error) {
              console.error('Error deleting device:', error);
              Alert.alert(
                t('deviceManagement.error.title'),
                t('deviceManagement.error.deleteFailed')
              );
            }
          },
        },
      ]
    );
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'online':
        return theme.colors.success;
      case 'offline':
        return theme.colors.textSecondary;
      case 'setup':
        return theme.colors.warning;
      case 'error':
        return theme.colors.error;
      default:
        return theme.colors.textSecondary;
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'online':
        return t('deviceManagement.status.online');
      case 'offline':
        return t('deviceManagement.status.offline');
      case 'setup':
        return t('deviceManagement.status.setup');
      case 'error':
        return t('deviceManagement.status.error');
      default:
        return t('deviceManagement.status.unknown');
    }
  };

  const renderDeviceCard = (device: RobotDevice) => (
    <AnimatedCard
      key={device.id}
      animationType="slideIn"
      delay={devices.indexOf(device) * 100}
      hoverLift={true}
      style={StyleSheet.flatten([styles.deviceCard, { backgroundColor: theme.colors.surface }])}
    >
      <TouchableOpacity
        onPress={() => handleDevicePress(device)}
        style={styles.deviceContent}
      >
        <View style={styles.deviceHeader}>
          <View style={styles.deviceInfo}>
            <Ionicons
              name="hardware-chip"
              size={24}
              color={theme.colors.primary}
            />
            <View style={styles.deviceDetails}>
              <Text style={[styles.deviceName, { color: theme.colors.text }]}>
                {device.name}
              </Text>
              <Text style={[styles.deviceModel, { color: theme.colors.textSecondary }]}>
                {device.model} • {device.serialNumber}
              </Text>
            </View>
          </View>
          <StatusBadge
            status={device.status}
            color={getStatusColor(device.status)}
            text={getStatusText(device.status)}
          />
        </View>

        <View style={styles.deviceStats}>
          <View style={styles.statItem}>
            <Ionicons name="time-outline" size={16} color={theme.colors.textSecondary} />
            <Text style={[styles.statText, { color: theme.colors.textSecondary }]}>
              {new Date(device.lastSeen).toLocaleDateString()}
            </Text>
          </View>
          <View style={styles.statItem}>
            <Ionicons name="code-outline" size={16} color={theme.colors.textSecondary} />
            <Text style={[styles.statText, { color: theme.colors.textSecondary }]}>
              v{device.firmwareVersion}
            </Text>
          </View>
        </View>

        <View style={styles.deviceActions}>
          <TouchableOpacity
            style={[styles.actionButton, { backgroundColor: theme.colors.primary }]}
            onPress={() => handleConnectDevice(device)}
          >
            <Ionicons name="bluetooth" size={16} color="white" />
            <Text style={styles.actionButtonText}>
              {t('deviceManagement.actions.connect')}
            </Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={[styles.actionButton, styles.secondaryButton, { borderColor: theme.colors.border }]}
            onPress={() => handleDeleteDevice(device)}
          >
            <Ionicons name="trash-outline" size={16} color={theme.colors.error} />
            <Text style={[styles.actionButtonText, { color: theme.colors.error }]}>
              {t('common.delete')}
            </Text>
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    </AnimatedCard>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Ionicons name="hardware-chip-outline" size={64} color={theme.colors.textSecondary} />
      <Text style={[styles.emptyTitle, { color: theme.colors.text }]}>
        {t('deviceManagement.empty.title')}
      </Text>
      <Text style={[styles.emptyMessage, { color: theme.colors.textSecondary }]}>
        {t('deviceManagement.empty.message')}
      </Text>
      <Button
        title={t('deviceManagement.empty.addDevice')}
        onPress={handleAddDevice}
        style={styles.addDeviceButton}
      />
    </View>
  );

  if (isLoading) {
    return (
      <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
        <Header title={t('deviceManagement.title')} />
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
          <Text style={[styles.loadingText, { color: theme.colors.text }]}>
            {t('deviceManagement.loading')}
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <Header title={t('deviceManagement.title')} />
      
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={handleRefresh}
            tintColor={theme.colors.primary}
          />
        }
      >
        {devices.length === 0 ? (
          renderEmptyState()
        ) : (
          <>
            <View style={styles.sectionHeader}>
              <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
                {t('deviceManagement.myDevices')} ({devices.length})
              </Text>
            </View>
            
            {devices.map(renderDeviceCard)}
          </>
        )}
      </ScrollView>

      {devices.length > 0 && (
        <FloatingActionButton
          icon="add"
          onPress={handleAddDevice}
          style={styles.fab}
        />
      )}
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
  },
  sectionHeader: {
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  deviceCard: {
    marginBottom: 16,
    borderRadius: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  deviceContent: {
    padding: 16,
  },
  deviceHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
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
  deviceModel: {
    fontSize: 14,
  },
  deviceStats: {
    flexDirection: 'row',
    marginBottom: 16,
    gap: 16,
  },
  statItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  statText: {
    fontSize: 12,
  },
  deviceActions: {
    flexDirection: 'row',
    gap: 8,
  },
  actionButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    gap: 4,
  },
  secondaryButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
  },
  actionButtonText: {
    fontSize: 12,
    fontWeight: '600',
    color: 'white',
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 64,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 8,
    textAlign: 'center',
  },
  emptyMessage: {
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 32,
  },
  addDeviceButton: {
    paddingHorizontal: 32,
  },
  fab: {
    position: 'absolute',
    bottom: 20,
    right: 20,
  },
});

export default DeviceManagementScreen;

