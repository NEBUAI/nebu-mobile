import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { IoTService } from './iot.service';
import { IoTController } from './iot.controller';
import { DeviceTokenController } from './device-token.controller';
import { IoTDevice } from './entities/iot-device.entity';
import { LiveKitModule } from '../livekit/livekit.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([IoTDevice]),
    LiveKitModule,
    JwtModule.register({}), // JwtModule global ya está configurado en app.module.ts
  ],
  providers: [IoTService],
  controllers: [IoTController, DeviceTokenController],
  exports: [IoTService],
})
export class IoTModule {}
