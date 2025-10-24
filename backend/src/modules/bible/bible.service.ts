import { Injectable } from '@nestjs/common';
import { CreateBibleDto } from './dto/create-bible.dto';
import { UpdateBibleDto } from './dto/update-bible.dto';

@Injectable()
export class BibleService {
  create(createBibleDto: CreateBibleDto) {
    return 'This action adds a new bible';
  }

  findAll() {
    return `This action returns all bible`;
  }

  findOne(id: number) {
    return `This action returns a #${id} bible`;
  }

  update(id: number, updateBibleDto: UpdateBibleDto) {
    return `This action updates a #${id} bible`;
  }

  remove(id: number) {
    return `This action removes a #${id} bible`;
  }
}
