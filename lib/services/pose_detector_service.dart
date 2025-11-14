import 'dart:ui';
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
      final inputImage = InputImage.fromBytes(
        bytes: cameraImage.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21, // Android default YUV format
          bytesPerRow: cameraImage.planes[0].bytesPerRow,
        ),
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
