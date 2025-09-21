import React from 'react';
import { Text, StyleSheet, TextStyle } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import MaskedView from '@react-native-masked-view/masked-view';
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

  return (
    <MaskedView
      style={styles.container}
      maskElement={
        <Text style={[styles.text, getTextStyle()]}>
          {children}
        </Text>
      }
    >
      <LinearGradient
        colors={getGradientColors()}
        locations={locations}
        start={start}
        end={end}
        style={styles.gradient}
      />
    </MaskedView>
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
