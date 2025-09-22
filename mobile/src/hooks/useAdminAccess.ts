import { useState, useRef, useCallback } from 'react';
import { Alert } from 'react-native';

interface AdminAccessConfig {
  tapCount: number;
  resetTimeout: number; // milliseconds
  secretArea?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

const DEFAULT_CONFIG: AdminAccessConfig = {
  tapCount: 3,
  resetTimeout: 2000, // 2 seconds to complete the sequence
};

export const useAdminAccess = (config: AdminAccessConfig = DEFAULT_CONFIG) => {
  const [isAdminMode, setIsAdminMode] = useState(false);
  const [tapSequence, setTapSequence] = useState<number[]>([]);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const tapCountRef = useRef(0);

  const resetSequence = useCallback(() => {
    setTapSequence([]);
    tapCountRef.current = 0;
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
  }, []);

  const handleTap = useCallback((event: any) => {
    const { locationX, locationY } = event.nativeEvent;
    
    // Check if tap is in secret area (if defined)
    if (config.secretArea) {
      const { x, y, width, height } = config.secretArea;
      if (
        locationX < x || 
        locationX > x + width || 
        locationY < y || 
        locationY > y + height
      ) {
        return; // Tap is outside secret area
      }
    }

    // Add tap to sequence
    const currentTime = Date.now();
    setTapSequence(prev => [...prev, currentTime]);
    tapCountRef.current += 1;

    // Clear existing timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // Check if we have enough taps
    if (tapCountRef.current >= config.tapCount) {
      // Verify tap sequence timing (all taps within resetTimeout)
      const recentTaps = tapSequence.filter(
        time => currentTime - time <= config.resetTimeout
      );
      
      if (recentTaps.length >= config.tapCount) {
        // Success! Enable admin mode
        setIsAdminMode(true);
        Alert.alert(
          '🔐 Modo Administrador',
          'Acceso administrativo activado',
          [
            {
              text: 'OK',
              onPress: () => console.log('Admin mode activated'),
            },
          ]
        );
        resetSequence();
        return;
      }
    }

    // Set timeout to reset sequence
    timeoutRef.current = setTimeout(() => {
      resetSequence();
    }, config.resetTimeout);
  }, [config, tapSequence, resetSequence]);

  const disableAdminMode = useCallback(() => {
    setIsAdminMode(false);
    resetSequence();
  }, [resetSequence]);

  const toggleAdminMode = useCallback(() => {
    setIsAdminMode(prev => !prev);
  }, []);

  return {
    isAdminMode,
    handleTap,
    disableAdminMode,
    toggleAdminMode,
    tapCount: tapCountRef.current,
    remainingTaps: config.tapCount - tapCountRef.current,
  };
};

export default useAdminAccess;
