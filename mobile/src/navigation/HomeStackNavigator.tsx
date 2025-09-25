import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useTranslation } from 'react-i18next';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

import HomeScreen from '@/screens/HomeScreen';
import WelcomeScreen from '@/screens/WelcomeScreen';
import RobotSetupScreen from '@/screens/RobotSetupScreen';
import DeviceManagementScreen from '@/screens/DeviceManagementScreen';
import QRScannerScreen from '@/screens/QRScannerScreen';
import DeviceSetupScreen from '@/screens/DeviceSetupScreen';
import {
  PersonalitySetupScreen,
  FavoritesSetupScreen,
  ToyNameSetupScreen,
  AgeSetupScreen,
  WorldInfoSetupScreen,
  VoiceSetupScreen,
  ConnectionSetupScreen,
} from '@/screens/setup';

export type HomeStackParamList = {
  Welcome: undefined;
  Home: undefined;
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

const Stack = createNativeStackNavigator<HomeStackParamList>();

const HomeStackNavigator: React.FC = () => {
  const { t } = useTranslation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <Stack.Screen name="Welcome" component={WelcomeScreen} />
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen 
        name="RobotSetup" 
        component={RobotSetupScreen}
        options={{
          headerShown: true,
          title: t('robotSetup.title'),
          headerStyle: {
            backgroundColor: theme.colors.background,
          },
          headerTintColor: theme.colors.text,
          headerTitleStyle: {
            fontWeight: '600',
          },
        }}
      />
      <Stack.Screen 
        name="DeviceManagement" 
        component={DeviceManagementScreen}
        options={{
          headerShown: true,
          title: t('deviceManagement.title'),
          headerStyle: {
            backgroundColor: theme.colors.background,
          },
          headerTintColor: theme.colors.text,
          headerTitleStyle: {
            fontWeight: '600',
          },
        }}
      />
      <Stack.Screen 
        name="QRScanner" 
        component={QRScannerScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="DeviceSetup" 
        component={DeviceSetupScreen}
        options={{
          headerShown: true,
          title: t('deviceSetup.title'),
          headerStyle: {
            backgroundColor: theme.colors.background,
          },
          headerTintColor: theme.colors.text,
          headerTitleStyle: {
            fontWeight: '600',
          },
        }}
      />
      
      {/* Setup Flow Screens */}
      <Stack.Screen 
        name="PersonalitySetup" 
        component={PersonalitySetupScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="FavoritesSetup" 
        component={FavoritesSetupScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="ToyNameSetup" 
        component={ToyNameSetupScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="AgeSetup" 
        component={AgeSetupScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="WorldInfoSetup" 
        component={WorldInfoSetupScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="VoiceSetup" 
        component={VoiceSetupScreen}
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="ConnectionSetup" 
        component={ConnectionSetupScreen}
        options={{
          headerShown: false,
        }}
      />
    </Stack.Navigator>
  );
};

export default HomeStackNavigator;
