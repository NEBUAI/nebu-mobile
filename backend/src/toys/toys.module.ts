import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ToysController } from './controllers/toys.controller';
import { ToysService } from './services/toys.service';
import { Toy } from './entities/toy.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Toy, User]),
  ],
  controllers: [ToysController],
  providers: [ToysService],
  exports: [ToysService], // Exportar el servicio para uso en otros módulos
})
export class ToysModule {}
