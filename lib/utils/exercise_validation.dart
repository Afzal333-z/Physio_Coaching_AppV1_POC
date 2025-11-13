class Exercise {
  final String name;
  final String description;
  final Map<String, double> targetAngles;

  const Exercise({
    required this.name,
    required this.description,
    required this.targetAngles,
  });
}

class ExerciseValidation {
  final double accuracy;
  final Map<String, String> jointStatus;
  final List<String> errors;

  const ExerciseValidation({
    required this.accuracy,
    required this.jointStatus,
    required this.errors,
  });
}

class ExerciseUtils {
  static const Map<String, Exercise> exercises = {
    'SQUAT': const Exercise(
      name: 'Squat',
      description: 'Lower body exercise',
      targetAngles: const {
        'leftKnee': 90.0,
        'rightKnee': 90.0,
      },
    ),
    'LUNGE': const Exercise(
      name: 'Lunge',
      description: 'Single leg exercise',
      targetAngles: const {
        'leftKnee': 90.0,
        'rightKnee': 90.0,
      },
    ),
    'PLANK': const Exercise(
      name: 'Plank',
      description: 'Core strength exercise',
      targetAngles: const {
        'leftShoulder': 180.0,
        'rightShoulder': 180.0,
      },
    ),
    'HAND_STRETCH': const Exercise(
      name: 'Hand Stretch',
      description: 'Stretch your fingers and wrist.',
      targetAngles: const {
        'leftWrist': 90.0,
        'rightWrist': 90.0,
      },
    ),
  };

  static ExerciseValidation validateExercise(
    Map<String, double> angles,
    Map<String, double> landmarks,
    String exerciseType,
  ) {
    final exercise = exercises[exerciseType] ?? exercises['SQUAT']!;
    final jointStatus = <String, String>{};
    final errors = <String>[];
    double totalAccuracy = 0.0;
    int checkedJoints = 0;

    exercise.targetAngles.forEach((joint, targetAngle) {
      final currentAngle = angles[joint] ?? 0.0;
      final difference = (currentAngle - targetAngle).abs();
      final accuracy = (1 - (difference / 180.0)).clamp(0.0, 1.0) * 100;
      
      totalAccuracy += accuracy;
      checkedJoints++;

      if (accuracy >= 90) {
        jointStatus[joint] = 'correct';
      } else if (accuracy >= 70) {
        jointStatus[joint] = 'warning';
        errors.add('$joint angle needs adjustment');
      } else {
        jointStatus[joint] = 'error';
        errors.add('$joint angle is incorrect');
      }
    });

    final avgAccuracy = checkedJoints > 0 ? totalAccuracy / checkedJoints : 0.0;

    return ExerciseValidation(
      accuracy: avgAccuracy,
      jointStatus: jointStatus,
      errors: errors,
    );
  }

  static Map<String, double> calculateJointAngles(Map<String, double> landmarks) {
    // Simplified angle calculation
    // In a real implementation, you would use MediaPipe landmarks
    return {
      'leftKnee': 90.0,
      'rightKnee': 90.0,
      'leftElbow': 90.0,
      'rightElbow': 90.0,
      'leftShoulder': 180.0,
      'rightShoulder': 180.0,
      // Added mock wrist angles for hand stretch
      'leftWrist': 90.0,
      'rightWrist': 90.0,
    };
  }
}
