import { PartialType } from '@nestjs/mapped-types';
import { CreateLiturgicalDto } from './create-liturgical.dto';

export class UpdateLiturgicalDto extends PartialType(CreateLiturgicalDto) {}
