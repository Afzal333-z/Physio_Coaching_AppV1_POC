/**
 * Utility functions for calculating joint angles from pose landmarks
 */

/**
 * Calculate angle between three points
 * @param {Object} pointA - First point {x, y, z}
 * @param {Object} pointB - Middle point (vertex) {x, y, z}
 * @param {Object} pointC - Third point {x, y, z}
 * @returns {number} Angle in degrees
 */
export function calculateAngle(pointA, pointB, pointC) {
  if (!pointA || !pointB || !pointC) return 0;

  // Calculate vectors
  const vectorBA = {
    x: pointA.x - pointB.x,
    y: pointA.y - pointB.y,
    z: pointA.z - pointB.z
  };

  const vectorBC = {
    x: pointC.x - pointB.x,
    y: pointC.y - pointB.y,
    z: pointC.z - pointB.z
  };

  // Calculate dot product
  const dotProduct = 
    vectorBA.x * vectorBC.x + 
    vectorBA.y * vectorBC.y + 
    vectorBA.z * vectorBC.z;

  // Calculate magnitudes
  const magnitudeBA = Math.sqrt(
    vectorBA.x ** 2 + vectorBA.y ** 2 + vectorBA.z ** 2
  );
  const magnitudeBC = Math.sqrt(
    vectorBC.x ** 2 + vectorBC.y ** 2 + vectorBC.z ** 2
  );

  // Calculate angle in radians
  const angleRadians = Math.acos(
    dotProduct / (magnitudeBA * magnitudeBC)
  );

  // Convert to degrees
  const angleDegrees = angleRadians * (180 / Math.PI);

  return angleDegrees;
}

/**
 * Calculate all relevant joint angles from pose landmarks
 * @param {Array} landmarks - MediaPipe pose landmarks
 * @returns {Object} Object containing all calculated angles
 */
export function calculateJointAngles(landmarks) {
  if (!landmarks || landmarks.length < 33) {
    return null;
  }

  // MediaPipe Pose landmark indices
  const POSE_LANDMARKS = {
    LEFT_SHOULDER: 11,
    RIGHT_SHOULDER: 12,
    LEFT_ELBOW: 13,
    RIGHT_ELBOW: 14,
    LEFT_WRIST: 15,
    RIGHT_WRIST: 16,
    LEFT_HIP: 23,
    RIGHT_HIP: 24,
    LEFT_KNEE: 25,
    RIGHT_KNEE: 26,
    LEFT_ANKLE: 27,
    RIGHT_ANKLE: 28,
  };

  const angles = {
    // Left side angles
    leftElbow: calculateAngle(
      landmarks[POSE_LANDMARKS.LEFT_SHOULDER],
      landmarks[POSE_LANDMARKS.LEFT_ELBOW],
      landmarks[POSE_LANDMARKS.LEFT_WRIST]
    ),
    leftShoulder: calculateAngle(
      landmarks[POSE_LANDMARKS.LEFT_ELBOW],
      landmarks[POSE_LANDMARKS.LEFT_SHOULDER],
      landmarks[POSE_LANDMARKS.LEFT_HIP]
    ),
    leftHip: calculateAngle(
      landmarks[POSE_LANDMARKS.LEFT_SHOULDER],
      landmarks[POSE_LANDMARKS.LEFT_HIP],
      landmarks[POSE_LANDMARKS.LEFT_KNEE]
    ),
    leftKnee: calculateAngle(
      landmarks[POSE_LANDMARKS.LEFT_HIP],
      landmarks[POSE_LANDMARKS.LEFT_KNEE],
      landmarks[POSE_LANDMARKS.LEFT_ANKLE]
    ),

    // Right side angles
    rightElbow: calculateAngle(
      landmarks[POSE_LANDMARKS.RIGHT_SHOULDER],
      landmarks[POSE_LANDMARKS.RIGHT_ELBOW],
      landmarks[POSE_LANDMARKS.RIGHT_WRIST]
    ),
    rightShoulder: calculateAngle(
      landmarks[POSE_LANDMARKS.RIGHT_ELBOW],
      landmarks[POSE_LANDMARKS.RIGHT_SHOULDER],
      landmarks[POSE_LANDMARKS.RIGHT_HIP]
    ),
    rightHip: calculateAngle(
      landmarks[POSE_LANDMARKS.RIGHT_SHOULDER],
      landmarks[POSE_LANDMARKS.RIGHT_HIP],
      landmarks[POSE_LANDMARKS.RIGHT_KNEE]
    ),
    rightKnee: calculateAngle(
      landmarks[POSE_LANDMARKS.RIGHT_HIP],
      landmarks[POSE_LANDMARKS.RIGHT_KNEE],
      landmarks[POSE_LANDMARKS.RIGHT_ANKLE]
    ),
  };

  return angles;
}

/**
 * Calculate back straightness (spine alignment)
 * @param {Array} landmarks - MediaPipe pose landmarks
 * @returns {number} Straightness score (0-1, where 1 is perfectly straight)
 */
export function calculateBackStraightness(landmarks) {
  if (!landmarks || landmarks.length < 33) return 0;

  const leftShoulder = landmarks[11];
  const rightShoulder = landmarks[12];
  const leftHip = landmarks[23];
  const rightHip = landmarks[24];

  // Calculate midpoints
  const shoulderMid = {
    x: (leftShoulder.x + rightShoulder.x) / 2,
    y: (leftShoulder.y + rightShoulder.y) / 2,
    z: (leftShoulder.z + rightShoulder.z) / 2,
  };

  const hipMid = {
    x: (leftHip.x + rightHip.x) / 2,
    y: (leftHip.y + rightHip.y) / 2,
    z: (leftHip.z + rightHip.z) / 2,
  };

  // Calculate the vertical distance vs total distance
  const verticalDist = Math.abs(shoulderMid.y - hipMid.y);
  const totalDist = Math.sqrt(
    (shoulderMid.x - hipMid.x) ** 2 +
    (shoulderMid.y - hipMid.y) ** 2 +
    (shoulderMid.z - hipMid.z) ** 2
  );

  // Straightness ratio (closer to 1 means straighter)
  const straightness = verticalDist / totalDist;

  return straightness;
}

/**
 * Format angle for display
 * @param {number} angle - Angle in degrees
 * @returns {string} Formatted angle string
 */
export function formatAngle(angle) {
  return `${Math.round(angle)}°`;
}