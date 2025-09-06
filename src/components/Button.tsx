import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { ButtonProps } from '@/types';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  loading = false,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const getButtonStyle = (): ViewStyle => {
    const baseStyle: ViewStyle = {
      borderRadius: theme.borderRadius.md,
      alignItems: 'center',
      justifyContent: 'center',
      flexDirection: 'row',
    };

    // Size styles
    switch (size) {
      case 'small':
        baseStyle.paddingVertical = theme.spacing.sm;
        baseStyle.paddingHorizontal = theme.spacing.md;
        baseStyle.minHeight = 36;
        break;
      case 'large':
        baseStyle.paddingVertical = theme.spacing.md;
        baseStyle.paddingHorizontal = theme.spacing.xl;
        baseStyle.minHeight = 56;
        break;
      default:
        baseStyle.paddingVertical = theme.spacing.sm + 2;
        baseStyle.paddingHorizontal = theme.spacing.lg;
        baseStyle.minHeight = 48;
    }

    // Variant styles
    switch (variant) {
      case 'secondary':
        baseStyle.backgroundColor = theme.colors.surface;
        baseStyle.borderWidth = 1;
        baseStyle.borderColor = theme.colors.border;
        break;
      case 'outline':
        baseStyle.backgroundColor = 'transparent';
        baseStyle.borderWidth = 1;
        baseStyle.borderColor = theme.colors.primary;
        break;
      default:
        baseStyle.backgroundColor = theme.colors.primary;
    }

    // Disabled state
    if (disabled || loading) {
      baseStyle.opacity = 0.6;
    }

    return baseStyle;
  };

  const getTextStyle = (): TextStyle => {
    const baseStyle: TextStyle = {
      fontWeight: theme.typography.weights.semibold,
    };

    // Size styles
    switch (size) {
      case 'small':
        baseStyle.fontSize = theme.typography.sizes.sm;
        break;
      case 'large':
        baseStyle.fontSize = theme.typography.sizes.lg;
        break;
      default:
        baseStyle.fontSize = theme.typography.sizes.md;
    }

    // Variant styles
    switch (variant) {
      case 'secondary':
        baseStyle.color = theme.colors.text;
        break;
      case 'outline':
        baseStyle.color = theme.colors.primary;
        break;
      default:
        baseStyle.color = '#FFFFFF';
    }

    return baseStyle;
  };

  return (
    <TouchableOpacity
      style={[styles.button, getButtonStyle()]}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.7}
    >
      {loading && (
        <ActivityIndicator
          size="small"
          color={variant === 'primary' ? '#FFFFFF' : theme.colors.primary}
          style={styles.loader}
        />
      )}
      <Text style={[styles.text, getTextStyle()]}>
        {title}
      </Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    textAlign: 'center',
  },
  loader: {
    marginRight: 8,
  },
});

export default Button;
