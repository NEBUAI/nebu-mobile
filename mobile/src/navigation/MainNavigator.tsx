import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { MainTabParamList } from '@/types';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

import HomeStackNavigator from './HomeStackNavigator';
import ProfileScreen from '@/screens/ProfileScreen';
import IoTDashboardScreen from '@/screens/IoTDashboardScreen';
import VoiceAgentScreen from '@/screens/VoiceAgentScreen';

const Tab = createBottomTabNavigator<MainTabParamList>();

const MainNavigator: React.FC = () => {
  const { t } = useTranslation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: keyof typeof Ionicons.glyphMap;

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'IoTDashboard') {
            iconName = focused ? 'hardware-chip' : 'hardware-chip-outline';
          } else if (route.name === 'VoiceAgent') {
            iconName = focused ? 'mic' : 'mic-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          } else {
            iconName = 'help-outline';
          }

          return <Ionicons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.textSecondary,
        tabBarStyle: {
          backgroundColor: theme.colors.background,
          borderTopColor: theme.colors.border,
          borderTopWidth: 1,
          paddingTop: 8,
          paddingBottom: 8,
          height: 60,
        },
        tabBarLabelStyle: {
          fontSize: theme.typography.sizes.xs,
          fontWeight: theme.typography.weights.medium,
          marginTop: 4,
        },
      })}
    >
      <Tab.Screen 
        name="Home" 
        component={HomeStackNavigator}
        options={{
          tabBarLabel: t('navigation.home'),
        }}
      />
      <Tab.Screen 
        name="IoTDashboard" 
        component={IoTDashboardScreen}
        options={{
          tabBarLabel: 'LiveKit',
        }}
      />
      <Tab.Screen 
        name="VoiceAgent" 
        component={VoiceAgentScreen}
        options={{
          tabBarLabel: '🤖 AI Voice',
        }}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileScreen}
        options={{
          tabBarLabel: t('navigation.profile'),
        }}
      />
    </Tab.Navigator>
  );
};

export default MainNavigator;
