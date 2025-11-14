import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Paints pose landmarks and skeleton on a canvas
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final Paint dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.green;

    for (final pose in poses) {
      // Draw all landmarks (joints)
      pose.landmarks.forEach((_, landmark) {
        final point = _translatePoint(
          landmark.x,
          landmark.y,
          size,
        );
        canvas.drawCircle(point, 8, dotPaint);
      });

      // Draw connections (skeleton)
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.leftShoulder],
        pose.landmarks[PoseLandmarkType.rightShoulder],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.leftShoulder],
        pose.landmarks[PoseLandmarkType.leftElbow],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.leftElbow],
        pose.landmarks[PoseLandmarkType.leftWrist],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.rightShoulder],
        pose.landmarks[PoseLandmarkType.rightElbow],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.rightElbow],
        pose.landmarks[PoseLandmarkType.rightWrist],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.leftShoulder],
        pose.landmarks[PoseLandmarkType.leftHip],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.rightShoulder],
        pose.landmarks[PoseLandmarkType.rightHip],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.leftHip],
        pose.landmarks[PoseLandmarkType.rightHip],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.leftHip],
        pose.landmarks[PoseLandmarkType.leftKnee],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.leftKnee],
        pose.landmarks[PoseLandmarkType.leftAnkle],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.rightHip],
        pose.landmarks[PoseLandmarkType.rightKnee],
        size,
      );
      _drawLine(
        canvas,
        paint,
        pose.landmarks[PoseLandmarkType.rightKnee],
        pose.landmarks[PoseLandmarkType.rightAnkle],
        size,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    Paint paint,
    PoseLandmark? start,
    PoseLandmark? end,
    Size size,
  ) {
    if (start == null || end == null) return;

    final p1 = _translatePoint(start.x, start.y, size);
    final p2 = _translatePoint(end.x, end.y, size);

    canvas.drawLine(p1, p2, paint);
  }

  Offset _translatePoint(double x, double y, Size size) {
    // Scale the coordinates from image size to canvas size
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    return Offset(x * scaleX, y * scaleY);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}

/// Calculate angle between three points (for joint angles)
double calculateAngle(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) {
  if (a == null || b == null || c == null) return 0.0;

  final double radians = math.atan2(c.y - b.y, c.x - b.x) -
      math.atan2(a.y - b.y, a.x - b.x);
  double angle = radians.abs() * 180.0 / math.pi;

  if (angle > 180.0) {
    angle = 360.0 - angle;
  }

  return angle;
}
