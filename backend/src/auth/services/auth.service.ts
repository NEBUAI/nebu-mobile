import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User, UserStatus } from '../../users/entities/user.entity';
import { RegisterDto } from '../dto/register.dto';
import { LoginDto } from '../dto/login.dto';
import { AuthResponseDto, AuthUserDto } from '../dto/auth-response.dto';
import { EmailService } from './email.service';
import { OAuthProviderData } from '../../common/types/common.types';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
    private emailService: EmailService,
    private configService: ConfigService
  ) {}

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const { email, password, firstName, lastName, username, preferredLanguage } = registerDto;

    // Check if user already exists
    const existingUser = await this.userRepository.findOne({
      where: [{ email }, ...(username ? [{ username }] : [])],
    });

    if (existingUser) {
      if (existingUser.email === email) {
        throw new ConflictException('Ya existe un usuario con este email');
      }
      if (existingUser.username === username) {
        throw new ConflictException('Ya existe un usuario con este nombre de usuario');
      }
    }

    // Hash password
    const saltRounds = this.configService.get<number>('auth.bcryptRounds');
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Generate email verification token
    const emailVerificationToken = this.generateVerificationToken();

    // Generate username if not provided
    const generatedUsername = username || this.generateUsername(email, firstName, lastName);

    // Create user
    const user = this.userRepository.create({
      email,
      password: hashedPassword,
      firstName,
      lastName,
      username: generatedUsername,
      preferredLanguage: preferredLanguage || 'es',
      emailVerificationToken,
      status: this.isEmailVerificationRequired() ? UserStatus.PENDING : UserStatus.ACTIVE,
      emailVerified: !this.isEmailVerificationRequired(), // Solo verificar automáticamente en desarrollo
    });

    const savedUser = await this.userRepository.save(user);

    // Send verification email only if required
    if (this.isEmailVerificationRequired()) {
      await this.emailService.sendVerificationEmail(savedUser.email, emailVerificationToken);
    }

    // Generate tokens
    const tokens = await this.generateTokens(savedUser);

    return {
      ...tokens,
      user: this.mapToAuthUser(savedUser),
    };
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const { email, password } = loginDto;

    // Find user by email
    const user = await this.userRepository.findOne({
      where: { email },
    });

    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Check password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Check if account is active
    if (user.status === UserStatus.SUSPENDED) {
      throw new UnauthorizedException('Cuenta suspendida. Contacta al soporte.');
    }

    if (user.status === UserStatus.DELETED) {
      throw new UnauthorizedException('Cuenta eliminada');
    }

    // Update last login
    user.lastLoginAt = new Date();
    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      ...tokens,
      user: this.mapToAuthUser(user),
    };
  }

  async verifyEmail(token: string): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({
      where: { emailVerificationToken: token },
    });

    if (!user) {
      throw new BadRequestException('Token de verificación inválido o expirado');
    }

    // Update user status
    user.emailVerified = true;
    user.emailVerificationToken = null;
    user.status = UserStatus.ACTIVE;

    await this.userRepository.save(user);

    return { message: 'Email verificado exitosamente' };
  }

  async resendVerificationEmail(email: string): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({
      where: { email },
    });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    if (user.emailVerified) {
      throw new BadRequestException('El email ya está verificado');
    }

    // Generate new verification token
    const emailVerificationToken = this.generateVerificationToken();
    user.emailVerificationToken = emailVerificationToken;

    await this.userRepository.save(user);
    await this.emailService.sendVerificationEmail(user.email, emailVerificationToken);

    return { message: 'Email de verificación enviado' };
  }

  async requestPasswordReset(email: string): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({
      where: { email },
    });

    if (!user) {
      // Don't reveal if user exists or not
      return {
        message: 'Si el email existe, recibirás instrucciones para restablecer tu contraseña',
      };
    }

    // Generate password reset token
    const resetToken = this.generateVerificationToken();
    const resetExpires = new Date();
    resetExpires.setHours(resetExpires.getHours() + 1); // 1 hour expiry

    user.passwordResetToken = resetToken;
    user.passwordResetExpires = resetExpires;

    await this.userRepository.save(user);
    await this.emailService.sendPasswordResetEmail(user.email, resetToken);

    return {
      message: 'Si el email existe, recibirás instrucciones para restablecer tu contraseña',
    };
  }

  async resetPassword(token: string, newPassword: string): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({
      where: {
        passwordResetToken: token,
      },
    });

    if (!user || !user.passwordResetExpires || user.passwordResetExpires < new Date()) {
      throw new BadRequestException('Token de restablecimiento inválido o expirado');
    }

    // Hash new password
    const saltRounds = this.configService.get<number>('auth.bcryptRounds');
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update user
    user.password = hashedPassword;
    user.passwordResetToken = null;
    user.passwordResetExpires = null;

    await this.userRepository.save(user);

    return { message: 'Contraseña restablecida exitosamente' };
  }

  async refreshToken(refreshToken: string): Promise<AuthResponseDto> {
    try {
      // Use enhanced token validation service
      const tokenValidationService = new (
        await import('./token-validation.service')
      ).TokenValidationService(this.jwtService, this.userRepository, this.configService);

      const validationResult = await tokenValidationService.validateRefreshToken(refreshToken);

      if (!validationResult.isValid) {
        if (validationResult.isExpired) {
          throw new UnauthorizedException('Token de actualización expirado');
        }
        throw new UnauthorizedException(
          validationResult.error || 'Token de actualización inválido'
        );
      }

      if (!validationResult.user) {
        throw new UnauthorizedException('Usuario no encontrado');
      }

      const tokens = await this.generateTokens(validationResult.user);

      return {
        ...tokens,
        user: this.mapToAuthUser(validationResult.user),
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Error procesando token de actualización');
    }
  }

  async validateUser(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user || user.status !== UserStatus.ACTIVE) {
      throw new UnauthorizedException('Usuario no válido');
    }

    return user;
  }

  private async generateTokens(user: User): Promise<{
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
  }> {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get<string>('auth.jwtExpiresIn'),
    });

    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get<string>('auth.refreshTokenExpiresIn'),
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: 24 * 60 * 60, // 24 hours in seconds
    };
  }

  private generateVerificationToken(): string {
    return (
      Math.random().toString(36).substring(2, 15) +
      Math.random().toString(36).substring(2, 15) +
      Date.now().toString(36)
    );
  }

  private mapToAuthUser(user: User): AuthUserDto {
    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
      avatar: user.avatar,
      role: user.role,
      status: user.status,
      emailVerified: user.emailVerified,
      preferredLanguage: user.preferredLanguage,
      createdAt: user.createdAt,
      fullName: user.fullName,
    };
  }

  async handleOAuthUser(oauthData: OAuthProviderData): Promise<User> {
    const { provider, providerId, email, name, avatar } = oauthData;

    // Buscar usuario existente por email o por proveedor OAuth
    let user = await this.userRepository.findOne({
      where: [{ email }, { oauthProvider: provider, oauthId: providerId }],
    });

    if (user) {
      // Actualizar información OAuth si no existe
      if (!user.oauthProvider || !user.oauthId) {
        user.oauthProvider = provider;
        user.oauthId = providerId;
        user.emailVerified = true; // OAuth providers ya verifican el email

        if (avatar && !user.avatar) {
          user.avatar = avatar;
        }

        user = await this.userRepository.save(user);
      }

      // Actualizar último login
      user.lastLoginAt = new Date();
      await this.userRepository.save(user);

      return user;
    }

    // Crear nuevo usuario con OAuth
    const [firstName, ...lastNameParts] = name.split(' ');
    const lastName = lastNameParts.join(' ') || '';

    const newUser = this.userRepository.create({
      email,
      firstName,
      lastName,
      username: email.split('@')[0] + '_' + Date.now(), // Username único basado en email
      oauthProvider: provider,
      oauthId: providerId,
      avatar,
      emailVerified: true, // OAuth providers ya verifican el email
      status: UserStatus.ACTIVE,
      lastLoginAt: new Date(),
    });

    return await this.userRepository.save(newUser);
  }

  private generateUsername(email: string, firstName: string, lastName: string): string {
    // Generate username from email prefix + first letter of names
    const emailPrefix = email.split('@')[0];
    const firstInitial = firstName.charAt(0).toLowerCase();
    const lastInitial = lastName.charAt(0).toLowerCase();
    const timestamp = Date.now().toString().slice(-4); // Last 4 digits of timestamp

    return `${emailPrefix}_${firstInitial}${lastInitial}${timestamp}`;
  }

  private isEmailVerificationRequired(): boolean {
    // Check environment
    const nodeEnv = this.configService.get<string>('NODE_ENV');

    // Disable email verification in development, enable in production
    return nodeEnv === 'production';
  }
}
