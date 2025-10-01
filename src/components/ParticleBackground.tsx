import React, { useRef, useEffect } from 'react';
import {
  View,
  StyleSheet,
  Animated,
  Dimensions,
  ViewStyle,
} from 'react-native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

interface ParticleBackgroundProps {
  particleCount?: number;
  style?: ViewStyle;
  children?: React.ReactNode;
}

interface Particle {
  id: number;
  x: Animated.Value;
  y: Animated.Value;
  opacity: Animated.Value;
  scale: Animated.Value;
  size: number;
}

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

const ParticleBackground: React.FC<ParticleBackgroundProps> = ({
  particleCount = 8,
  style,
  children,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const particles = useRef<Particle[]>([]);

  // Initialize particles
  useEffect(() => {
    particles.current = Array.from({ length: particleCount }, (_, index) => ({
      id: index,
      x: new Animated.Value(Math.random() * screenWidth),
      y: new Animated.Value(Math.random() * screenHeight),
      opacity: new Animated.Value(0.1 + Math.random() * 0.3),
      scale: new Animated.Value(0.5 + Math.random() * 0.5),
      size: 4 + Math.random() * 8,
    }));

    // Start particle animations
    particles.current.forEach((particle, index) => {
      animateParticle(particle, index);
    });
  }, [particleCount]);

  const animateParticle = (particle: Particle, index: number) => {
    const duration = 15000 + Math.random() * 10000; // 15-25 seconds
    const delay = index * 1000; // Stagger start times

    // Floating animation inspired by reference CSS
    const floatAnimation = () => {
      const newX = Math.random() * screenWidth;
      const newY = Math.random() * screenHeight;
      const newOpacity = 0.1 + Math.random() * 0.3;
      const newScale = 0.5 + Math.random() * 0.5;

      Animated.parallel([
        Animated.timing(particle.x, {
          toValue: newX,
          duration,
          useNativeDriver: false,
        }),
        Animated.timing(particle.y, {
          toValue: newY,
          duration,
          useNativeDriver: false,
        }),
        Animated.timing(particle.opacity, {
          toValue: newOpacity,
          duration: duration / 2,
          useNativeDriver: false,
        }),
        Animated.timing(particle.scale, {
          toValue: newScale,
          duration: duration / 3,
          useNativeDriver: false,
        }),
      ]).start(() => {
        // Restart animation when complete
        floatAnimation();
      });
    };

    // Start with delay
    setTimeout(floatAnimation, delay);
  };

  const getParticleColor = () => {
    return isDarkMode ? theme.colors.primary + '40' : theme.colors.primary + '20';
  };

  const renderParticle = (particle: Particle) => {
    const animatedStyle = {
      position: 'absolute' as const,
      left: particle.x,
      top: particle.y,
      opacity: particle.opacity,
      transform: [{ scale: particle.scale }],
    };

    return (
      <Animated.View
        key={particle.id}
        style={[
          animatedStyle,
          {
            width: particle.size,
            height: particle.size,
            borderRadius: particle.size / 2,
            backgroundColor: getParticleColor(),
          },
        ]}
      />
    );
  };

  return (
    <View style={[styles.container, style]}>
      {/* Particle Layer */}
      <View style={styles.particleLayer}>
        {particles.current.map(renderParticle)}
      </View>
      
      {/* Content Layer */}
      <View style={styles.contentLayer}>
        {children}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    position: 'relative',
  },
  particleLayer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 1,
    pointerEvents: 'none',
  },
  contentLayer: {
    flex: 1,
    zIndex: 2,
  },
});

export default ParticleBackground;
