/* eslint-disable no-console */
type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LoggerConfig {
  enableDebug: boolean;
  enableInfo: boolean;
  enableWarn: boolean;
  enableError: boolean;
}

class Logger {
  private config: LoggerConfig;

  constructor() {
    this.config = {
      enableDebug: __DEV__,
      enableInfo: true,
      enableWarn: true,
      enableError: true,
    };
  }

  debug(message: string, ...args: unknown[]): void {
    if (this.config.enableDebug) {
      console.log(`[DEBUG] ${message}`, ...args);
    }
  }

  info(message: string, ...args: unknown[]): void {
    if (this.config.enableInfo) {
      console.log(`[INFO] ${message}`, ...args);
    }
  }

  warn(message: string, ...args: unknown[]): void {
    if (this.config.enableWarn) {
      console.warn(`[WARN] ${message}`, ...args);
    }
  }

  error(message: string, error?: unknown, ...args: unknown[]): void {
    if (this.config.enableError) {
      console.error(`[ERROR] ${message}`, error, ...args);
    }
  }

  configure(config: Partial<LoggerConfig>): void {
    this.config = { ...this.config, ...config };
  }
}

export const logger = new Logger();
