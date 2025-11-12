/**
 * Exercise validation and comparison logic
 */

import { calculateBackStraightness } from './angleCalculations';

// Exercise definitions with target angles
export const EXERCISES = {
  SQUAT: {
    name: 'Squat',
    description: 'Proper squat form with knees at 80-110 degrees',
    targets: {
      leftKnee: { min: 80, max: 110, weight: 1.0 },
      rightKnee: { min: 80, max: 110, weight: 1.0 },
      backStraightness: { min: 0.85, max: 1.0, weight: 0.8 }
    }
  },
  LATERAL_RAISE: {
    name: 'Lateral Shoulder Raise',
    description: 'Arms raised to shoulder level (160-180 degrees)',
    targets: {
      leftShoulder: { min: 160, max: 180, weight: 1.0 },
      rightShoulder: { min: 160, max: 180, weight: 1.0 }
    }
  }
};

/**
 * Validate if an angle is within target range
 * @param {number} angle - Current angle
 * @param {Object} target - Target range {min, max}
 * @returns {string} 'correct', 'slight', or 'incorrect'
 */
export function validateAngle(angle, target) {
  if (!angle || !target) return 'incorrect';

  const { min, max } = target;
  const tolerance = (max - min) * 0.15; // 15% tolerance for 'slight' deviation

  if (angle >= min && angle <= max) {
    return 'correct'; // Green
  } else if (
    (angle >= min - tolerance && angle < min) ||
    (angle > max && angle <= max + tolerance)
  ) {
    return 'slight'; // Yellow
  } else {
    return 'incorrect'; // Red
  }
}

/**
 * Get color for joint based on validation status
 * @param {string} status - 'correct', 'slight', or 'incorrect'
 * @returns {string} Color hex code
 */
export function getJointColor(status) {
  const colors = {
    correct: '#22C55E',   // Green
    slight: '#EAB308',    // Yellow
    incorrect: '#EF4444'  // Red
  };
  return colors[status] || colors.incorrect;
}

/**
 * Validate pose against exercise requirements
 * @param {Object} angles - Calculated joint angles
 * @param {Array} landmarks - Pose landmarks
 * @param {string} exerciseType - 'SQUAT' or 'LATERAL_RAISE'
 * @returns {Object} Validation results
 */
export function validateExercise(angles, landmarks, exerciseType) {
  if (!angles || !exerciseType || !EXERCISES[exerciseType]) {
    return {
      isValid: false,
      accuracy: 0,
      jointStatus: {},
      errors: []
    };
  }

  const exercise = EXERCISES[exerciseType];
  const jointStatus = {};
  const errors = [];
  let totalScore = 0;
  let totalWeight = 0;

  // Validate each target angle
  for (const [joint, target] of Object.entries(exercise.targets)) {
    let value;
    let status;

    if (joint === 'backStraightness') {
      value = calculateBackStraightness(landmarks);
      status = validateAngle(value * 100, { 
        min: target.min * 100, 
        max: target.max * 100 
      });
    } else {
      value = angles[joint];
      status = validateAngle(value, target);
    }

    jointStatus[joint] = {
      value,
      status,
      target,
      color: getJointColor(status)
    };

    // Calculate score for this joint
    const jointScore = status === 'correct' ? 1.0 : status === 'slight' ? 0.5 : 0.0;
    totalScore += jointScore * target.weight;
    totalWeight += target.weight;

    // Add errors
    if (status === 'incorrect') {
      errors.push(`${joint}: ${Math.round(value)}° (target: ${target.min}-${target.max}°)`);
    }
  }

  const accuracy = totalWeight > 0 ? (totalScore / totalWeight) * 100 : 0;

  return {
    isValid: accuracy >= 70,
    accuracy: Math.round(accuracy),
    jointStatus,
    errors
  };
}

/**
 * Get feedback message based on validation results
 * @param {Object} validation - Validation results
 * @param {string} exerciseType - Exercise type
 * @returns {string} Feedback message
 */
export function getFeedbackMessage(validation, exerciseType) {
  if (!validation || !exerciseType) return '';

  const { accuracy, errors } = validation;
  const exercise = EXERCISES[exerciseType];

  if (accuracy >= 90) {
    return `Excellent form! ${exercise.name} performed correctly.`;
  } else if (accuracy >= 70) {
    return `Good effort! Minor adjustments needed: ${errors.join(', ')}`;
  } else {
    return `Form needs correction: ${errors.join(', ')}`;
  }
}

/**
 * Get exercise instructions
 * @param {string} exerciseType - Exercise type
 * @returns {string} Instructions
 */
export function getExerciseInstructions(exerciseType) {
  const exercise = EXERCISES[exerciseType];
  return exercise ? exercise.description : '';
}