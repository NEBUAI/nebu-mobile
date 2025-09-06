import { configureStore } from '@reduxjs/toolkit';
import authSlice from './authSlice';
import themeSlice from './themeSlice';

export const store = configureStore({
  reducer: {
    auth: authSlice,
    theme: themeSlice,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
