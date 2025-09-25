import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ENV_CONFIG } from '@/config/env';

interface LoginCredentials {
  email: string;
  password: string;
}

interface RegisterCredentials {
  email: string;
  password: string;
  firstName?: string;
  lastName?: string;
}

interface AuthResponse {
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    avatar?: string;
    role: string;
  };
  accessToken: string;
  refreshToken: string;
}

interface SocialAuthResponse {
  user: {
    id: string;
    email: string;
    name: string;
    avatar?: string;
    provider: 'google' | 'facebook' | 'apple';
  };
  accessToken: string;
  refreshToken: string;
}

class AuthService {
  private baseURL: string;

  constructor() {
    this.baseURL = ENV_CONFIG.API_BASE_URL;
  }

  // Email/Password Authentication
  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    try {
      const response = await axios.post(`${this.baseURL}/auth/login`, credentials);
      
      // Store tokens
      await this.storeTokens(response.data.accessToken, response.data.refreshToken);
      
      return response.data;
    } catch (error) {
      console.error('Login error:', error);
      throw new Error('Login failed. Please check your credentials.');
    }
  }

  async register(credentials: RegisterCredentials): Promise<AuthResponse> {
    try {
      const response = await axios.post(`${this.baseURL}/auth/register`, credentials);
      
      // Store tokens
      await this.storeTokens(response.data.accessToken, response.data.refreshToken);
      
      return response.data;
    } catch (error) {
      console.error('Registration error:', error);
      throw new Error('Registration failed. Please try again.');
    }
  }

  // Social Authentication
  async googleLogin(googleToken: string): Promise<SocialAuthResponse> {
    try {
      const response = await axios.post(`${this.baseURL}/auth/google`, {
        token: googleToken,
      });
      
      await this.storeTokens(response.data.accessToken, response.data.refreshToken);
      
      return response.data;
    } catch (error) {
      console.error('Google login error:', error);
      throw new Error('Google login failed. Please try again.');
    }
  }

  async facebookLogin(facebookToken: string): Promise<SocialAuthResponse> {
    try {
      const response = await axios.post(`${this.baseURL}/auth/facebook`, {
        token: facebookToken,
      });
      
      await this.storeTokens(response.data.accessToken, response.data.refreshToken);
      
      return response.data;
    } catch (error) {
      console.error('Facebook login error:', error);
      throw new Error('Facebook login failed. Please try again.');
    }
  }

  async appleLogin(appleToken: string): Promise<SocialAuthResponse> {
    try {
      const response = await axios.post(`${this.baseURL}/auth/apple`, {
        token: appleToken,
      });
      
      await this.storeTokens(response.data.accessToken, response.data.refreshToken);
      
      return response.data;
    } catch (error) {
      console.error('Apple login error:', error);
      throw new Error('Apple login failed. Please try again.');
    }
  }

  // Token Management
  async storeTokens(accessToken: string, refreshToken: string): Promise<void> {
    try {
      await AsyncStorage.multiSet([
        ['accessToken', accessToken],
        ['refreshToken', refreshToken],
      ]);
    } catch (error) {
      console.error('Error storing tokens:', error);
    }
  }

  async getAccessToken(): Promise<string | null> {
    try {
      return await AsyncStorage.getItem('accessToken');
    } catch (error) {
      console.error('Error getting access token:', error);
      return null;
    }
  }

  async getRefreshToken(): Promise<string | null> {
    try {
      return await AsyncStorage.getItem('refreshToken');
    } catch (error) {
      console.error('Error getting refresh token:', error);
      return null;
    }
  }

  async refreshAccessToken(): Promise<string | null> {
    try {
      const refreshToken = await this.getRefreshToken();
      if (!refreshToken) {
        throw new Error('No refresh token available');
      }

      const response = await axios.post(`${this.baseURL}/auth/refresh`, {
        refreshToken,
      });

      const newAccessToken = response.data.accessToken;
      await AsyncStorage.setItem('accessToken', newAccessToken);

      return newAccessToken;
    } catch (error) {
      console.error('Token refresh error:', error);
      await this.logout();
      return null;
    }
  }

  async logout(): Promise<void> {
    try {
      await AsyncStorage.multiRemove(['accessToken', 'refreshToken', 'user']);
    } catch (error) {
      console.error('Logout error:', error);
    }
  }

  async isAuthenticated(): Promise<boolean> {
    try {
      const accessToken = await this.getAccessToken();
      return !!accessToken;
    } catch (error) {
      console.error('Authentication check error:', error);
      return false;
    }
  }

  // Password Reset
  async requestPasswordReset(email: string): Promise<void> {
    try {
      await axios.post(`${this.baseURL}/auth/forgot-password`, { email });
    } catch (error) {
      console.error('Password reset request error:', error);
      throw new Error('Failed to send password reset email.');
    }
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    try {
      await axios.post(`${this.baseURL}/auth/reset-password`, {
        token,
        password: newPassword,
      });
    } catch (error) {
      console.error('Password reset error:', error);
      throw new Error('Failed to reset password.');
    }
  }

  // Email Verification
  async verifyEmail(token: string): Promise<void> {
    try {
      await axios.post(`${this.baseURL}/auth/verify-email`, { token });
    } catch (error) {
      console.error('Email verification error:', error);
      throw new Error('Failed to verify email.');
    }
  }

  async resendVerificationEmail(email: string): Promise<void> {
    try {
      await axios.post(`${this.baseURL}/auth/resend-verification`, { email });
    } catch (error) {
      console.error('Resend verification error:', error);
      throw new Error('Failed to resend verification email.');
    }
  }
}

export default new AuthService();
