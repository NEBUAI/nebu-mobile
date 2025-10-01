import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { Provider } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { store } from '@/store';
import { RootNavigator } from '@/navigation';
import { useAppSelector } from '@/store/hooks';
import '@/utils/i18n';

const AppContent: React.FC = () => {
  const { i18n } = useTranslation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const currentLanguage = useAppSelector((state) => state.language.currentLanguage);

  useEffect(() => {
    if (i18n.language !== currentLanguage) {
      i18n.changeLanguage(currentLanguage);
    }
  }, [currentLanguage, i18n]);

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
