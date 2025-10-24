import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { BibleService } from './bible.service';
import { CreateBibleDto } from './dto/create-bible.dto';
import { UpdateBibleDto } from './dto/update-bible.dto';

@Controller('bible')
export class BibleController {
  constructor(private readonly bibleService: BibleService) {}

  @Post()
  create(@Body() createBibleDto: CreateBibleDto) {
    return this.bibleService.create(createBibleDto);
  }

  @Get()
  findAll() {
    return this.bibleService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.bibleService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateBibleDto: UpdateBibleDto) {
    return this.bibleService.update(+id, updateBibleDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.bibleService.remove(+id);
  }
}
