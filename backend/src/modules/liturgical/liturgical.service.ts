import { Injectable } from '@nestjs/common';
import { CreateLiturgicalDto } from './dto/create-liturgical.dto';
import { UpdateLiturgicalDto } from './dto/update-liturgical.dto';

@Injectable()
export class LiturgicalService {
  create(createLiturgicalDto: CreateLiturgicalDto) {
    return 'This action adds a new liturgical';
  }

  findAll() {
    return `This action returns all liturgical`;
  }

  findOne(id: number) {
    return `This action returns a #${id} liturgical`;
  }

  update(id: number, updateLiturgicalDto: UpdateLiturgicalDto) {
    return `This action updates a #${id} liturgical`;
  }

  remove(id: number) {
    return `This action removes a #${id} liturgical`;
  }
}
