import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = 0.5;
  double _volume = 1.0;
  VoidCallback? _onStateChanged;
  Function(String text, int startOffset, int endOffset, String word)?
      _onProgressChanged;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get currentSpeechRate => _speechRate;
  double get currentVolume => _volume;

  // Set state change callback
  void setOnStateChanged(VoidCallback? callback) {
    _onStateChanged = callback;
  }

  // Set progress callback
  void setOnProgressChanged(
      Function(String text, int startOffset, int endOffset, String word)?
          callback) {
    _onProgressChanged = callback;
  }

  // Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    // Set language to Vietnamese
    await _flutterTts!.setLanguage("vi-VN");

    // Set speech rate (0.0 to 1.0)
    await _flutterTts!.setSpeechRate(0.5);

    // Set volume (0.0 to 1.0)
    await _flutterTts!.setVolume(1.0);

    // Set pitch (0.5 to 2.0)
    await _flutterTts!.setPitch(1.0);

    // Set up event handlers
    _flutterTts!.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _onStateChanged?.call();
    });

    _flutterTts!.setCompletionHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _onStateChanged?.call();
    });

    _flutterTts!.setPauseHandler(() {
      _isPlaying = false;
      _isPaused = true;
      _onStateChanged?.call();
    });

    _flutterTts!.setContinueHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _onStateChanged?.call();
    });

    _flutterTts!.setErrorHandler((msg) {
      _isPlaying = false;
      _isPaused = false;
      debugPrint('TTS Error: $msg');
      _onStateChanged?.call();
    });

    // Set progress handler để track vị trí chính xác
    _flutterTts!.setProgressHandler((text, startOffset, endOffset, word) {
      _onProgressChanged?.call(text, startOffset, endOffset, word);
    });

    _isInitialized = true;
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  // Toggle play/stop
  Future<void> togglePlayStop(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isPlaying) {
      await stop();
    } else {
      await speak(text);
    }
  }

  // Pause speech
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.pause();
    } catch (e) {
      debugPrint('Error pausing: $e');
    }
  }

  // Resume speech from pause
  Future<void> resume() async {
    if (!_isInitialized) return;

    try {
      // FlutterTts không hỗ trợ resume trực tiếp trên mọi platform
      // Cần sử dụng phương pháp khác - tạm thời comment lại
      // await _flutterTts!.speak("");
    } catch (e) {
      debugPrint('Error resuming: $e');
    }
  }

  // Stop speech
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.stop();
      _isPlaying = false;
      _isPaused = false;
    } catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  // Set speech rate
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;

    try {
      _speechRate = rate;
      await _flutterTts!.setSpeechRate(rate);
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      _volume = volume;
      await _flutterTts!.setVolume(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  // Set rate with immediate effect
  void setRate(double rate) {
    _speechRate = rate;
    if (_isInitialized) {
      _flutterTts!.setSpeechRate(rate);
    }
  }

  // Set volume with immediate effect
  void setVol(double volume) {
    _volume = volume;
    if (_isInitialized) {
      _flutterTts!.setVolume(volume);
    }
  }

  // Set pitch
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.setPitch(pitch);
    } catch (e) {
      debugPrint('Error setting pitch: $e');
    }
  }

  // Get available languages
  Future<List<dynamic>> getLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _flutterTts!.getLanguages ?? [];
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  // Get available voices
  Future<List<dynamic>> getVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _flutterTts!.getVoices ?? [];
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return [];
    }
  }

  // Dispose
  Future<void> dispose() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
      _flutterTts = null;
      _isInitialized = false;
      _isPlaying = false;
      _isPaused = false;
    }
  }
}
