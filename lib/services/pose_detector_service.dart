import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Service for detecting poses from camera frames using Google ML Kit
class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  bool _isProcessing = false;

  /// Process a camera image and detect poses
  Future<List<Pose>> detectPoses(CameraImage image, InputImageRotation rotation) async {
    if (_isProcessing) return [];

    _isProcessing = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final InputImageMetadata metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
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
