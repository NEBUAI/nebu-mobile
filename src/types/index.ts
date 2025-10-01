// User and Auth Types
export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResponse {
  success: boolean;
  user?: User;
  tokens?: AuthTokens;
  error?: string;
}

export interface SocialAuthResult {
  success: boolean;
  user?: User;
  tokens?: AuthTokens;
  error?: string;
  appleCredential?: unknown;
}

export interface SocialAuthStatus {
  google: boolean;
  facebook: boolean;
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

// Theme and Language Types
export interface ThemeState {
  isDarkMode: boolean;
}

export interface LanguageState {
  currentLanguage: 'es' | 'en';
}

// IoT Types
export interface IoTDevice {
  id: string;
  name: string;
  type: string;
  status: 'online' | 'offline';
  lastSeen?: string;
  [key: string]: unknown;
}

export interface IoTMetrics {
  [key: string]: unknown;
}

export interface IoTState {
  devices: IoTDevice[];
  metrics: IoTMetrics;
  isLoading: boolean;
  error: string | null;
  selectedDevice: IoTDevice | null;
}

export interface RootState {
  auth: AuthState;
  theme: ThemeState;
  language: LanguageState;
  iot: IoTState;
}

export type RootStackParamList = {
  Splash: undefined;
  Auth: undefined;
  Main: undefined;
  HomeStack: undefined;
};

export type AuthStackParamList = {
  Login: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  IoTDashboard: undefined;
  VoiceAgent: undefined;
  Profile: undefined;
};

export type HomeStackParamList = {
  Home: undefined;
  Welcome: undefined;
  RobotSetup: undefined;
  DeviceManagement: undefined;
  QRScanner: undefined;
  DeviceSetup: { device: any };
  // Setup Flow Screens
  PersonalitySetup: undefined;
  FavoritesSetup: undefined;
  ToyNameSetup: undefined;
  AgeSetup: undefined;
  WorldInfoSetup: undefined;
  VoiceSetup: undefined;
  ConnectionSetup: undefined;
};

export interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  loading?: boolean;
  style?: any;
}

export interface InputProps {
  placeholder: string;
  value: string;
  onChangeText: (text: string) => void;
  secureTextEntry?: boolean;
  keyboardType?: 'default' | 'email-address' | 'numeric';
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  error?: string;
}

export interface HeaderProps {
  title: string;
  showBackButton?: boolean;
  onBackPress?: () => void;
  rightComponent?: React.ReactNode;
}
