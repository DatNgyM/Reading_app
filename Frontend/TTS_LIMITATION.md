# Giới Hạn của FlutterTTS

## Vấn đề
FlutterTTS không hỗ trợ tính năng **pause/resume từ vị trí đã dừng**.

## Cách Hoạt Động Hiện Tại

### ✅ Trường hợp 1: Đang nghe → Back Home → Quay lại
- TTS tiếp tục phát trong background
- Khi quay lại, audio vẫn phát tiếp từ đoạn đó
- **KHÔNG CẦN** resume → Hoạt động đúng như mong muốn ✅

### ⚠️ Trường hợp 2: Đang nghe → Thoát app hoàn toàn → Mở lại
- TTS bị dừng khi app đóng
- Khi mở lại, hiển thị dialog "Tiếp tục nghe?"
- Nếu chọn "Tiếp tục" → Phát lại từ đầu bài đó
- **VÌ**: TTS không lưu vị trí đang phát, nên phải bắt đầu lại từ đầu

## Tại sao không thể tiếp tục từ vị trí đã dừng?

FlutterTTS không có API:
- `getCurrentPosition()` - Lấy vị trí hiện tại
- `seekTo(position)` - Nhảy đến vị trí cụ thể
- `pause()` và `resume()` - Chỉ pause, không resume từ vị trí cũ

## Giải pháp thay thế (nếu cần)

1. **Sử dụng audio_service** package
2. **Custom TTS engine** với text tracking
3. **Lưu manual** vị trí đang đọc trong mỗi sentence

## Kết luận

Hiện tại, tính năng **Resume** trong app có nghĩa là:
- "Tiếp tục nghe bài đã chọn" 
- **KHÔNG PHẢI** "Tiếp tục từ vị trí đã dừng"

