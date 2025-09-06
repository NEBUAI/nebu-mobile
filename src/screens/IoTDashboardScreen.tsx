// @ts-nocheck
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { Header, Button } from '@/components';
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { setDevices, setLoading, setError, IoTDevice } from '@/store/iotSlice';
import { getTheme } from '@/utils/theme';

const IoTDashboardScreen: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const { devices, metrics, isLoading, error } = useAppSelector((state) => state.iot);
  const theme = getTheme(isDarkMode);

  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    // Initialize empty state - real data will come from actual IoT connections
    dispatch(setLoading(false));
  }, []);

  const handleConnect = async () => {
    try {
      dispatch(setLoading(true));
      // TODO: Implement real IoT connection logic here
      // This should connect to actual IoT devices/services
      dispatch(setError('Función de conexión no implementada. Conectar a dispositivos IoT reales.'));
      dispatch(setLoading(false));
    } catch (err) {
      dispatch(setError('Error al conectar con dispositivos IoT'));
      dispatch(setLoading(false));
    }
  };

  const handleDisconnect = async () => {
    setIsConnected(false);
    Alert.alert('Info', 'Desconectado del sistema IoT');
  };

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getContentStyle = (): ViewStyle => ({
    padding: theme.spacing.lg,
  });

  const getMetricCardStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
    ...theme.shadows.sm,
  });

  const getDeviceCardStyle = (status: string): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
    borderLeftWidth: 4,
    borderLeftColor: status === 'online' ? theme.colors.success : theme.colors.error,
    ...theme.shadows.sm,
  });

  const getTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: theme.colors.text,
    marginBottom: theme.spacing.md,
  });

  const getSubtitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: theme.colors.textSecondary,
  });

  const getValueStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.xl,
    fontWeight: theme.typography.weights.bold,
    color: theme.colors.primary,
  });

  const renderMetricCard = (title: string, value: string | number, icon: string) => (
    <View style={getMetricCardStyle()} key={title}>
      <View style={styles.metricHeader}>
        <Ionicons name={icon as any} size={24} color={theme.colors.primary} />
        <Text style={[styles.metricTitle, { color: theme.colors.text }]}>{title}</Text>
      </View>
      <Text style={[styles.metricValue, getValueStyle()]}>{value}</Text>
    </View>
  );

  const renderDeviceCard = (device: IoTDevice) => (
    <View style={getDeviceCardStyle(device.status)} key={device.id}>
      <View style={styles.deviceHeader}>
        <Text style={[styles.deviceName, { color: theme.colors.text }]}>{device.name}</Text>
        <View style={[
          styles.statusBadge,
          { backgroundColor: device.status === 'online' ? theme.colors.success : theme.colors.error }
        ]}>
          <Text style={styles.statusText}>{device.status}</Text>
        </View>
      </View>
      
      <Text style={[styles.deviceType, getSubtitleStyle()]}>Tipo: {device.type}</Text>
      
      {device.temperature && (
        <Text style={[styles.deviceData, { color: theme.colors.text }]}>
          🌡️ {device.temperature}°C
        </Text>
      )}
      
      {device.humidity && (
        <Text style={[styles.deviceData, { color: theme.colors.text }]}>
          💧 {device.humidity}%
        </Text>
      )}
      
      {device.batteryLevel && (
        <Text style={[styles.deviceData, { color: theme.colors.text }]}>
          🔋 {device.batteryLevel}%
        </Text>
      )}
      
      <Text style={[styles.lastSeen, getSubtitleStyle()]}>
        Última conexión: {new Date(device.lastSeen).toLocaleString()}
      </Text>
    </View>
  );

  return (
    <View style={[styles.container, getContainerStyle()]}>
      <Header title="IoT Dashboard" />
      
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={[styles.content, getContentStyle()]}
        showsVerticalScrollIndicator={false}
      >
        {/* Connection Status */}
        <View style={styles.connectionSection}>
          <Text style={[styles.sectionTitle, getTitleStyle()]}>Estado de Conexión</Text>
          <View style={styles.connectionButtons}>
            <Button
              title={isConnected ? 'Desconectar' : 'Conectar'}
              onPress={isConnected ? handleDisconnect : handleConnect}
              loading={isLoading}
              variant={isConnected ? 'outline' : 'primary'}
            />
          </View>
        </View>

        {/* Metrics Overview */}
        <Text style={[styles.sectionTitle, getTitleStyle()]}>Resumen</Text>
        <View style={styles.metricsGrid}>
          {renderMetricCard('Total Dispositivos', metrics.totalDevices, 'hardware-chip-outline')}
          {renderMetricCard('En Línea', metrics.onlineDevices, 'checkmark-circle-outline')}
          {renderMetricCard('Fuera de Línea', metrics.offlineDevices, 'close-circle-outline')}
          {renderMetricCard('Temp. Promedio', `${metrics.averageTemperature.toFixed(1)}°C`, 'thermometer-outline')}
        </View>

        {/* Devices List */}
        <Text style={[styles.sectionTitle, getTitleStyle()]}>Dispositivos</Text>
        {devices.map(renderDeviceCard)}

        {error && (
          <View style={[styles.errorContainer, { backgroundColor: theme.colors.error + '20' }]}>
            <Text style={[styles.errorText, { color: theme.colors.error }]}>{error}</Text>
          </View>
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
  content: {
    paddingBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
    marginTop: 8,
  },
  connectionSection: {
    marginBottom: 24,
  },
  connectionButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  metricsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  metricHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  metricTitle: {
    fontSize: 14,
    marginLeft: 8,
  },
  metricValue: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  deviceHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  deviceName: {
    fontSize: 16,
    fontWeight: '600',
    flex: 1,
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statusText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '500',
  },
  deviceType: {
    fontSize: 14,
    marginBottom: 8,
  },
  deviceData: {
    fontSize: 14,
    marginBottom: 4,
  },
  lastSeen: {
    fontSize: 12,
    marginTop: 8,
  },
  errorContainer: {
    padding: 16,
    borderRadius: 8,
    marginTop: 16,
  },
  errorText: {
    fontSize: 14,
    textAlign: 'center',
  },
});

export default IoTDashboardScreen;