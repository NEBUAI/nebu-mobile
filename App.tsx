import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { Provider } from 'react-redux';
import { store } from '@/store';
import { RootNavigator } from '@/navigation';
import { useAppSelector } from '@/store/hooks';

const AppContent: React.FC = () => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);

  return (
    <>
      <StatusBar style={isDarkMode ? 'light' : 'dark'} />
      <RootNavigator />
    </>
  );
};

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <AppContent />
    </Provider>
  );
};

export default App;
