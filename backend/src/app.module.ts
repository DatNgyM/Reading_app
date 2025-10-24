import { Module } from '@nestjs/common';
import { BibleModule } from './modules/bible/bible.module';
import { LiturgicalModule } from './modules/liturgical/liturgical.module';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  imports: [BibleModule, LiturgicalModule],
  providers: [PrismaService],
})
export class AppModule { }
