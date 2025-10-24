import { Test, TestingModule } from '@nestjs/testing';
import { LiturgicalService } from './liturgical.service';

describe('LiturgicalService', () => {
  let service: LiturgicalService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [LiturgicalService],
    }).compile();

    service = module.get<LiturgicalService>(LiturgicalService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
