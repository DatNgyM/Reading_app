import { Test, TestingModule } from '@nestjs/testing';
import { LiturgicalController } from './liturgical.controller';
import { LiturgicalService } from './liturgical.service';

describe('LiturgicalController', () => {
  let controller: LiturgicalController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [LiturgicalController],
      providers: [LiturgicalService],
    }).compile();

    controller = module.get<LiturgicalController>(LiturgicalController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
