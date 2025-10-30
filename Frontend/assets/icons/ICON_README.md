# 📖 Hướng Dẫn Tạo Icon App Hình Sách

## ⚠️ Quan trọng: Cần tạo file `app_icon.png`

Bạn cần tạo một file PNG kích thước **1024x1024 pixels** với hình sách.

## 🎯 Cách 1: Tạo Icon Online (Đơn giản nhất) ⭐

1. Vào một trong các website sau:
   - **https://www.favicon-generator.org/**
   - **https://icon.kitchen/**
   - **https://www.appicon.co/**

2. Tải lên hình sách (PNG/JPG) hoặc tạo icon mới từ text
3. Download file PNG **1024x1024 pixels**
4. Đổi tên file thành `app_icon.png`
5. **Bỏ file vào thư mục này**: `Frontend/assets/icons/app_icon.png`

## 🎯 Cách 2: Dùng Icon Có Sẵn

Nếu bạn đã có file ảnh sách:
1. Mở bằng Paint / Photoshop / hoặc editor bất kỳ
2. Resize về **1024x1024 pixels** (square)
3. Lưu thành `app_icon.png`
4. **Bỏ vào**: `Frontend/assets/icons/app_icon.png`

## 🎯 Cách 3: Tạo Icon Đơn Giản Bằng Paint

1. Mở Paint (Windows) hoặc bất kỳ editor nào
2. Tạo file mới 1024x1024px
3. Vẽ hình sách đơn giản:
   - Vẽ hình chữ nhật (sách đóng)
   - Thêm đường gáy sách ở giữa
   - Thêm vài đường ngang (trang sách)
4. Lưu thành PNG: `app_icon.png`
5. Bỏ vào `Frontend/assets/icons/`

## ✅ Sau khi có file `app_icon.png`

Chạy 2 lệnh sau trong terminal (trong thư mục Frontend):

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

Icon sẽ được tạo tự động cho Android và iOS! 🎉

## 📝 Lưu ý

- File phải đúng tên: `app_icon.png`
- Kích thước: **1024x1024 pixels** (hoặc lớn hơn)
- Format: PNG (không phải JPG)
- Đặt trong: `Frontend/assets/icons/app_icon.png`

## 🎨 Gợi ý màu sắc

- Màu sách: Xanh lá (#2E7D32) hoặc màu bạn thích
- Nền: Trắng hoặc trong suốt
- Đơn giản, dễ nhìn khi icon nhỏ
