import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ViewStyle,
  TextStyle,
  ActivityIndicator,
} from 'react-native';

interface PrimaryButtonProps {
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  size?: 'small' | 'medium' | 'large';
}

const PrimaryButton: React.FC<PrimaryButtonProps> = ({
  title,
  onPress,
  loading = false,
  disabled = false,
  style,
  textStyle,
  size = 'large',
}) => {
  const getButtonStyle = (): ViewStyle => {
    const baseStyle: ViewStyle = {
      backgroundColor: '#000000',
      borderRadius: 12,
      alignItems: 'center',
      justifyContent: 'center',
      opacity: disabled ? 0.6 : 1,
    };

    switch (size) {
      case 'small':
        return { ...baseStyle, paddingVertical: 12, paddingHorizontal: 20, minHeight: 44 };
      case 'medium':
        return { ...baseStyle, paddingVertical: 14, paddingHorizontal: 24, minHeight: 48 };
      case 'large':
        return { ...baseStyle, paddingVertical: 16, paddingHorizontal: 24, minHeight: 52 };
      default:
        return baseStyle;
    }
  };

  const getTextStyle = (): TextStyle => {
    const baseStyle: TextStyle = {
      color: '#FFFFFF',
      fontWeight: '600',
      textAlign: 'center',
    };

    switch (size) {
      case 'small':
        return { ...baseStyle, fontSize: 14 };
      case 'medium':
        return { ...baseStyle, fontSize: 15 };
      case 'large':
        return { ...baseStyle, fontSize: 16 };
      default:
        return baseStyle;
    }
  };

  return (
    <TouchableOpacity
      style={[getButtonStyle(), style]}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.8}
    >
      {loading ? (
        <ActivityIndicator size="small" color="#FFFFFF" />
      ) : (
        <Text style={[getTextStyle(), textStyle]}>{title}</Text>
      )}
    </TouchableOpacity>
  );
};

export default PrimaryButton;
