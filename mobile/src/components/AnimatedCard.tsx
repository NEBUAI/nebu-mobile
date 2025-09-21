import React, { useRef, useEffect } from 'react';
import {
  View,
  StyleSheet,
  Animated,
  ViewStyle,
  TouchableOpacity,
} from 'react-native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

interface AnimatedCardProps {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
  variant?: 'default' | 'glass' | 'elevated' | 'outlined';
  animationType?: 'fadeIn' | 'slideIn' | 'scaleIn' | 'float';
  delay?: number;
  glowEffect?: boolean;
  hoverLift?: boolean;
}

const AnimatedCard: React.FC<AnimatedCardProps> = ({
  children,
  style,
  onPress,
  variant = 'default',
  animationType = 'fadeIn',
  delay = 0,
  glowEffect = false,
  hoverLift = false,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;
  const scaleAnim = useRef(new Animated.Value(0.8)).current;
  const floatAnim = useRef(new Animated.Value(0)).current;
  const glowAnim = useRef(new Animated.Value(0)).current;
  const liftAnim = useRef(new Animated.Value(0)).current;
  const pressAnim = useRef(new Animated.Value(1)).current;

  // Entry animations inspired by reference CSS
  useEffect(() => {
    const startAnimation = () => {
      switch (animationType) {
        case 'fadeIn':
          Animated.timing(fadeAnim, {
            toValue: 1,
            duration: theme.animations.timing.verySlow,
            delay,
            useNativeDriver: true,
          }).start();
          break;
          
        case 'slideIn':
          Animated.parallel([
            Animated.timing(fadeAnim, {
              toValue: 1,
              duration: theme.animations.timing.verySlow,
              delay,
              useNativeDriver: true,
            }),
            Animated.timing(slideAnim, {
              toValue: 0,
              duration: theme.animations.timing.verySlow,
              delay,
              useNativeDriver: true,
            }),
          ]).start();
          break;
          
        case 'scaleIn':
          Animated.parallel([
            Animated.timing(fadeAnim, {
              toValue: 1,
              duration: theme.animations.timing.slow,
              delay,
              useNativeDriver: true,
            }),
            Animated.spring(scaleAnim, {
              toValue: 1,
              delay,
              useNativeDriver: true,
            }),
          ]).start();
          break;
          
        case 'float':
          fadeAnim.setValue(1);
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
          break;
      }
    };

    startAnimation();
  }, [animationType, delay]);

  // Glow effect animation
  useEffect(() => {
    if (glowEffect) {
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
  }, [glowEffect]);

  const handlePressIn = () => {
    if (!onPress) return;
    
    Animated.parallel([
      Animated.spring(pressAnim, {
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
    if (!onPress) return;
    
    Animated.parallel([
      Animated.spring(pressAnim, {
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

  const getCardStyle = (): ViewStyle => {
    const baseStyle: ViewStyle = {
      borderRadius: theme.borderRadius.lg,
      padding: theme.spacing.lg,
    };

    const variantStyles = {
      default: {
        backgroundColor: theme.colors.card,
        ...theme.shadows.md,
      },
      glass: {
        backgroundColor: isDarkMode 
          ? 'rgba(0, 0, 0, 0.2)' 
          : 'rgba(255, 255, 255, 0.1)',
        borderWidth: 1,
        borderColor: isDarkMode 
          ? 'rgba(255, 255, 255, 0.1)' 
          : 'rgba(255, 255, 255, 0.2)',
        ...theme.shadows.sm,
      },
      elevated: {
        backgroundColor: theme.colors.card,
        ...theme.shadows.lg,
      },
      outlined: {
        backgroundColor: 'transparent',
        borderWidth: 1,
        borderColor: theme.colors.border,
      },
    };

    return {
      ...baseStyle,
      ...variantStyles[variant],
    };
  };

  const animatedStyle = {
    opacity: fadeAnim,
    transform: [
      { translateY: animationType === 'slideIn' ? slideAnim : floatAnim },
      { scale: animationType === 'scaleIn' ? scaleAnim : pressAnim },
      { translateY: liftAnim },
    ],
  };

  const glowStyle = glowEffect ? {
    shadowColor: theme.colors.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: glowAnim,
    shadowRadius: 15,
    elevation: 12,
  } : {};

  const CardComponent = onPress ? TouchableOpacity : View;

  return (
    <Animated.View style={[animatedStyle, glowStyle]}>
      <CardComponent
        style={[getCardStyle(), style]}
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        activeOpacity={onPress ? 0.9 : 1}
      >
        {children}
      </CardComponent>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  // Placeholder for additional styles if needed
});

export default AnimatedCard;
