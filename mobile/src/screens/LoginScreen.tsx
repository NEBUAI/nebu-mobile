import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { useTranslation } from 'react-i18next';
import { Button, Input } from '@/components';
import { useAppDispatch, useAppSelector } from '@/store/hooks';
import { loginSuccess, setLoading } from '@/store/authSlice';
import { getTheme } from '@/utils/theme';

const LoginScreen: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({ email: '', password: '' });

  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const { isLoading } = useAppSelector((state) => state.auth);
  const theme = getTheme(isDarkMode);

  const validateForm = () => {
    const newErrors = { email: '', password: '' };
    let isValid = true;

    if (!email) {
      newErrors.email = t('auth.validation.emailRequired');
      isValid = false;
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = t('auth.validation.emailInvalid');
      isValid = false;
    }

    if (!password) {
      newErrors.password = t('auth.validation.passwordRequired');
      isValid = false;
    } else if (password.length < 6) {
      newErrors.password = t('auth.validation.passwordMinLength');
      isValid = false;
    }

    setErrors(newErrors);
    return isValid;
  };

  const handleLogin = async () => {
    if (!validateForm()) return;

    dispatch(setLoading(true));

    // Auto login for testing LiveKit features
    setTimeout(() => {
      dispatch(loginSuccess({
        id: '1',
        email: email,
        name: 'LiveKit Tester',
        avatar: undefined,
      }));
    }, 1000);
  };

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getContentStyle = (): ViewStyle => ({
    paddingHorizontal: theme.spacing.lg,
    paddingTop: theme.spacing.xxl * 2,
  });

  const getLogoContainerStyle = (): ViewStyle => ({
    alignItems: 'center',
    marginBottom: theme.spacing.xxl,
  });

  const getLogoStyle = (): ViewStyle => ({
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: theme.colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: theme.spacing.md,
  });

  const getTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.xxl,
    fontWeight: theme.typography.weights.bold,
    color: theme.colors.text,
    textAlign: 'center',
    marginBottom: theme.spacing.sm,
  });

  const getSubtitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: theme.colors.textSecondary,
    textAlign: 'center',
    marginBottom: theme.spacing.xl,
  });

  return (
    <KeyboardAvoidingView
      style={[styles.container, getContainerStyle()]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        contentContainerStyle={[styles.content, getContentStyle()]}
        keyboardShouldPersistTaps="handled"
      >
        <View style={[styles.logoContainer, getLogoContainerStyle()]}>
          <View style={[styles.logo, getLogoStyle()]}>
            <Text style={styles.logoText}>N</Text>
          </View>
          <Text style={[styles.title, getTitleStyle()]}>{t('auth.welcome')}</Text>
          <Text style={[styles.subtitle, getSubtitleStyle()]}>
            {t('auth.welcomeSubtitle')}
          </Text>
        </View>

        <View style={styles.form}>
          <Input
            placeholder={t('auth.email')}
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
            error={errors.email}
          />

          <Input
            placeholder={t('auth.password')}
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            error={errors.password}
          />

          <View style={styles.buttonContainer}>
            <Button
              title={t('auth.login')}
              onPress={handleLogin}
              loading={isLoading}
              size="large"
            />
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flexGrow: 1,
    justifyContent: 'center',
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 40,
  },
  logo: {
    width: 80,
    height: 80,
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 32,
  },
  form: {
    width: '100%',
  },
  buttonContainer: {
    marginTop: 24,
  },
});

export default LoginScreen;
