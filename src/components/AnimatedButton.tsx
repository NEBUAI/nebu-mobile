import React, { useRef } from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  Animated,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

interface AnimatedButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  icon?: keyof typeof Ionicons.glyphMap;
  iconPosition?: 'left' | 'right';
  disabled?: boolean;
  loading?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  glowEffect?: boolean;
  hoverLift?: boolean;
}

const AnimatedButton: React.FC<AnimatedButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'md',
  icon,
  iconPosition = 'left',
  disabled = false,
  loading = false,
  style,
  textStyle,
  glowEffect = false,
  hoverLift = false,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const glowAnim = useRef(new Animated.Value(0)).current;
  const liftAnim = useRef(new Animated.Value(0)).current;

  // Animations inspired by reference CSS
  const handlePressIn = () => {
    if (disabled || loading) return;
    
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: theme.animations.scale.small,
        useNativeDriver: true,
      }),
      hoverLift && Animated.timing(liftAnim, {
        toValue: theme.animations.transform.liftDistance,
        duration: theme.animations.timing.fast,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const handlePressOut = () => {
    if (disabled || loading) return;
    
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: theme.animations.scale.normal,
        useNativeDriver: true,
      }),
      hoverLift && Animated.timing(liftAnim, {
        toValue: 0,
        duration: theme.animations.timing.normal,
        useNativeDriver: true,
      }),
    ]).start();
  };

  // Glow animation effect
  React.useEffect(() => {
    if (glowEffect && !disabled) {
      Animated.loop(
        Animated.sequence([
          Animated.timing(glowAnim, {
            toValue: 1,
            duration: 2000,
            useNativeDriver: false,
          }),
          Animated.timing(glowAnim, {
            toValue: 0,
            duration: 2000,
            useNativeDriver: false,
          }),
        ])
      ).start();
    }
  }, [glowEffect, disabled]);

  const getButtonStyle = (): ViewStyle => {
    const baseStyle: ViewStyle = {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      borderRadius: size === 'lg' ? theme.borderRadius.xl : theme.borderRadius.lg,
      ...theme.shadows.md,
    };

    // Size variations
    const sizeStyles = {
      sm: {
        paddingHorizontal: theme.spacing.md,
        paddingVertical: theme.spacing.sm,
        minHeight: 36,
      },
      md: {
        paddingHorizontal: theme.spacing.lg,
        paddingVertical: theme.spacing.md,
        minHeight: 48,
      },
      lg: {
        paddingHorizontal: theme.spacing.xl,
        paddingVertical: theme.spacing.lg,
        minHeight: 56,
      },
    };

    // Variant styles inspired by reference CSS
    const variantStyles = {
      primary: {
        backgroundColor: theme.colors.primary,
        ...theme.shadows.md,
      },
      secondary: {
        backgroundColor: theme.colors.secondary,
        ...theme.shadows.sm,
      },
      outline: {
        backgroundColor: 'transparent',
        borderWidth: 1,
        borderColor: theme.colors.primary,
      },
      ghost: {
        backgroundColor: 'transparent',
      },
    };

    return {
      ...baseStyle,
      ...sizeStyles[size],
      ...variantStyles[variant],
      opacity: disabled ? theme.animations.opacity.disabled : theme.animations.opacity.visible,
    };
  };

  const getTextStyle = (): TextStyle => {
    const baseStyle: TextStyle = {
      fontWeight: theme.typography.weights.semibold,
      textAlign: 'center',
    };

    const sizeStyles = {
      sm: { fontSize: theme.typography.sizes.sm },
      md: { fontSize: theme.typography.sizes.md },
      lg: { fontSize: theme.typography.sizes.lg },
    };

    const variantStyles = {
      primary: { color: '#FFFFFF' },
      secondary: { color: theme.colors.text },
      outline: { color: theme.colors.primary },
      ghost: { color: theme.colors.primary },
    };

    return {
      ...baseStyle,
      ...sizeStyles[size],
      ...variantStyles[variant],
    };
  };

  const getIconSize = () => {
    const sizes = { sm: 16, md: 20, lg: 24 };
    return sizes[size];
  };

  const renderIcon = () => {
    if (!icon) return null;
    
    const iconColor = variant === 'primary' ? '#FFFFFF' : theme.colors.primary;
    const marginStyle = iconPosition === 'left' 
      ? { marginRight: theme.spacing.sm } 
      : { marginLeft: theme.spacing.sm };

    return (
      <Ionicons
        name={icon}
        size={getIconSize()}
        color={iconColor}
        style={marginStyle}
      />
    );
  };

  const animatedStyle = {
    transform: [
      { scale: scaleAnim } as any,
      { translateY: liftAnim } as any,
    ],
  };

  const glowStyle = glowEffect ? {
    shadowColor: theme.colors.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: glowAnim,
    shadowRadius: 15,
    elevation: 10,
  } : {};

  return (
    <Animated.View style={[animatedStyle, glowStyle]}>
      <TouchableOpacity
        style={[getButtonStyle(), style]}
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={disabled || loading}
        activeOpacity={0.8}
      >
        {iconPosition === 'left' && renderIcon()}
        
        <Text style={[getTextStyle(), textStyle]}>
          {loading ? 'Cargando...' : title}
        </Text>
        
        {iconPosition === 'right' && renderIcon()}
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  // Placeholder for additional styles if needed
});

export default AnimatedButton;
