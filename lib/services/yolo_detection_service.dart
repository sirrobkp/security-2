import 'dart:async';
import 'dart:typed_data';
// import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/alert.dart';

class YoloDetectionService {
  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _isDetecting = false;
  StreamSubscription? _frameSubscription;

  // Detection callbacks
  Function(Alert)? onThreatDetected;
  Function(Uint8List)? onFrameProcessed;

  bool get isInitialized => _isInitialized;
  bool get isDetecting => _isDetecting;

  Future<void> initialize() async {
    try {
      print('🧠 Loading YOLO model...');
      
      // Load YOLOv5 or YOLOv8 model
      _interpreter = await Interpreter.fromAsset('assets/models/yolov5s-fp16.tflite');
      
      // Allocate tensors
      _interpreter!.allocateTensors();
      
      _isInitialized = true;
      print('✅ YOLO model loaded successfully!');
      
      // Print model info
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      print('📊 Input shape: $inputShape');
      print('📊 Output shape: $outputShape');
      
    } catch (e) {
      print('❌ Failed to load YOLO model: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> startDetection(Stream<Uint8List> frameStream) async {
    if (!_isInitialized || _isDetecting) {
      print('⚠️ Cannot start detection - initialized: $_isInitialized, detecting: $_isDetecting');
      return;
    }

    print('🎯 Starting real-time detection...');
    _isDetecting = true;

    _frameSubscription = frameStream.listen((frameBytes) async {
      try {
        await _processFrame(frameBytes);
      } catch (e) {
        print('Error processing frame: $e');
      }
    });
  }

  Future<void> _processFrame(Uint8List frameBytes) async {
    if (!_isDetecting) return;

    try {
      // Decode image
      img.Image? image = img.decodeImage(frameBytes);
      if (image == null) return;

      // Resize to 640x640 (YOLO input size)
      img.Image resizedImage = img.copyResize(image, width: 640, height: 640);

      // Prepare input tensor
      var input = _imageToInputTensor(resizedImage);

      // Prepare output tensor
      var output = List.filled(1 * 25200 * 85, 0.0).reshape([1, 25200, 85]);

      // Run inference
      final startTime = DateTime.now();
      _interpreter!.run(input, output);
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;
      
      print('⚡ Inference time: ${inferenceTime}ms');

      // Process detections
      List<Detection> detections = _processOutput(output[0]);

      // Check for threats
      for (var detection in detections) {
        if (_isThreatDetection(detection)) {
          print('🚨 THREAT DETECTED: ${detection.label} (${detection.confidence.toStringAsFixed(2)})');
          
          final alert = Alert(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: _getThreatType(detection.label),
            confidence: (detection.confidence * 100).round(),
            timestamp: DateTime.now(),
          );

          onThreatDetected?.call(alert);
          
          // Don't spam alerts - wait 5 seconds before next alert
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      onFrameProcessed?.call(frameBytes);

    } catch (e) {
      print('❌ Frame processing error: $e');
    }
  }

  List<List<List<List<double>>>> _imageToInputTensor(img.Image image) {
    var input = List.generate(
      1,
      (_) => List.generate(
        640,
        (_) => List.generate(
          640,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        final pixel = image.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0; // Normalize to [0, 1]
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    return input;
  }

  List<Detection> _processOutput(List<List<double>> output) {
    List<Detection> detections = [];
    const double confidenceThreshold = 0.5;

    for (var detection in output) {
      // detection format: [x, y, w, h, objectness, class1, class2, ...]
      double objectness = detection[4];
      
      if (objectness < confidenceThreshold) continue;

      // Get class scores (index 5 onwards)
      List<double> classScores = detection.sublist(5);
      
      // Find max class score and index
      double maxScore = classScores.reduce((a, b) => a > b ? a : b);
      int classIndex = classScores.indexOf(maxScore);
      
      double confidence = objectness * maxScore;
      
      if (confidence < confidenceThreshold) continue;

      String label = _getClassLabel(classIndex);

      detections.add(Detection(
        bbox: [detection[0], detection[1], detection[2], detection[3]],
        confidence: confidence,
        classIndex: classIndex,
        label: label,
      ));
    }

    // Apply NMS (Non-Maximum Suppression)
    return _applyNMS(detections);
  }

  List<Detection> _applyNMS(List<Detection> detections) {
    const double iouThreshold = 0.45;
    
    if (detections.isEmpty) return [];

    // Sort by confidence
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    List<Detection> selected = [];

    while (detections.isNotEmpty) {
      var best = detections.removeAt(0);
      selected.add(best);

      detections.removeWhere((detection) {
        double iou = _calculateIOU(best.bbox, detection.bbox);
        return iou > iouThreshold && best.classIndex == detection.classIndex;
      });
    }

    return selected;
  }

  double _calculateIOU(List<double> box1, List<double> box2) {
    // Calculate Intersection over Union
    double x1 = box1[0] - box1[2] / 2;
    double y1 = box1[1] - box1[3] / 2;
    double x2 = box1[0] + box1[2] / 2;
    double y2 = box1[1] + box1[3] / 2;

    double x3 = box2[0] - box2[2] / 2;
    double y3 = box2[1] - box2[3] / 2;
    double x4 = box2[0] + box2[2] / 2;
    double y4 = box2[1] + box2[3] / 2;

    double intersectionX1 = x1 > x3 ? x1 : x3;
    double intersectionY1 = y1 > y3 ? y1 : y3;
    double intersectionX2 = x2 < x4 ? x2 : x4;
    double intersectionY2 = y2 < y4 ? y2 : y4;

    double intersectionArea = (intersectionX2 - intersectionX1).clamp(0.0, double.infinity) *
        (intersectionY2 - intersectionY1).clamp(0.0, double.infinity);

    double box1Area = (x2 - x1) * (y2 - y1);
    double box2Area = (x4 - x3) * (y4 - y3);

    double unionArea = box1Area + box2Area - intersectionArea;

    return intersectionArea / unionArea;
  }

  bool _isThreatDetection(Detection detection) {
    final label = detection.label.toLowerCase();
    final confidence = detection.confidence;

    if (confidence < 0.6) return false; // Higher threshold for threats

    // Check for weapons
    if (label.contains('knife') || 
        label.contains('gun') || 
        label.contains('weapon') ||
        label.contains('scissors')) { // knife class
      return true;
    }

    // Check for fire/smoke
    if (label.contains('fire') || 
        label.contains('smoke') || 
        label.contains('flame')) {
      return true;
    }

    // Check for intrusion (person detected)
    if (label == 'person' && confidence > 0.7) {
      return true;
    }

    return false;
  }

  String _getThreatType(String label) {
    final lowerLabel = label.toLowerCase();

    if (lowerLabel.contains('knife') || 
        lowerLabel.contains('gun') || 
        lowerLabel.contains('weapon') ||
        lowerLabel.contains('scissors')) {
      return 'weapon';
    }

    if (lowerLabel.contains('fire') || 
        lowerLabel.contains('smoke') || 
        lowerLabel.contains('flame')) {
      return 'fire';
    }

    if (lowerLabel == 'person') {
      return 'intrusion';
    }

    return 'intrusion';
  }

  String _getClassLabel(int classIndex) {
    // COCO dataset labels
    const labels = [
      'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat',
      'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird', 'cat',
      'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack',
      'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball',
      'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard', 'tennis racket',
      'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
      'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair',
      'couch', 'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse',
      'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink', 'refrigerator',
      'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush'
    ];

    if (classIndex < 0 || classIndex >= labels.length) {
      return 'unknown';
    }

    return labels[classIndex];
  }

  void stopDetection() {
    print('🛑 Stopping detection...');
    _isDetecting = false;
    _frameSubscription?.cancel();
    _frameSubscription = null;
  }

  void dispose() {
    stopDetection();
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

class Detection {
  final List<double> bbox;
  final double confidence;
  final int classIndex;
  final String label;

  Detection({
    required this.bbox,
    required this.confidence,
    required this.classIndex,
    required this.label,
  });
}
