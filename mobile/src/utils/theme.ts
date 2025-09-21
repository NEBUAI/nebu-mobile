export const colors = {
  // Nebu brand colors inspired by reference CSS
  primary: '#2F27CE', // Brand primary from reference
  primaryDark: '#433BFF', // Brand accent from reference
  secondary: '#CE965E', // Gold accent from reference
  tertiary: '#4ECDC4', // Teal for IoT elements
  success: '#51CF66',
  warning: '#f59e0b', // Modern amber from reference
  error: '#dc2626', // Error red from reference
  
  // Additional semantic colors
  gold: '#CE965E',
  accent: '#433BFF',
  yellow: '#f59e0b',
  
  // Light theme colors - Warm Neutral Theme from reference
  light: {
    background: '#fafafa', // Subtle warm background
    surface: '#fefefe', // Off-white for cards
    card: '#FFFFF1', // Pure white cards
    text: '#374151', // Softer dark gray
    textSecondary: '#4b5563', // Warm medium gray
    border: '#e5e7eb', // Warm light border
    placeholder: '#9ca3af', // Medium gray placeholder
    muted: '#f3f4f6', // Light warm gray
    accent: '#f9fafb', // Very light warm gray
  },
  
  // Dark theme colors - Nebu dark palette from reference
  dark: {
    background: '#0b0b13', // Deep dark background
    surface: '#12121b', // Dark surface
    card: '#1e1e2a', // Dark card background
    text: '#e6e6f0', // Light text
    textSecondary: '#a1a1aa', // Medium gray text
    border: '#2a2a3a', // Dark border
    placeholder: '#6b7280', // Dark placeholder
    muted: '#2a2a3a', // Dark muted
    accent: '#1e1e2a', // Dark accent
  },
};

export const typography = {
  sizes: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 18,
    xl: 20,
    xxl: 24,
    xxxl: 32,
  },
  weights: {
    regular: '400' as const,
    medium: '500' as const,
    semibold: '600' as const,
    bold: '700' as const,
  },
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

export const borderRadius = {
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  full: 9999,
};

export const shadows = {
  sm: {
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.18,
    shadowRadius: 1.0,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.23,
    shadowRadius: 2.62,
    elevation: 4,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.30,
    shadowRadius: 4.65,
    elevation: 8,
  },
  // Glow effect inspired by reference CSS
  glow: {
    shadowColor: '#2F27CE',
    shadowOffset: {
      width: 0,
      height: 0,
    },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 12,
  },
  // Hover lift effect
  lift: {
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 8,
    },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 16,
  },
};

// Animation configurations inspired by reference CSS
export const animations = {
  // Timing functions
  timing: {
    fast: 200,
    normal: 300,
    slow: 500,
    verySlow: 800,
  },
  
  // Easing curves
  easing: {
    easeOut: 'ease-out',
    easeIn: 'ease-in',
    easeInOut: 'ease-in-out',
    spring: 'spring',
  },
  
  // Scale animations
  scale: {
    small: 0.95,
    normal: 1.0,
    large: 1.05,
    hover: 1.02,
  },
  
  // Opacity animations
  opacity: {
    hidden: 0,
    visible: 1,
    muted: 0.6,
    disabled: 0.4,
  },
  
  // Transform values
  transform: {
    slideDistance: 30,
    liftDistance: -8,
    floatDistance: 10,
  },
};

export const getTheme = (isDarkMode: boolean) => ({
  colors: {
    ...colors,
    ...(isDarkMode ? colors.dark : colors.light),
  },
  typography,
  spacing,
  borderRadius,
  shadows,
  animations,
  isDarkMode,
});
