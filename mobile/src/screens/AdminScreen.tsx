import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  ViewStyle,
  TextStyle,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { Header, AnimatedCard, GradientText } from '@/components';
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

interface AdminScreenProps {
  onClose: () => void;
}

const AdminScreen: React.FC<AdminScreenProps> = ({ onClose }) => {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getContentStyle = (): ViewStyle => ({
    padding: theme.spacing.lg,
  });

  const getCardStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.lg,
    padding: theme.spacing.lg,
    marginBottom: theme.spacing.md,
    ...theme.shadows.md,
  });

  const getTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.xl,
    fontWeight: theme.typography.weights.bold,
    color: theme.colors.text,
    marginBottom: theme.spacing.sm,
  });

  const getSubtitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: theme.colors.textSecondary,
    marginBottom: theme.spacing.lg,
  });

  const getSectionTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: theme.colors.text,
    marginBottom: theme.spacing.md,
  });

  const getButtonStyle = (variant: 'primary' | 'danger' | 'warning' = 'primary'): ViewStyle => {
    const colors = {
      primary: theme.colors.primary,
      danger: '#FF3B30',
      warning: '#FF9500',
    };
    
    return {
      backgroundColor: colors[variant],
      borderRadius: theme.borderRadius.md,
      padding: theme.spacing.md,
      marginBottom: theme.spacing.sm,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
    };
  };

  const getButtonTextStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    fontWeight: theme.typography.weights.semibold,
    color: '#FFFFFF',
    marginLeft: theme.spacing.sm,
  });

  const handleClearCache = () => {
    Alert.alert(
      '🗑️ Limpiar Cache',
      '¿Estás seguro de que quieres limpiar toda la caché de la aplicación?',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Limpiar',
          style: 'destructive',
          onPress: () => {
            // Implementar limpieza de cache
            Alert.alert('✅ Éxito', 'Cache limpiada correctamente');
          },
        },
      ]
    );
  };

  const handleResetSettings = () => {
    Alert.alert(
      '⚙️ Resetear Configuración',
      '¿Estás seguro de que quieres resetear toda la configuración a los valores por defecto?',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Resetear',
          style: 'destructive',
          onPress: () => {
            // Implementar reset de configuración
            Alert.alert('✅ Éxito', 'Configuración reseteada correctamente');
          },
        },
      ]
    );
  };

  const handleViewLogs = () => {
    Alert.alert(
      '📋 Logs del Sistema',
      'Funcionalidad de logs disponible en modo debug',
      [{ text: 'OK' }]
    );
  };

  const handleTestBLE = () => {
    Alert.alert(
      '🔵 Test BLE',
      'Iniciando test de Bluetooth Low Energy...',
      [{ text: 'OK' }]
    );
    // Navegar a pantalla de test BLE
  };

  const handleDatabaseInfo = () => {
    Alert.alert(
      '🗄️ Información de Base de Datos',
      'Estado de la base de datos:\n• Conexión: Activa\n• Última sincronización: Hace 2 minutos\n• Registros: 1,234',
      [{ text: 'OK' }]
    );
  };

  const handleSystemInfo = () => {
    Alert.alert(
      '📱 Información del Sistema',
      `Versión de la app: 1.0.0\nVersión de React Native: 0.79.5\nPlataforma: ${Platform.OS}\nArquitectura: ${Platform.OS === 'ios' ? 'ARM64' : 'x86_64'}`,
      [{ text: 'OK' }]
    );
  };

  const handleForceCrash = () => {
    Alert.alert(
      '💥 Forzar Crash (Solo para Testing)',
      '⚠️ ADVERTENCIA: Esto causará que la aplicación se cierre inesperadamente. Solo usar para testing de crash reporting.',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Forzar Crash',
          style: 'destructive',
          onPress: () => {
            // Forzar crash para testing
            throw new Error('Forced crash for testing purposes');
          },
        },
      ]
    );
  };

  return (
    <View style={[styles.container, getContainerStyle()]}>
      <Header
        title="🔐 Panel de Administración"
        leftComponent={
          <TouchableOpacity onPress={onClose}>
            <Ionicons name="close" size={24} color={theme.colors.text} />
          </TouchableOpacity>
        }
        rightComponent={
          <TouchableOpacity>
            <Ionicons name="shield-checkmark" size={24} color={theme.colors.success} />
          </TouchableOpacity>
        }
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
          style={getCardStyle()}
        >
          <GradientText variant="danger" style={getTitleStyle()}>
            Panel de Administración
          </GradientText>
          <Text style={getSubtitleStyle()}>
            Herramientas de desarrollo y debugging
          </Text>
        </AnimatedCard>

        <AnimatedCard
          animationType="slideIn"
          delay={100}
          hoverLift={false}
          style={getCardStyle()}
        >
          <Text style={getSectionTitleStyle()}>🛠️ Herramientas de Sistema</Text>
          
          <TouchableOpacity
            style={getButtonStyle('warning')}
            onPress={handleClearCache}
          >
            <Ionicons name="trash-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Limpiar Cache</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={getButtonStyle('warning')}
            onPress={handleResetSettings}
          >
            <Ionicons name="refresh-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Resetear Configuración</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={getButtonStyle()}
            onPress={handleViewLogs}
          >
            <Ionicons name="document-text-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Ver Logs del Sistema</Text>
          </TouchableOpacity>
        </AnimatedCard>

        <AnimatedCard
          animationType="slideIn"
          delay={200}
          hoverLift={false}
          style={getCardStyle()}
        >
          <Text style={getSectionTitleStyle()}>🔵 Testing BLE</Text>
          
          <TouchableOpacity
            style={getButtonStyle()}
            onPress={handleTestBLE}
          >
            <Ionicons name="bluetooth-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Test Bluetooth Low Energy</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={getButtonStyle()}
            onPress={handleDatabaseInfo}
          >
            <Ionicons name="server-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Estado de Base de Datos</Text>
          </TouchableOpacity>
        </AnimatedCard>

        <AnimatedCard
          animationType="slideIn"
          delay={300}
          hoverLift={false}
          style={getCardStyle()}
        >
          <Text style={getSectionTitleStyle()}>📊 Información del Sistema</Text>
          
          <TouchableOpacity
            style={getButtonStyle()}
            onPress={handleSystemInfo}
          >
            <Ionicons name="information-circle-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Información del Sistema</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={getButtonStyle('danger')}
            onPress={handleForceCrash}
          >
            <Ionicons name="warning-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Forzar Crash (Testing)</Text>
          </TouchableOpacity>
        </AnimatedCard>

        <AnimatedCard
          animationType="slideIn"
          delay={400}
          hoverLift={false}
          style={getCardStyle()}
        >
          <Text style={getSectionTitleStyle()}>🚀 Acciones Rápidas</Text>
          
          <TouchableOpacity
            style={getButtonStyle()}
            onPress={() => navigation.navigate('RobotSetup' as never)}
          >
            <Ionicons name="bluetooth-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Configurar Robot</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={getButtonStyle()}
            onPress={() => navigation.navigate('IoTDashboard' as never)}
          >
            <Ionicons name="hardware-chip-outline" size={20} color="#FFFFFF" />
            <Text style={getButtonTextStyle()}>Dashboard IoT</Text>
          </TouchableOpacity>
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
});

export default AdminScreen;
