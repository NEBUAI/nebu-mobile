import React, { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/types';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

type SplashScreenNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'Splash'
>;

const { width, height } = Dimensions.get('window');

const SplashScreen: React.FC = () => {
  const { t } = useTranslation();
  const navigation = useNavigation<SplashScreenNavigationProp>();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const { isAuthenticated } = useAppSelector((state) => state.auth);
  const theme = getTheme(isDarkMode);

  useEffect(() => {
    const timer = setTimeout(() => {
      // TEMPORARY BYPASS: Navigate to the Home stack (renamed from 'Home')
      navigation.replace('HomeStack');
    }, 2000);

    return () => clearTimeout(timer);
  }, [navigation]);

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.primary,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  });

  const getLogoContainerStyle = (): ViewStyle => ({
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: theme.spacing.xl,
  });

  const getTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.xxxl,
    fontWeight: theme.typography.weights.bold,
    color: '#FFFFFF',
    textAlign: 'center',
    marginBottom: theme.spacing.sm,
  });

  const getSubtitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: 'rgba(255, 255, 255, 0.8)',
    textAlign: 'center',
  });

  return (
    <View style={[styles.container, getContainerStyle()]}>
      <View style={[styles.logoContainer, getLogoContainerStyle()]}>
        <Text style={styles.logoText}>N</Text>
      </View>
      <Text style={[styles.title, getTitleStyle()]}>{t('app.name')}</Text>
      <Text style={[styles.subtitle, getSubtitleStyle()]}>
        {t('app.tagline')}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoContainer: {
    width: 120,
    height: 120,
    borderRadius: 60,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoText: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFFFFF',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
    textAlign: 'center',
  },
});

export default SplashScreen;
