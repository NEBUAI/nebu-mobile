import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useTranslation } from 'react-i18next';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

import HomeScreen from '@/screens/HomeScreen';
import RobotSetupScreen from '@/screens/RobotSetupScreen';

export type HomeStackParamList = {
  Home: undefined;
  RobotSetup: undefined;
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
    </Stack.Navigator>
  );
};

export default HomeStackNavigator;
