import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { LiturgicalService } from './liturgical.service';
import { CreateLiturgicalDto } from './dto/create-liturgical.dto';
import { UpdateLiturgicalDto } from './dto/update-liturgical.dto';

@Controller('liturgical')
export class LiturgicalController {
  constructor(private readonly liturgicalService: LiturgicalService) {}

  @Post()
  create(@Body() createLiturgicalDto: CreateLiturgicalDto) {
    return this.liturgicalService.create(createLiturgicalDto);
  }

  @Get()
  findAll() {
    return this.liturgicalService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.liturgicalService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateLiturgicalDto: UpdateLiturgicalDto) {
    return this.liturgicalService.update(+id, updateLiturgicalDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.liturgicalService.remove(+id);
  }
}
