import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { LoginManager, AccessToken } from 'react-native-fbsdk-next';
import { Platform } from 'react-native';
import { ENV_CONFIG } from '@/config/env';
import authService from './authService';
import type { SocialAuthResult, SocialAuthStatus } from '@/types';

class SocialAuthService {
  private isConfigured = false;

  constructor() {
    this.configureSDKs();
  }

  private configureSDKs() {
    if (this.isConfigured) return;

    // Configurar Google Sign-In
    GoogleSignin.configure({
      webClientId: ENV_CONFIG.GOOGLE_WEB_CLIENT_ID,
      offlineAccess: true,
      hostedDomain: '',
      forceCodeForRefreshToken: true,
    });

    // Configurar Facebook Login
    LoginManager.setLoginBehavior('web_only');

    this.isConfigured = true;
  }

  async googleLogin(): Promise<SocialAuthResult> {
    try {
      // Verificar que Google Play Services esté disponible
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });

      // Iniciar sesión con Google
      const userInfo = await GoogleSignin.signIn();

      if (!userInfo.data?.idToken) {
        throw new Error('No se pudo obtener el token de Google');
      }

      // Enviar token al backend
      const response = await authService.googleLogin(userInfo.data.idToken);

      return {
        success: true,
        user: response.user,
        tokens: {
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        },
      };
    } catch (error) {
      const err = error as { code?: string; message?: string };

      if (err.code === 'SIGN_IN_CANCELLED') {
        return { success: false, error: 'Login cancelado por el usuario' };
      }

      return { success: false, error: `Error en Google Sign-In: ${err.message || 'Unknown error'}` };
    }
  }

  async facebookLogin(): Promise<SocialAuthResult> {
    try {
      // Iniciar sesión con Facebook
      const result = await LoginManager.logInWithPermissions(['public_profile', 'email']);

      if (result.isCancelled) {
        return { success: false, error: 'Login cancelado por el usuario' };
      }

      // Obtener token de acceso
      const data = await AccessToken.getCurrentAccessToken();

      if (!data || !data.accessToken) {
        throw new Error('No se pudo obtener el token de Facebook');
      }

      // Enviar token al backend
      const response = await authService.facebookLogin(data.accessToken);

      return {
        success: true,
        user: response.user,
        tokens: {
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        },
      };
    } catch (error) {
      const err = error as { message?: string };
      return { success: false, error: `Error en Facebook Login: ${err.message || 'Unknown error'}` };
    }
  }

  async appleLogin(): Promise<SocialAuthResult> {
    try {
      // Verificar si estamos en iOS
      if (Platform.OS !== 'ios') {
        return { success: false, error: 'Apple Sign-In solo está disponible en iOS' };
      }

      // TODO: Implementar Apple Sign-In real cuando el módulo esté disponible
      // Por ahora, simulamos con un token mock
      const mockToken = 'apple_mock_token_' + Date.now();
      const response = await authService.appleLogin(mockToken);

      return {
        success: true,
        user: response.user,
        tokens: {
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        },
        appleCredential: null, // Mock credential
      };
    } catch (error) {
      const err = error as { code?: string; message?: string };

      if (err.code === 'ERR_CANCELED') {
        return { success: false, error: 'Login cancelado por el usuario' };
      }

      return { success: false, error: `Error en Apple Sign-In: ${err.message || 'Unknown error'}` };
    }
  }

  async logout(): Promise<void> {
    try {
      // Cerrar sesión en Google
      await GoogleSignin.signOut();

      // Cerrar sesión en Facebook
      LoginManager.logOut();

      // Apple Sign-In no requiere logout explícito
    } catch (error) {
      // Silently fail logout
    }
  }

  async isSignedIn(): Promise<SocialAuthStatus> {
    try {
      const [googleUser, facebookToken] = await Promise.all([
        GoogleSignin.getCurrentUser(),
        AccessToken.getCurrentAccessToken(),
      ]);

      return {
        google: !!googleUser,
        facebook: !!facebookToken,
      };
    } catch {
      return { google: false, facebook: false };
    }
  }

  async getCurrentUser(): Promise<{ google: unknown; facebook: unknown } | null> {
    try {
      const [googleUser, facebookToken] = await Promise.all([
        GoogleSignin.getCurrentUser(),
        AccessToken.getCurrentAccessToken(),
      ]);

      return {
        google: googleUser,
        facebook: facebookToken,
      };
    } catch {
      return null;
    }
  }
}

export default new SocialAuthService();
