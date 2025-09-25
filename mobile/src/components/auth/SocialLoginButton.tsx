import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ViewStyle,
  TextStyle,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface SocialLoginButtonProps {
  provider: 'google' | 'facebook' | 'apple';
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
}

const SocialLoginButton: React.FC<SocialLoginButtonProps> = ({
  provider,
  onPress,
  loading = false,
  disabled = false,
  style,
}) => {
  const getProviderConfig = () => {
    switch (provider) {
      case 'google':
        return {
          icon: 'logo-google',
          text: 'Continue with Google',
          backgroundColor: '#FFFFFF',
          textColor: '#000000',
          borderColor: '#E5E5E5',
        };
      case 'facebook':
        return {
          icon: 'logo-facebook',
          text: 'Continue with Facebook',
          backgroundColor: '#FFFFFF',
          textColor: '#000000',
          borderColor: '#E5E5E5',
        };
      case 'apple':
        return {
          icon: 'logo-apple',
          text: 'Continue with Apple',
          backgroundColor: '#FFFFFF',
          textColor: '#000000',
          borderColor: '#E5E5E5',
        };
      default:
        return {
          icon: 'logo-google',
          text: 'Continue',
          backgroundColor: '#FFFFFF',
          textColor: '#000000',
          borderColor: '#E5E5E5',
        };
    }
  };

  const config = getProviderConfig();

  return (
    <TouchableOpacity
      style={[
        styles.button,
        {
          backgroundColor: config.backgroundColor,
          borderColor: config.borderColor,
          opacity: disabled ? 0.6 : 1,
        },
        style,
      ]}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.8}
    >
      {loading ? (
        <ActivityIndicator size="small" color={config.textColor} />
      ) : (
        <Ionicons
          name={config.icon as any}
          size={20}
          color={config.textColor}
          style={styles.icon}
        />
      )}
      <Text style={[styles.text, { color: config.textColor }]}>
        {config.text}
      </Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderRadius: 12,
    borderWidth: 1,
    marginVertical: 6,
    minHeight: 52,
  },
  icon: {
    marginRight: 12,
  },
  text: {
    fontSize: 16,
    fontWeight: '500',
    flex: 1,
    textAlign: 'center',
  },
});

export default SocialLoginButton;
