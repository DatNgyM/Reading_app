import { Module } from '@nestjs/common';
import { LiturgicalService } from './liturgical.service';
import { LiturgicalController } from './liturgical.controller';

@Module({
  controllers: [LiturgicalController],
  providers: [LiturgicalService],
})
export class LiturgicalModule {}
