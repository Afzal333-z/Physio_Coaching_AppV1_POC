import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' as math;

/// Counts exercise repetitions based on joint angles
class RepCounter {
  int _repCount = 0;
  bool _isInDownPosition = false;
  String _currentExercise = 'SQUAT';

  int get repCount => _repCount;

  void setExercise(String exercise) {
    _currentExercise = exercise;
    reset();
  }

  void reset() {
    _repCount = 0;
    _isInDownPosition = false;
  }

  /// Process pose and count reps
  void processPose(Pose pose) {
    switch (_currentExercise) {
      case 'SQUAT':
        _countSquats(pose);
        break;
      case 'ARM_RAISE':
        _countArmRaises(pose);
        break;
      case 'HAND_STRETCH':
        _countHandStretches(pose);
        break;
      default:
        break;
    }
  }

  void _countSquats(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null) return;

    final double kneeAngle = _calculateAngle(leftHip, leftKnee, leftAnkle);

    // Squat down: knee angle < 120 degrees
    if (kneeAngle < 120 && !_isInDownPosition) {
      _isInDownPosition = true;
    }

    // Squat up: knee angle > 160 degrees
    if (kneeAngle > 160 && _isInDownPosition) {
      _isInDownPosition = false;
      _repCount++;
    }
  }

  void _countArmRaises(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (leftShoulder == null || leftElbow == null || leftWrist == null) return;

    final double elbowAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);

    // Arm raised: elbow angle > 160 degrees (straight arm)
    if (elbowAngle > 160 && !_isInDownPosition) {
      _isInDownPosition = true;
    }

    // Arm down: elbow angle < 100 degrees
    if (elbowAngle < 100 && _isInDownPosition) {
      _isInDownPosition = false;
      _repCount++;
    }
  }

  void _countHandStretches(Pose pose) {
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (rightShoulder == null || rightElbow == null || rightWrist == null) return;

    final double elbowAngle = _calculateAngle(rightShoulder, rightElbow, rightWrist);

    // Hand stretched: elbow angle > 150 degrees
    if (elbowAngle > 150 && !_isInDownPosition) {
      _isInDownPosition = true;
    }

    // Hand relaxed: elbow angle < 120 degrees
    if (elbowAngle < 120 && _isInDownPosition) {
      _isInDownPosition = false;
      _repCount++;
    }
  }

  double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final double radians = math.atan2(c.y - b.y, c.x - b.x) -
        math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * 180.0 / math.pi;

    if (angle > 180.0) {
      angle = 360.0 - angle;
    }

    return angle;
  }

  /// Get accuracy based on form quality (0-100)
  double getAccuracy(Pose pose) {
    // Simple accuracy calculation - can be enhanced
    final landmarks = pose.landmarks.values.where((l) => l.likelihood > 0.5);
    final accuracy = (landmarks.length / pose.landmarks.length) * 100;
    return accuracy.clamp(0, 100);
  }
}
