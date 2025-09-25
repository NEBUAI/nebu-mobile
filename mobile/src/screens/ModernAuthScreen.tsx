import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  TouchableOpacity,
  Alert,
  Dimensions,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { useTranslation } from 'react-i18next';
import { LinearGradient } from 'expo-linear-gradient';

import ModernInput from '@/components/auth/ModernInput';
import PrimaryButton from '@/components/auth/PrimaryButton';
import SocialLoginButton from '@/components/auth/SocialLoginButton';
import { useAppDispatch, useAppSelector } from '@/store/hooks';
import { loginSuccess, setLoading } from '@/store/authSlice';
import authService from '@/services/authService';
import socialAuthService from '@/services/socialAuthService';

const { width } = Dimensions.get('window');

type AuthMode = 'login' | 'signup';

const ModernAuthScreen: React.FC = () => {
  const [mode, setMode] = useState<AuthMode>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errors, setErrors] = useState({
    email: '',
    password: '',
    confirmPassword: '',
  });

  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const { isLoading } = useAppSelector((state) => state.auth);

  const validateForm = () => {
    const newErrors = { email: '', password: '', confirmPassword: '' };
    let isValid = true;

    // Email validation
    if (!email) {
      newErrors.email = 'Email is required';
      isValid = false;
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = 'Please enter a valid email';
      isValid = false;
    }

    // Password validation
    if (!password) {
      newErrors.password = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
      isValid = false;
    }

    // Confirm password validation (only for signup)
    if (mode === 'signup') {
      if (!confirmPassword) {
        newErrors.confirmPassword = 'Please confirm your password';
        isValid = false;
      } else if (password !== confirmPassword) {
        newErrors.confirmPassword = 'Passwords do not match';
        isValid = false;
      }
    }

    setErrors(newErrors);
    return isValid;
  };

  const handleEmailAuth = async () => {
    if (!validateForm()) return;

    dispatch(setLoading(true));

    try {
      let response;
      
      if (mode === 'login') {
        response = await authService.login({ email, password });
      } else {
        response = await authService.register({ email, password });
      }

      dispatch(loginSuccess({
        id: response.user.id,
        email: response.user.email,
        name: `${response.user.firstName} ${response.user.lastName}`.trim(),
        avatar: response.user.avatar,
      }));
    } catch (error) {
      Alert.alert('Error', error.message || 'Authentication failed. Please try again.');
    } finally {
      dispatch(setLoading(false));
    }
  };

  const handleGoogleLogin = async () => {
    dispatch(setLoading(true));
    
    try {
      const result = await socialAuthService.googleLogin();
      
      if (result.success) {
        dispatch(loginSuccess({
          id: result.user.id,
          email: result.user.email,
          name: result.user.name,
          avatar: result.user.avatar,
        }));
        Alert.alert(t('common.success'), t('auth.loginSuccess'));
      } else {
        Alert.alert(t('common.error'), result.error || t('auth.loginError'));
      }
    } catch (error) {
      Alert.alert('Error', error.message || 'Google Sign-In failed. Please try again.');
    } finally {
      dispatch(setLoading(false));
    }
  };

  const handleFacebookLogin = async () => {
    dispatch(setLoading(true));
    
    try {
      const result = await socialAuthService.facebookLogin();
      
      if (result.success) {
        dispatch(loginSuccess({
          id: result.user.id,
          email: result.user.email,
          name: result.user.name,
          avatar: result.user.avatar,
        }));
        Alert.alert(t('common.success'), t('auth.loginSuccess'));
      } else {
        Alert.alert(t('common.error'), result.error || t('auth.loginError'));
      }
    } catch (error) {
      Alert.alert('Error', error.message || 'Facebook Login failed. Please try again.');
    } finally {
      dispatch(setLoading(false));
    }
  };

  const handleAppleLogin = async () => {
    dispatch(setLoading(true));
    
    try {
      const result = await socialAuthService.appleLogin();
      
      if (result.success) {
        dispatch(loginSuccess({
          id: result.user.id,
          email: result.user.email,
          name: result.user.name,
          avatar: result.user.avatar,
        }));
        Alert.alert(t('common.success'), t('auth.loginSuccess'));
      } else {
        Alert.alert(t('common.error'), result.error || t('auth.loginError'));
      }
    } catch (error) {
      Alert.alert('Error', error.message || 'Apple Sign-In failed. Please try again.');
    } finally {
      dispatch(setLoading(false));
    }
  };

  const toggleMode = () => {
    setMode(mode === 'login' ? 'signup' : 'login');
    setErrors({ email: '', password: '', confirmPassword: '' });
    setConfirmPassword('');
  };

  return (
    <View style={styles.container}>
      <StatusBar style="dark" />
      
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={styles.keyboardView}
        >
          {/* Header */}
          <View style={styles.header}>
            <View style={styles.logoContainer}>
              <View style={styles.logo}>
                <Text style={styles.logoText}>N</Text>
              </View>
            </View>
            
            <Text style={styles.title}>
              {mode === 'login' ? 'Log in' : 'Sign up'}
            </Text>
            
            <Text style={styles.subtitle}>
              {mode === 'login' 
                ? 'Welcome back! Please sign in to your account.'
                : 'Create your account to get started.'
              }
            </Text>
          </View>

          {/* Form */}
          <View style={styles.form}>
            <ModernInput
              placeholder="Email"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              error={errors.email}
            />

            <ModernInput
              placeholder="Password"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              showPasswordToggle
              error={errors.password}
            />

            {mode === 'signup' && (
              <ModernInput
                placeholder="Confirm Password"
                value={confirmPassword}
                onChangeText={setConfirmPassword}
                secureTextEntry
                showPasswordToggle
                error={errors.confirmPassword}
              />
            )}

            <PrimaryButton
              title={mode === 'login' ? 'Continue' : 'Create Account'}
              onPress={handleEmailAuth}
              loading={isLoading}
              style={styles.primaryButton}
            />
          </View>

          {/* Divider */}
          <View style={styles.divider}>
            <View style={styles.dividerLine} />
            <Text style={styles.dividerText}>or</Text>
            <View style={styles.dividerLine} />
          </View>

          {/* Social Login */}
          <View style={styles.socialContainer}>
            <SocialLoginButton
              provider="google"
              onPress={handleGoogleLogin}
              loading={isLoading}
              disabled={isLoading}
            />
            
            <SocialLoginButton
              provider="apple"
              onPress={handleAppleLogin}
              loading={isLoading}
              disabled={isLoading}
            />
            
            <SocialLoginButton
              provider="facebook"
              onPress={handleFacebookLogin}
              loading={isLoading}
              disabled={isLoading}
            />
          </View>

          {/* Footer */}
          <View style={styles.footer}>
            <TouchableOpacity onPress={toggleMode} style={styles.toggleButton}>
              <Text style={styles.toggleText}>
                {mode === 'login' 
                  ? "Don't have an account? Sign up"
                  : 'Already have an account? Log in'
                }
              </Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.helpButton}>
              <Text style={styles.helpText}>Need help signing in?</Text>
            </TouchableOpacity>
          </View>
        </KeyboardAvoidingView>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 40,
  },
  keyboardView: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    marginBottom: 40,
  },
  logoContainer: {
    marginBottom: 24,
  },
  logo: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#000000',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 8,
  },
  logoText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#000000',
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#8E8E93',
    textAlign: 'center',
    lineHeight: 24,
    paddingHorizontal: 20,
  },
  form: {
    marginBottom: 32,
  },
  primaryButton: {
    marginTop: 8,
  },
  divider: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 32,
  },
  dividerLine: {
    flex: 1,
    height: 1,
    backgroundColor: '#E5E5E7',
  },
  dividerText: {
    fontSize: 14,
    color: '#8E8E93',
    paddingHorizontal: 16,
    fontWeight: '500',
  },
  socialContainer: {
    marginBottom: 32,
  },
  footer: {
    alignItems: 'center',
    marginTop: 'auto',
  },
  toggleButton: {
    marginBottom: 16,
  },
  toggleText: {
    fontSize: 16,
    color: '#007AFF',
    fontWeight: '500',
  },
  helpButton: {
    marginTop: 8,
  },
  helpText: {
    fontSize: 16,
    color: '#8E8E93',
    fontWeight: '400',
  },
});

export default ModernAuthScreen;
