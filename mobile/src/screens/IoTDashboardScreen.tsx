// @ts-nocheck
import React, { useState, useEffect, useRef } from 'react';
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
import { Header, Button, AnimatedCard, StatusBadge, FloatingActionButton } from '@/components';
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { setDevices, setLoading, setError, IoTDevice } from '@/store/iotSlice';
import { getTheme } from '@/utils/theme';
import { LiveKitIoTService } from '@/services/livekitService';

const IoTDashboardScreen: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const { devices, metrics, isLoading, error } = useAppSelector((state) => state.iot);
  const theme = getTheme(isDarkMode);

  const [isConnected, setIsConnected] = useState(false);
  const [isMicEnabled, setIsMicEnabled] = useState(false);
  const [roomInfo, setRoomInfo] = useState<any>(null);
  const [receivedData, setReceivedData] = useState<any[]>([]);
  const [sensorInterval, setSensorInterval] = useState<NodeJS.Timeout | null>(null);
  
  const livekitService = useRef(new LiveKitIoTService());

  useEffect(() => {
    // Initialize LiveKit service callbacks
    livekitService.current.onConnectionStatus((status) => {
      setIsConnected(status === 'connected');
      if (status === 'connected') {
        setRoomInfo(livekitService.current.getRoomInfo());
        dispatch(setError(null));
      } else if (status === 'error') {
        dispatch(setError('Error conectando a LiveKit'));
      }
    });

    livekitService.current.onDeviceData((data) => {
      setReceivedData(prev => [...prev.slice(-9), data]); // Keep last 10 entries
    });

    return () => {
      if (sensorInterval) {
        clearInterval(sensorInterval);
      }
      livekitService.current.disconnect();
    };
  }, []);

  const handleConnect = async () => {
    try {
      dispatch(setLoading(true));
      await livekitService.current.connect({
        roomName: 'nebu-iot-test',
        participantName: `mobile-${Date.now()}`,
      });
      dispatch(setLoading(false));
      Alert.alert('¡Conectado!', 'Conectado a LiveKit. Ahora puedes enviar datos y audio.');
    } catch (err) {
      dispatch(setError('Error al conectar con LiveKit'));
      dispatch(setLoading(false));
      Alert.alert('Error', 'No se pudo conectar a LiveKit');
    }
  };

  const handleToggleMicrophone = async () => {
    try {
      if (isMicEnabled) {
        await livekitService.current.disableMicrophone();
        setIsMicEnabled(false);
        Alert.alert('Micrófono', 'Micrófono desactivado');
      } else {
        await livekitService.current.enableMicrophone();
        setIsMicEnabled(true);
        Alert.alert('Micrófono', 'Micrófono activado - ¡Habla!');
      }
    } catch (err) {
      Alert.alert('Error', 'Error al controlar micrófono');
    }
  };

  const handleSendSensorData = async () => {
    try {
      await livekitService.current.sendIoTSensorData();
      Alert.alert('Datos Enviados', 'Datos de sensores enviados a LiveKit');
    } catch (err) {
      Alert.alert('Error', 'Error al enviar datos');
    }
  };

  const handleStartSensorStream = () => {
    if (sensorInterval) {
      clearInterval(sensorInterval);
      setSensorInterval(null);
      Alert.alert('Stream Detenido', 'Stream de sensores detenido');
    } else {
      const interval = setInterval(async () => {
        try {
          await livekitService.current.sendIoTSensorData();
        } catch (err) {
          console.error('Error sending sensor data:', err);
        }
      }, 2000); // Send every 2 seconds
      
      setSensorInterval(interval);
      Alert.alert('Stream Iniciado', 'Enviando datos cada 2 segundos');
    }
  };

  const handleSendCustomData = async () => {
    try {
      const customData = {
        type: 'custom_message',
        message: '¡Hola desde Nebu Mobile!',
        timestamp: Date.now(),
        deviceInfo: {
          platform: 'mobile',
          app: 'nebu-mobile'
        }
      };
      await livekitService.current.sendData(customData);
      Alert.alert('Mensaje Enviado', 'Mensaje personalizado enviado');
    } catch (err) {
      Alert.alert('Error', 'Error al enviar mensaje');
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
      <Header title=" LiveKit IoT Test" />
      
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={[styles.content, getContentStyle()]}
        showsVerticalScrollIndicator={false}
      >
        {error && (
          <View style={[styles.errorContainer, { backgroundColor: theme.colors.error + '20' }]}>
            <Text style={[styles.errorText, { color: theme.colors.error }]}>{error}</Text>
          </View>
        )}

        {/* Connection Status */}
        <AnimatedCard
          animationType="fadeIn"
          delay={200}
          variant="elevated"
          style={getMetricCardStyle()}
        >
          <View style={styles.statusHeader}>
            <Text style={[styles.sectionTitle, getTitleStyle()]}>Estado de Conexión</Text>
            <StatusBadge
              status={isConnected ? 'online' : 'offline'}
              text={isConnected ? 'Conectado' : 'Desconectado'}
              pulseEffect={isConnected}
              size="md"
            />
          </View>
          
          {roomInfo && (
            <View style={styles.roomInfo}>
              <Text style={[styles.roomInfoText, { color: theme.colors.textSecondary }]}>
                Sala: {roomInfo.name}
              </Text>
              <Text style={[styles.roomInfoText, { color: theme.colors.textSecondary }]}>
                👥 Participantes: {roomInfo.participants}
              </Text>
            </View>
          )}
          
          <Button
            title={isConnected ? "Desconectar LiveKit" : "🔗 Conectar LiveKit"}
            onPress={isConnected ? handleDisconnect : handleConnect}
            variant={isConnected ? "outline" : "primary"}
            loading={isLoading}
            style={{ marginTop: 12 }}
          />
        </AnimatedCard>

        {/* Audio Controls */}
        <View style={getMetricCardStyle()}>
          <Text style={[styles.sectionTitle, getTitleStyle()]}>🎤 Control de Audio</Text>
          
          <Button
            title={isMicEnabled ? "🎤 Micrófono ACTIVADO" : "🎤 Activar Micrófono"}
            onPress={handleToggleMicrophone}
            variant={isMicEnabled ? "primary" : "outline"}
            disabled={!isConnected}
            style={{ backgroundColor: isMicEnabled ? '#4caf50' : undefined }}
          />
          
          {!isConnected && (
            <Text style={[styles.disabledText, { color: theme.colors.textSecondary }]}>
              Conecta a LiveKit para usar audio
            </Text>
          )}
        </View>

        {/* Data Streaming */}
        <View style={getMetricCardStyle()}>
          <Text style={[styles.sectionTitle, getTitleStyle()]}> Streaming de Datos</Text>
          
          <View style={styles.buttonGrid}>
            <Button
              title="📈 Enviar Sensores"
              onPress={handleSendSensorData}
              variant="outline"
              style={styles.gridButton}
              disabled={!isConnected}
            />
            
            <Button
              title={sensorInterval ? "⏹️ Detener Stream" : "▶️ Stream Auto"}
              onPress={handleStartSensorStream}
              variant={sensorInterval ? "primary" : "outline"}
              style={[styles.gridButton, { backgroundColor: sensorInterval ? '#ff9800' : undefined }]}
              disabled={!isConnected}
            />
          </View>
          
          <Button
            title="💬 Enviar Mensaje Custom"
            onPress={handleSendCustomData}
            variant="outline"
            disabled={!isConnected}
            style={{ marginTop: 8 }}
          />
          
          {sensorInterval && (
            <Text style={[styles.streamingText, { color: '#ff9800' }]}>
              Enviando datos cada 2 segundos...
            </Text>
          )}
        </View>

        {/* Received Data */}
        {receivedData.length > 0 && (
          <View style={getMetricCardStyle()}>
            <Text style={[styles.sectionTitle, getTitleStyle()]}>
              📥 Datos Recibidos ({receivedData.length})
            </Text>
            
            {receivedData.slice(-3).map((data, index) => (
              <View key={index} style={styles.dataItem}>
                <View style={styles.dataHeader}>
                  <Text style={[styles.dataType, { color: theme.colors.primary }]}>
                    {data.type}
                  </Text>
                  <Text style={[styles.dataTimestamp, { color: theme.colors.textSecondary }]}>
                    {new Date(data.timestamp).toLocaleTimeString()}
                  </Text>
                </View>
                
                {data.temperature && (
                  <Text style={[styles.dataValue, { color: theme.colors.text }]}>
                    🌡️ Temperatura: {data.temperature.toFixed(1)}°C
                  </Text>
                )}
                {data.humidity && (
                  <Text style={[styles.dataValue, { color: theme.colors.text }]}>
                    💧 Humedad: {data.humidity.toFixed(1)}%
                  </Text>
                )}
                {data.pressure && (
                  <Text style={[styles.dataValue, { color: theme.colors.text }]}>
                    🌪️ Presión: {data.pressure.toFixed(1)} hPa
                  </Text>
                )}
              </View>
            ))}
          </View>
        )}

        {/* Instructions */}
        <View style={[getMetricCardStyle(), { borderColor: theme.colors.primary, borderWidth: 1 }]}>
          <Text style={[styles.sectionTitle, getTitleStyle()]}> Instrucciones</Text>
          <Text style={[styles.instructionText, { color: theme.colors.textSecondary }]}>
            1. 🔗 Conecta a LiveKit para comenzar{'\n'}
            2. 🎤 Activa el micrófono para transmitir audio{'\n'}
            3. 📈 Envía datos de sensores simulados{'\n'}
            4. ▶️ Inicia stream automático de datos{'\n'}
            5. 💬 Envía mensajes personalizados{'\n'}
            6.  Abre otra app LiveKit para ver la interacción
          </Text>
        </View>
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
  statusHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  connectionBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  connectionText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
  roomInfo: {
    marginBottom: 12,
  },
  roomInfoText: {
    fontSize: 14,
    marginBottom: 4,
  },
  disabledText: {
    fontSize: 12,
    textAlign: 'center',
    marginTop: 8,
    fontStyle: 'italic',
  },
  buttonGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 8,
  },
  gridButton: {
    flex: 1,
  },
  streamingText: {
    fontSize: 12,
    textAlign: 'center',
    marginTop: 8,
    fontWeight: '500',
  },
  dataItem: {
    backgroundColor: 'rgba(0,0,0,0.05)',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  dataHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  dataType: {
    fontSize: 14,
    fontWeight: '600',
  },
  dataTimestamp: {
    fontSize: 12,
  },
  dataValue: {
    fontSize: 13,
    marginBottom: 2,
  },
  instructionText: {
    fontSize: 14,
    lineHeight: 20,
  },
});

export default IoTDashboardScreen;