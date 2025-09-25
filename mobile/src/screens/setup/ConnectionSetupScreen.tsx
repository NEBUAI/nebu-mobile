import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Animated,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

const ConnectionSetupScreen: React.FC = () => {
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [isConnecting, setIsConnecting] = useState(false);
  const [isScanning, setIsScanning] = useState(false);
  const [scanAnimation] = useState(new Animated.Value(0));

  const handleBack = () => {
    navigation.goBack();
  };

  const handleConnectNow = () => {
    setIsConnecting(true);
    setIsScanning(true);
    
    // Start scanning animation
    Animated.loop(
      Animated.sequence([
        Animated.timing(scanAnimation, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(scanAnimation, {
          toValue: 0,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    ).start();

    // Simulate connection process
    setTimeout(() => {
      setIsScanning(false);
      setIsConnecting(false);
      scanAnimation.stopAnimation();
      
      // Navigate to Home screen after successful connection
      Alert.alert(
        'Connection Successful!',
        'Your Nebu has been connected successfully!',
        [
          {
            text: 'Continue',
            onPress: () => navigation.navigate('Home' as never),
          },
        ]
      );
    }, 5000);
  };

  const handleConnectLater = () => {
    Alert.alert(
      'Setup Complete',
      'You can connect your Nebu later from the settings.',
      [
        {
          text: 'Continue',
          onPress: () => navigation.navigate('Home' as never),
        },
      ]
    );
  };

  const renderScanningAnimation = () => {
    const scale = scanAnimation.interpolate({
      inputRange: [0, 1],
      outputRange: [1, 1.2],
    });

    const opacity = scanAnimation.interpolate({
      inputRange: [0, 1],
      outputRange: [0.3, 0.8],
    });

    return (
      <View style={styles.scanningContainer}>
        <Animated.View
          style={[
            styles.scanningCircle,
            {
              backgroundColor: theme.colors.primary,
              transform: [{ scale }],
              opacity,
            },
          ]}
        />
        <Animated.View
          style={[
            styles.scanningCircle,
            styles.scanningCircle2,
            {
              backgroundColor: theme.colors.secondary,
              transform: [{ scale }],
              opacity: opacity,
            },
          ]}
        />
        <Animated.View
          style={[
            styles.scanningCircle,
            styles.scanningCircle3,
            {
              backgroundColor: theme.colors.tertiary,
              transform: [{ scale }],
              opacity: opacity,
            },
          ]}
        />
      </View>
    );
  };

  const renderConnectionContent = () => {
    if (isScanning) {
      return (
        <View style={styles.content}>
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Searching for Your Nebu...
          </Text>
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            Please wait while we scan for nearby devices
          </Text>
          {renderScanningAnimation()}
        </View>
      );
    }

    if (isConnecting) {
      return (
        <View style={styles.content}>
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Let's find your Nebu!
          </Text>
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            Make sure your Nebu is turned on and nearby. We'll scan for it and help you connect.
          </Text>
          {renderScanningAnimation()}
        </View>
      );
    }

    return (
      <View style={styles.content}>
        <Text style={[styles.title, { color: theme.colors.text }]}>
          Would you like to connect your Nebu now?
        </Text>
        
        {/* Illustration placeholder */}
        <View style={styles.illustrationContainer}>
          <View style={[styles.personIllustration, { backgroundColor: theme.colors.textSecondary }]} />
          <View style={[styles.nebuIllustration, { backgroundColor: theme.colors.primary }]} />
          <Ionicons 
            name="bluetooth" 
            size={40} 
            color={theme.colors.primary} 
            style={styles.bluetoothIcon}
          />
        </View>
      </View>
    );
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      {/* Header */}
      <View style={[styles.header, { backgroundColor: theme.colors.background }]}>
        <TouchableOpacity style={styles.headerButton} onPress={handleBack}>
          <Ionicons name="arrow-back" size={24} color={theme.colors.text} />
        </TouchableOpacity>
        
        {/* Progress Bar */}
        <View style={[styles.progressContainer, { backgroundColor: theme.colors.border }]}>
          <View style={[styles.progressBar, { backgroundColor: theme.colors.primary, width: '100%' }]} />
        </View>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {renderConnectionContent()}
      </ScrollView>

      {/* Action Buttons */}
      {!isConnecting && !isScanning && (
        <View style={styles.bottomContainer}>
          <TouchableOpacity
            style={[styles.primaryButton, { backgroundColor: theme.colors.primary }]}
            onPress={handleConnectNow}
          >
            <Text style={styles.primaryButtonText}>Connect Now</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.secondaryButton, { borderColor: theme.colors.border }]}
            onPress={handleConnectLater}
          >
            <Text style={[styles.secondaryButtonText, { color: theme.colors.text }]}>
              Connect Later
            </Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 20,
  },
  headerButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.05)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  progressContainer: {
    flex: 1,
    height: 4,
    borderRadius: 2,
  },
  progressBar: {
    height: '100%',
    borderRadius: 2,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 40,
    paddingBottom: 40,
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    lineHeight: 32,
    marginBottom: 16,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 60,
    textAlign: 'center',
  },
  illustrationContainer: {
    width: 200,
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  personIllustration: {
    width: 60,
    height: 80,
    borderRadius: 30,
    position: 'absolute',
    left: 20,
    bottom: 20,
  },
  nebuIllustration: {
    width: 80,
    height: 80,
    borderRadius: 40,
    position: 'absolute',
    right: 20,
    bottom: 20,
  },
  bluetoothIcon: {
    position: 'absolute',
    top: 20,
    right: 20,
  },
  scanningContainer: {
    width: 120,
    height: 120,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  scanningCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    position: 'absolute',
  },
  scanningCircle2: {
    width: 100,
    height: 100,
    borderRadius: 50,
  },
  scanningCircle3: {
    width: 80,
    height: 80,
    borderRadius: 40,
  },
  bottomContainer: {
    paddingHorizontal: 20,
    paddingBottom: 40,
    gap: 16,
  },
  primaryButton: {
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryButton: {
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    borderWidth: 1,
  },
  secondaryButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default ConnectionSetupScreen;
