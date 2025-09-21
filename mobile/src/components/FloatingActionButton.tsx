import React, { useRef, useEffect } from 'react';
import {
  View,
  TouchableOpacity,
  StyleSheet,
  Animated,
  ViewStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

interface FloatingActionButtonProps {
  icon: keyof typeof Ionicons.glyphMap;
  onPress: () => void;
  position?: 'bottom-right' | 'bottom-left' | 'top-right' | 'top-left';
  size?: 'sm' | 'md' | 'lg';
  variant?: 'primary' | 'secondary' | 'voice' | 'iot';
  glitchEffect?: boolean;
  floatEffect?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
}

const FloatingActionButton: React.FC<FloatingActionButtonProps> = ({
  icon,
  onPress,
  position = 'bottom-right',
  size = 'md',
  variant = 'primary',
  glitchEffect = false,
  floatEffect = true,
  disabled = false,
  style,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const floatAnim = useRef(new Animated.Value(0)).current;
  const glitchAnim1 = useRef(new Animated.Value(0)).current;
  const glitchAnim2 = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const rotateAnim = useRef(new Animated.Value(0)).current;

  // Float animation inspired by reference CSS
  useEffect(() => {
    if (floatEffect && !disabled) {
      Animated.loop(
        Animated.sequence([
          Animated.timing(floatAnim, {
            toValue: -theme.animations.transform.floatDistance,
            duration: 3000,
            useNativeDriver: true,
          }),
          Animated.timing(floatAnim, {
            toValue: 0,
            duration: 3000,
            useNativeDriver: true,
          }),
        ])
      ).start();
    }
  }, [floatEffect, disabled]);

  // Glitch animation inspired by reference CSS
  useEffect(() => {
    if (glitchEffect && !disabled) {
      const glitchAnimation = () => {
        Animated.parallel([
          Animated.sequence([
            Animated.timing(glitchAnim1, {
              toValue: 1,
              duration: 100,
              useNativeDriver: true,
            }),
            Animated.timing(glitchAnim1, {
              toValue: 0,
              duration: 100,
              useNativeDriver: true,
            }),
          ]),
          Animated.sequence([
            Animated.delay(50),
            Animated.timing(glitchAnim2, {
              toValue: 1,
              duration: 100,
              useNativeDriver: true,
            }),
            Animated.timing(glitchAnim2, {
              toValue: 0,
              duration: 100,
              useNativeDriver: true,
            }),
          ]),
        ]).start(() => {
          // Repeat glitch effect randomly
          setTimeout(glitchAnimation, Math.random() * 5000 + 2000);
        });
      };
      
      glitchAnimation();
    }
  }, [glitchEffect, disabled]);

  const handlePressIn = () => {
    if (disabled) return;
    
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: theme.animations.scale.small,
        useNativeDriver: true,
      }),
      Animated.timing(rotateAnim, {
        toValue: 1,
        duration: theme.animations.timing.fast,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const handlePressOut = () => {
    if (disabled) return;
    
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: theme.animations.scale.normal,
        useNativeDriver: true,
      }),
      Animated.timing(rotateAnim, {
        toValue: 0,
        duration: theme.animations.timing.normal,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const getPositionStyle = (): ViewStyle => {
    const positions = {
      'bottom-right': { bottom: theme.spacing.xl, right: theme.spacing.xl },
      'bottom-left': { bottom: theme.spacing.xl, left: theme.spacing.xl },
      'top-right': { top: theme.spacing.xl, right: theme.spacing.xl },
      'top-left': { top: theme.spacing.xl, left: theme.spacing.xl },
    };
    
    return positions[position];
  };

  const getSizeStyle = (): ViewStyle => {
    const sizes = {
      sm: { width: 48, height: 48, borderRadius: 24 },
      md: { width: 56, height: 56, borderRadius: 28 },
      lg: { width: 64, height: 64, borderRadius: 32 },
    };
    
    return sizes[size];
  };

  const getVariantStyle = (): ViewStyle => {
    const variants = {
      primary: {
        backgroundColor: theme.colors.primary,
        ...theme.shadows.glow,
      },
      secondary: {
        backgroundColor: theme.colors.secondary,
        ...theme.shadows.md,
      },
      voice: {
        backgroundColor: theme.colors.success,
        ...theme.shadows.glow,
      },
      iot: {
        backgroundColor: theme.colors.tertiary,
        ...theme.shadows.md,
      },
    };
    
    return variants[variant];
  };

  const getIconSize = () => {
    const sizes = { sm: 20, md: 24, lg: 28 };
    return sizes[size];
  };

  const animatedStyle: any = {
    transform: [
      { translateY: floatAnim },
      { scale: scaleAnim },
    ],
    opacity: disabled ? theme.animations.opacity.disabled : theme.animations.opacity.visible,
  };

  return (
    <Animated.View style={[
      styles.container,
      getPositionStyle(),
      getSizeStyle(),
      getVariantStyle(),
      animatedStyle,
      style,
    ]}>
      <View>
        <TouchableOpacity
          style={styles.button}
          onPress={onPress}
          onPressIn={handlePressIn}
          onPressOut={handlePressOut}
          disabled={disabled}
          activeOpacity={0.8}
        >
          <Ionicons
            name={icon}
            size={getIconSize()}
            color="#FFFFFF"
          />
        </TouchableOpacity>
      </View>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  },
  button: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '100%',
  },
});

export default FloatingActionButton;
