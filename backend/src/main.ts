import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = new DocumentBuilder()
    .setTitle('Liturgy Reader API')
    .setDescription('API đọc bài đọc theo ngày dựa vào lịch phụng vụ & Kinh Thánh')
    .setVersion('1.0')
    .addTag('bible')
    .addTag('liturgical')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(process.env.PORT || 3000);
  console.log(`🚀 Server ready at http://localhost:3000/api/docs`);
}
bootstrap();
