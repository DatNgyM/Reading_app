import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tts_service.dart';
import '../utils/app_theme.dart';

class TTSSettingsDialog extends StatefulWidget {
  const TTSSettingsDialog({super.key});

  @override
  State<TTSSettingsDialog> createState() => _TTSSettingsDialogState();
}

class _TTSSettingsDialogState extends State<TTSSettingsDialog> {
  final TTSService _ttsService = TTSService();
  late double _speechRate;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _speechRate = _ttsService.currentSpeechRate;
    _volume = _ttsService.currentVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Cài đặt giọng đọc',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Speech Rate
          Row(
            children: [
              const Icon(Icons.speed, color: AppTheme.primaryLight),
              const SizedBox(width: 12),
              const Text('Tốc độ đọc'),
              const Spacer(),
              Text('${(_speechRate * 100).round()}%'),
            ],
          ),
          Slider(
            value: _speechRate,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            activeColor: AppTheme.primaryLight,
            onChanged: (value) {
              setState(() {
                _speechRate = value;
              });
              _ttsService.setRate(value);
            },
          ),
          const SizedBox(height: 16),

          // Volume
          Row(
            children: [
              const Icon(Icons.volume_up, color: AppTheme.primaryLight),
              const SizedBox(width: 12),
              const Text('Âm lượng'),
              const Spacer(),
              Text('${(_volume * 100).round()}%'),
            ],
          ),
          Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: AppTheme.primaryLight,
            onChanged: (value) {
              setState(() {
                _volume = value;
              });
              _ttsService.setVol(value);
            },
          ),
          const SizedBox(height: 20),

          // Test button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _ttsService.speak(
                    'Đây là giọng đọc thử nghiệm với tốc độ và âm lượng hiện tại.');
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Thử giọng đọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đóng'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
