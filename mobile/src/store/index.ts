import { configureStore } from '@reduxjs/toolkit';
import authSlice from './authSlice';
import themeSlice from './themeSlice';
import languageSlice from './languageSlice';
import iotSlice from './iotSlice';

export const store = configureStore({
  reducer: {
    auth: authSlice,
    theme: themeSlice,
    language: languageSlice,
    iot: iotSlice,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
