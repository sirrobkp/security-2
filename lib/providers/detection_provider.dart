import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../services/yolo_service.dart';
import '../models/alert.dart';

class DetectionProvider extends ChangeNotifier {
  CameraController? _cameraController;
  final YoloService _yoloService = YoloService();
  bool _isInitialized = false;
  bool _isDetecting = false;
  // ignore: unused_field
  StreamSubscription? _detectionStream;

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isDetecting => _isDetecting;

  Future<void> initialize() async {
    try {
      // Initialize YOLO model
      await _yoloService.loadModel();
      
      // Initialize camera
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing detection: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> startDetection(Function(Alert) onThreatDetected) async {
    if (!_isInitialized || _isDetecting) return;

    _isDetecting = true;
    notifyListeners();

    try {
      await _cameraController!.startImageStream((CameraImage image) async {
        if (_isDetecting) {
          final detections = await _processFrame(image);
          
          // Check for threats
          for (final detection in detections) {
            if (_isThreat(detection)) {
              final alert = Alert(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: _getThreatType(detection['label']),
                confidence: (detection['confidence'] * 100).round(),
                timestamp: DateTime.now(),
              );
              
              onThreatDetected(alert);
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error starting detection: $e');
      _isDetecting = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _processFrame(CameraImage image) async {
    try {
      // Convert CameraImage to bytes
      final bytes = _convertYUV420ToBytes(image);
      
      // Run YOLO detection
      final detections = await _yoloService.detect(bytes, image.width, image.height);
      
      return detections;
    } catch (e) {
      debugPrint('Error processing frame: $e');
      return [];
    }
  }

  Uint8List _convertYUV420ToBytes(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    
    final img.Image imgImage = img.Image(width: width, height: height);
    
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;
        
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        
        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    
    return Uint8List.fromList(img.encodePng(imgImage));
  }

  bool _isThreat(Map<String, dynamic> detection) {
    final label = detection['label'].toString().toLowerCase();
    final confidence = detection['confidence'] as double;
    
    // Threat detection logic
    if (confidence < 0.7) return false;
    
    // Weapon detection
    if (label.contains('knife') || label.contains('gun') || label.contains('weapon')) {
      return true;
    }
    
    // Fire detection
    if (label.contains('fire') || label.contains('smoke') || label.contains('flame')) {
      return true;
    }
    
    // Intrusion detection (person in restricted area)
    if (label.contains('person')) {
      return true;
    }
    
    return false;
  }

  String _getThreatType(String label) {
    final lowerLabel = label.toLowerCase();
    
    if (lowerLabel.contains('knife') || lowerLabel.contains('gun') || lowerLabel.contains('weapon')) {
      return 'weapon';
    }
    
    if (lowerLabel.contains('fire') || lowerLabel.contains('smoke') || lowerLabel.contains('flame')) {
      return 'fire';
    }
    
    if (lowerLabel.contains('person')) {
      return 'intrusion';
    }
    
    return 'intrusion';
  }

  void stopDetection() {
    _isDetecting = false;
    _cameraController?.stopImageStream();
    notifyListeners();
  }

  @override
  void dispose() {
    stopDetection();
    _cameraController?.dispose();
    _yoloService.dispose();
    super.dispose();
  }
}
