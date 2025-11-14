import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Service for detecting poses from camera frames using Google ML Kit
class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base, // Changed to base for better performance
    ),
  );

  bool _isProcessing = false;

  /// Process a camera image and detect poses
  Future<List<Pose>> detectPoses(CameraImage cameraImage) async {
    if (_isProcessing) return [];

    _isProcessing = true;

    try {
      // Combine all YUV planes properly
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      // Get image size
      final Size imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

      // Create metadata with all plane information
      final InputImageMetadata metadata = InputImageMetadata(
        size: imageSize,
        rotation: InputImageRotation.rotation90deg, // Portrait mode rotation
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );

      final poses = await _poseDetector.processImage(inputImage);
      return poses;
    } catch (e) {
      print('❌ Pose detection error: $e');
      return [];
    } finally {
      _isProcessing = false;
    }
  }

  void dispose() {
    _poseDetector.close();
  }
}
