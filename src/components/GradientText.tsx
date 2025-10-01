import React from 'react';
import { Text, StyleSheet, TextStyle } from 'react-native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

interface GradientTextProps {
  children: string;
  style?: TextStyle;
  colors?: string[];
  locations?: number[];
  start?: { x: number; y: number };
  end?: { x: number; y: number };
  variant?: 'primary' | 'secondary' | 'accent' | 'custom';
}

const GradientText: React.FC<GradientTextProps> = ({
  children,
  style,
  colors: customColors,
  locations,
  start = { x: 0, y: 0 },
  end = { x: 1, y: 0 },
  variant = 'primary',
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const getGradientColors = (): string[] => {
    if (customColors) return customColors;

    const variants = {
      primary: [theme.colors.primary, theme.colors.primaryDark],
      secondary: [theme.colors.secondary, theme.colors.gold],
      accent: [theme.colors.accent, theme.colors.primary],
      custom: [theme.colors.primary, theme.colors.accent],
    };

    return variants[variant];
  };

  const getTextStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.bold,
    ...style,
  });

  // Simplified version without external dependencies
  // Use primary color for now, can be enhanced later with expo-linear-gradient
  return (
    <Text style={[styles.text, getTextStyle(), { color: theme.colors.primary }]}>
      {children}
    </Text>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
  },
  text: {
    backgroundColor: 'transparent',
  },
  gradient: {
    flex: 1,
    height: '100%',
  },
});

export default GradientText;
