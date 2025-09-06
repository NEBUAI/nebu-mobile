import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
  TextInput,
  Modal,
} from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState, AppDispatch } from '@/store';
import { connectToLiveKit, disconnectFromLiveKit, sendIoTData, addDeviceData } from '@/store/iotSlice';
import { liveKitIoTService, IoTDeviceData } from '@/services/livekitService';
import { Button } from '@/components';
import { LiveKitTester } from '@/utils/livekitTest';

const IoTDashboardScreen: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { t } = useTranslation();
  
  const {
    isConnected,
    connectionStatus,
    devices,
    recentData,
    isLoading,
    error,
  } = useSelector((state: RootState) => state.iot);

  const [showConnectionModal, setShowConnectionModal] = useState(false);
  const [connectionConfig, setConnectionConfig] = useState({
    serverUrl: '', // Will use env variable if empty
    roomName: 'nebu-iot-room',
    participantName: 'nebu-mobile-' + Date.now(),
  });

  useEffect(() => {
    // Set up data listener
    liveKitIoTService.onDeviceData((data: IoTDeviceData) => {
      dispatch(addDeviceData(data));
    });

    // Set up connection status listener
    liveKitIoTService.onConnectionStatus((status) => {
      // Handle connection status updates if needed
    });

    return () => {
      // Cleanup
      if (isConnected) {
        dispatch(disconnectFromLiveKit());
      }
    };
  }, [dispatch, isConnected]);

  const handleConnect = async () => {
    try {
      await dispatch(connectToLiveKit(connectionConfig)).unwrap();
      setShowConnectionModal(false);
    } catch (error) {
      Alert.alert(t('common.error'), error as string);
    }
  };

  const handleDisconnect = async () => {
    try {
      await dispatch(disconnectFromLiveKit()).unwrap();
    } catch (error) {
      Alert.alert(t('common.error'), error as string);
    }
  };

  const handleSendTestData = async () => {
    if (!isConnected) return;

    const testData: IoTDeviceData = {
      deviceId: 'mobile-test-device',
      deviceType: 'sensor',
      data: {
        temperature: Math.round((Math.random() * 30 + 10) * 10) / 10, // 10-40°C
        humidity: Math.round((Math.random() * 60 + 30) * 10) / 10, // 30-90%
        pressure: Math.round((Math.random() * 50 + 1000) * 100) / 100, // 1000-1050 hPa
        battery: Math.round(Math.random() * 100), // 0-100%
        signal: Math.round(Math.random() * 100), // 0-100%
        timestamp: Date.now(),
      },
      timestamp: Date.now(),
    };

    try {
      await dispatch(sendIoTData(testData)).unwrap();
      Alert.alert('Datos enviados', `Temperatura: ${testData.data.temperature}°C\nHumedad: ${testData.data.humidity}%`);
    } catch (error) {
      Alert.alert(t('common.error'), error as string);
    }
  };

  const handleRunTests = async () => {
    Alert.alert(
      'Ejecutar Pruebas',
      '¿Quieres ejecutar las pruebas de conexión de LiveKit?',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Ejecutar',
          onPress: async () => {
            try {
              const results = await LiveKitTester.runAllTests();
              const summary = results.map(r => r.message).join('\n');
              Alert.alert('Resultados de Pruebas', summary);
            } catch (error) {
              Alert.alert('Error en Pruebas', error as string);
            }
          }
        }
      ]
    );
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'connected':
        return '#4CAF50';
      case 'connecting':
        return '#FF9800';
      case 'error':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  };

  const renderDevice = ({ item }: { item: any }) => (
    <View style={styles.deviceCard}>
      <View style={styles.deviceHeader}>
        <Text style={styles.deviceName}>{item.name}</Text>
        <View style={[styles.statusIndicator, { backgroundColor: item.status === 'online' ? '#4CAF50' : '#F44336' }]} />
      </View>
      <Text style={styles.deviceType}>Type: {item.type}</Text>
      <Text style={styles.deviceLastSeen}>
        Last seen: {new Date(item.lastSeen).toLocaleTimeString()}
      </Text>
      {item.data && (
        <Text style={styles.deviceData} numberOfLines={2}>
          Data: {JSON.stringify(item.data)}
        </Text>
      )}
    </View>
  );

  const renderRecentData = ({ item }: { item: IoTDeviceData }) => (
    <View style={styles.dataCard}>
      <View style={styles.dataHeader}>
        <Text style={styles.deviceId}>{item.deviceId}</Text>
        <Text style={styles.dataTime}>{new Date(item.timestamp).toLocaleTimeString()}</Text>
      </View>
      <Text style={styles.dataContent} numberOfLines={3}>
        {JSON.stringify(item.data, null, 2)}
      </Text>
    </View>
  );

  return (
    <View style={styles.container}>
      {/* Connection Status */}
      <View style={styles.statusBar}>
        <View style={styles.statusInfo}>
          <View style={[styles.statusDot, { backgroundColor: getStatusColor(connectionStatus) }]} />
          <Text style={styles.statusText}>
            {connectionStatus.charAt(0).toUpperCase() + connectionStatus.slice(1)}
          </Text>
        </View>
        {!isConnected ? (
          <Button
            title="Connect"
            onPress={() => setShowConnectionModal(true)}
            disabled={isLoading}
          />
        ) : (
          <Button
            title="Disconnect"
            onPress={handleDisconnect}
            disabled={isLoading}
          />
        )}
      </View>

      {error && (
        <View style={styles.errorBar}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )}

      {isConnected && (
        <View style={styles.actionBar}>
          <Button
            title="Send Test Data"
            onPress={handleSendTestData}
            style={styles.testButton}
          />
          <Button
            title="Run Tests"
            onPress={handleRunTests}
            style={[styles.testButton, styles.runTestsButton]}
          />
        </View>
      )}

      {/* Devices Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Connected Devices ({devices.length})</Text>
        <FlatList
          data={devices}
          renderItem={renderDevice}
          keyExtractor={(item) => item.id}
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.devicesList}
        />
      </View>

      {/* Recent Data Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Recent Data ({recentData.length})</Text>
        <FlatList
          data={recentData.slice(0, 10)}
          renderItem={renderRecentData}
          keyExtractor={(item, index) => `${item.deviceId}-${item.timestamp}-${index}`}
          style={styles.dataList}
        />
      </View>

      {/* Connection Modal */}
      <Modal
        visible={showConnectionModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowConnectionModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Connect to LiveKit</Text>
            
            <TextInput
              style={styles.input}
              placeholder="Server URL"
              value={connectionConfig.serverUrl}
              onChangeText={(text) => setConnectionConfig({ ...connectionConfig, serverUrl: text })}
            />
            
            <Text style={styles.infoText}>
              Las credenciales se cargan automáticamente desde las variables de entorno.
              Solo personaliza si necesitas valores específicos.
            </Text>
            
            <TextInput
              style={styles.input}
              placeholder="Room Name"
              value={connectionConfig.roomName}
              onChangeText={(text) => setConnectionConfig({ ...connectionConfig, roomName: text })}
            />
            
            <TextInput
              style={styles.input}
              placeholder="Participant Name"
              value={connectionConfig.participantName}
              onChangeText={(text) => setConnectionConfig({ ...connectionConfig, participantName: text })}
            />

            <View style={styles.modalActions}>
              <Button
                title="Cancel"
                onPress={() => setShowConnectionModal(false)}
                style={[styles.modalButton, styles.cancelButton]}
              />
              <Button
                title="Connect"
                onPress={handleConnect}
                style={[styles.modalButton, styles.connectButton]}
                disabled={isLoading}
              />
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  statusBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  statusInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 8,
  },
  statusText: {
    fontSize: 16,
    fontWeight: '500',
  },
  errorBar: {
    backgroundColor: '#ffebee',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
  },
  errorText: {
    color: '#d32f2f',
    textAlign: 'center',
  },
  actionBar: {
    marginBottom: 16,
    flexDirection: 'row',
    gap: 12,
  },
  testButton: {
    backgroundColor: '#2196F3',
    flex: 1,
  },
  runTestsButton: {
    backgroundColor: '#FF9800',
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  devicesList: {
    paddingHorizontal: 8,
  },
  deviceCard: {
    backgroundColor: 'white',
    padding: 12,
    borderRadius: 8,
    marginHorizontal: 4,
    width: 200,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  deviceHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  deviceName: {
    fontSize: 14,
    fontWeight: '600',
  },
  statusIndicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  deviceType: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  deviceLastSeen: {
    fontSize: 11,
    color: '#999',
    marginBottom: 4,
  },
  deviceData: {
    fontSize: 11,
    color: '#333',
    fontFamily: 'monospace',
  },
  dataList: {
    maxHeight: 300,
  },
  dataCard: {
    backgroundColor: 'white',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  dataHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  deviceId: {
    fontSize: 14,
    fontWeight: '500',
  },
  dataTime: {
    fontSize: 12,
    color: '#666',
  },
  dataContent: {
    fontSize: 12,
    fontFamily: 'monospace',
    color: '#333',
    backgroundColor: '#f8f8f8',
    padding: 8,
    borderRadius: 4,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 24,
    width: '90%',
    maxWidth: 400,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 20,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
    fontSize: 14,
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 16,
  },
  modalButton: {
    flex: 1,
    marginHorizontal: 8,
  },
  cancelButton: {
    backgroundColor: '#6c757d',
  },
  connectButton: {
    backgroundColor: '#28a745',
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    fontStyle: 'italic',
    marginVertical: 8,
    textAlign: 'center',
  },
});

export default IoTDashboardScreen;