import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { LoginManager, AccessToken } from 'react-native-fbsdk-next';
import { AppleAuthentication } from 'expo-apple-authentication';
import { Platform, Alert } from 'react-native';
import { ENV_CONFIG } from '@/config/env';
import authService from './authService';

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

  async googleLogin(): Promise<any> {
    try {
      // Verificar que Google Play Services esté disponible
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });

      // Iniciar sesión con Google
      const userInfo = await GoogleSignin.signIn();

      if (!userInfo.idToken) {
        throw new Error('No se pudo obtener el token de Google');
      }

      // Enviar token al backend
      const response = await authService.googleLogin(userInfo.idToken);

      return {
        success: true,
        user: response.user,
        tokens: {
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        },
      };
    } catch (error: any) {
      console.error('Google Sign-In Error:', error);
      
      if (error.code === 'SIGN_IN_CANCELLED') {
        return { success: false, error: 'Login cancelado por el usuario' };
      }
      
      return { success: false, error: 'Error en Google Sign-In: ' + error.message };
    }
  }

  async facebookLogin(): Promise<any> {
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
    } catch (error: any) {
      console.error('Facebook Login Error:', error);
      return { success: false, error: 'Error en Facebook Login: ' + error.message };
    }
  }

  async appleLogin(): Promise<any> {
    try {
      // Verificar si Apple Sign-In está disponible
      if (!AppleAuthentication.isAvailable) {
        return { success: false, error: 'Apple Sign-In no está disponible en este dispositivo' };
      }

      // Iniciar sesión con Apple
      const credential = await AppleAuthentication.signInAsync({
        requestedScopes: [
          AppleAuthentication.AppleAuthenticationScope.FULL_NAME,
          AppleAuthentication.AppleAuthenticationScope.EMAIL,
        ],
      });

      if (!credential.identityToken) {
        throw new Error('No se pudo obtener el token de Apple');
      }

      // Enviar token al backend
      const response = await authService.appleLogin(credential.identityToken);

      return {
        success: true,
        user: response.user,
        tokens: {
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        },
        appleCredential: credential, // Para información adicional de Apple
      };
    } catch (error: any) {
      console.error('Apple Sign-In Error:', error);
      
      if (error.code === 'ERR_CANCELED') {
        return { success: false, error: 'Login cancelado por el usuario' };
      }
      
      return { success: false, error: 'Error en Apple Sign-In: ' + error.message };
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
      console.error('Error al cerrar sesión social:', error);
    }
  }

  // Método para verificar si el usuario está autenticado con algún proveedor social
  async isSignedIn(): Promise<{ google: boolean; facebook: boolean }> {
    try {
      const [googleSignedIn, facebookToken] = await Promise.all([
        GoogleSignin.isSignedIn(),
        AccessToken.getCurrentAccessToken(),
      ]);

      return {
        google: googleSignedIn,
        facebook: !!facebookToken,
      };
    } catch (error) {
      console.error('Error verificando estado de autenticación social:', error);
      return { google: false, facebook: false };
    }
  }

  // Método para obtener información del usuario autenticado
  async getCurrentUser(): Promise<any> {
    try {
      const [googleUser, facebookToken] = await Promise.all([
        GoogleSignin.getCurrentUser(),
        AccessToken.getCurrentAccessToken(),
      ]);

      return {
        google: googleUser,
        facebook: facebookToken,
      };
    } catch (error) {
      console.error('Error obteniendo usuario actual:', error);
      return null;
    }
  }
}

export default new SocialAuthService();
