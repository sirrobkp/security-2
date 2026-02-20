import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class YoloService {
  Interpreter? _interpreter;
  List<String>? _labels;
  
  static const int INPUT_SIZE = 640;
  static const double CONFIDENCE_THRESHOLD = 0.5;
  static const double IOU_THRESHOLD = 0.45;

  Future<void> loadModel() async {
    try {
      // Load YOLOv5 or YOLOv8 model
      _interpreter = await Interpreter.fromAsset('assets/models/yolov5s.tflite');
      
      // Load labels
      _labels = [
        'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck',
        'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench',
        'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra',
        'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
        'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove',
        'skateboard', 'surfboard', 'tennis racket', 'bottle', 'wine glass', 'cup',
        'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich', 'orange',
        'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch',
        'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse',
        'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink',
        'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier',
        'toothbrush', 'gun', 'weapon', 'fire', 'smoke', 'flame'
      ];
      
      print('YOLO model loaded successfully');
    } catch (e) {
      print('Error loading YOLO model: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> detect(Uint8List imageBytes, int width, int height) async {
    if (_interpreter == null) {
      throw Exception('Model not loaded');
    }

    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return [];

      // Resize to model input size
      img.Image resizedImage = img.copyResize(
        image,
        width: INPUT_SIZE,
        height: INPUT_SIZE,
      );

      // Prepare input tensor
      var input = _imageToByteListFloat32(resizedImage);

      // Prepare output tensors
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      var output = List.generate(
        outputShape[0],
        (i) => List.generate(
          outputShape[1],
          (j) => List.filled(outputShape[2], 0.0),
        ),
      );

      // Run inference
      _interpreter!.run(input, output);

      // Process detections
      List<Map<String, dynamic>> detections = _processOutput(output[0]);

      // Apply NMS (Non-Maximum Suppression)
      detections = _applyNMS(detections);

      return detections;
    } catch (e) {
      print('Error during detection: $e');
      return [];
    }
  }

  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image) {
    var convertedBytes = List.generate(
      1,
      (i) => List.generate(
        INPUT_SIZE,
        (j) => List.generate(
          INPUT_SIZE,
          (k) => List.filled(3, 0.0),
        ),
      ),
    );

    for (var i = 0; i < INPUT_SIZE; i++) {
      for (var j = 0; j < INPUT_SIZE; j++) {
        var pixel = image.getPixel(j, i);
        convertedBytes[0][i][j][0] = pixel.r / 255.0;
        convertedBytes[0][i][j][1] = pixel.g / 255.0;
        convertedBytes[0][i][j][2] = pixel.b / 255.0;
      }
    }

    return convertedBytes;
  }

  List<Map<String, dynamic>> _processOutput(List<List<double>> output) {
    List<Map<String, dynamic>> detections = [];

    for (var detection in output) {
      double confidence = detection[4];
      
      if (confidence < CONFIDENCE_THRESHOLD) continue;

      // Get class scores
      List<double> classScores = detection.sublist(5);
      int classId = classScores.indexOf(classScores.reduce((a, b) => a > b ? a : b));
      double classConfidence = classScores[classId];

      if (classConfidence < CONFIDENCE_THRESHOLD) continue;

      detections.add({
        'bbox': [detection[0], detection[1], detection[2], detection[3]],
        'confidence': classConfidence,
        'class': classId,
        'label': _labels![classId],
      });
    }

    return detections;
  }

  List<Map<String, dynamic>> _applyNMS(List<Map<String, dynamic>> detections) {
    if (detections.isEmpty) return [];

    // Sort by confidence
    detections.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    List<Map<String, dynamic>> selected = [];

    while (detections.isNotEmpty) {
      var best = detections.removeAt(0);
      selected.add(best);

      detections.removeWhere((detection) {
        double iou = _calculateIOU(best['bbox'], detection['bbox']);
        return iou > IOU_THRESHOLD;
      });
    }

    return selected;
  }

  double _calculateIOU(List<double> box1, List<double> box2) {
    double x1 = box1[0].clamp(0.0, INPUT_SIZE.toDouble());
    double y1 = box1[1].clamp(0.0, INPUT_SIZE.toDouble());
    double x2 = (box1[0] + box1[2]).clamp(0.0, INPUT_SIZE.toDouble());
    double y2 = (box1[1] + box1[3]).clamp(0.0, INPUT_SIZE.toDouble());

    double x3 = box2[0].clamp(0.0, INPUT_SIZE.toDouble());
    double y3 = box2[1].clamp(0.0, INPUT_SIZE.toDouble());
    double x4 = (box2[0] + box2[2]).clamp(0.0, INPUT_SIZE.toDouble());
    double y4 = (box2[1] + box2[3]).clamp(0.0, INPUT_SIZE.toDouble());

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

  void dispose() {
    _interpreter?.close();
  }
}
