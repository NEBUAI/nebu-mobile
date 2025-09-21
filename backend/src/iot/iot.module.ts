import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IoTService } from './iot.service';
import { IoTController } from './iot.controller';
import { IoTDevice } from './entities/iot-device.entity';
import { LiveKitModule } from '../livekit/livekit.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([IoTDevice]),
    LiveKitModule,
  ],
  providers: [IoTService],
  controllers: [IoTController],
  exports: [IoTService],
})
export class IoTModule {}
