import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Animated,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

interface StatusBadgeProps {
  status: 'online' | 'offline' | 'connecting' | 'error' | 'success' | 'warning' | 'setup';
  text?: string;
  color?: string;
  showIcon?: boolean;
  size?: 'sm' | 'md' | 'lg';
  pulseEffect?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
}

const StatusBadge: React.FC<StatusBadgeProps> = ({
  status,
  text,
  color,
  showIcon = true,
  size = 'md',
  pulseEffect = false,
  style,
  textStyle,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const scaleAnim = useRef(new Animated.Value(0)).current;

  // Entry animation
  useEffect(() => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      tension: 100,
      friction: 8,
      useNativeDriver: true,
    }).start();
  }, []);

  // Pulse animation for active statuses
  useEffect(() => {
    if (pulseEffect && (status === 'online' || status === 'connecting')) {
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 1.1,
            duration: 1000,
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 1000,
            useNativeDriver: true,
          }),
        ])
      ).start();
    }
  }, [pulseEffect, status]);

  const getStatusConfig = () => {
    const configs = {
      online: {
        color: color || theme.colors.success,
        icon: 'checkmark-circle' as keyof typeof Ionicons.glyphMap,
        text: text || 'En línea',
      },
      offline: {
        color: color || theme.colors.error,
        icon: 'close-circle' as keyof typeof Ionicons.glyphMap,
        text: text || 'Desconectado',
      },
      connecting: {
        color: color || theme.colors.warning,
        icon: 'time' as keyof typeof Ionicons.glyphMap,
        text: text || 'Conectando...',
      },
      error: {
        color: color || theme.colors.error,
        icon: 'alert-circle' as keyof typeof Ionicons.glyphMap,
        text: text || 'Error',
      },
      success: {
        color: color || theme.colors.success,
        icon: 'checkmark-circle' as keyof typeof Ionicons.glyphMap,
        text: text || 'Éxito',
      },
      warning: {
        color: color || theme.colors.warning,
        icon: 'warning' as keyof typeof Ionicons.glyphMap,
        text: text || 'Advertencia',
      },
      setup: {
        color: color || theme.colors.warning,
        icon: 'settings' as keyof typeof Ionicons.glyphMap,
        text: text || 'Configuración',
      },
    };
    
    return configs[status];
  };

  const getBadgeStyle = (): ViewStyle => {
    const config = getStatusConfig();
    
    const baseStyle: ViewStyle = {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: config.color + '20', // 20% opacity
      borderWidth: 1,
      borderColor: config.color,
      borderRadius: theme.borderRadius.full,
    };

    const sizeStyles = {
      sm: {
        paddingHorizontal: theme.spacing.sm,
        paddingVertical: theme.spacing.xs,
        minHeight: 24,
      },
      md: {
        paddingHorizontal: theme.spacing.md,
        paddingVertical: theme.spacing.sm,
        minHeight: 32,
      },
      lg: {
        paddingHorizontal: theme.spacing.lg,
        paddingVertical: theme.spacing.md,
        minHeight: 40,
      },
    };

    return {
      ...baseStyle,
      ...sizeStyles[size],
    };
  };

  const getTextStyle = (): TextStyle => {
    const config = getStatusConfig();
    
    const sizeStyles = {
      sm: { fontSize: theme.typography.sizes.xs },
      md: { fontSize: theme.typography.sizes.sm },
      lg: { fontSize: theme.typography.sizes.md },
    };

    return {
      color: config.color,
      fontWeight: theme.typography.weights.semibold,
      ...sizeStyles[size],
    };
  };

  const getIconSize = () => {
    const sizes = { sm: 12, md: 16, lg: 20 };
    return sizes[size];
  };

  const config = getStatusConfig();
  
  const animatedStyle = {
    transform: [
      { scale: scaleAnim },
      { scale: pulseAnim },
    ],
  };

  return (
    <Animated.View style={[animatedStyle]}>
      <View style={[getBadgeStyle(), style]}>
        {showIcon && (
          <Ionicons
            name={config.icon}
            size={getIconSize()}
            color={config.color}
            style={{ marginRight: config.text ? theme.spacing.xs : 0 }}
          />
        )}
        
        {config.text && (
          <Text style={[getTextStyle(), textStyle]}>
            {config.text}
          </Text>
        )}
      </View>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  // Placeholder for additional styles if needed
});

export default StatusBadge;
