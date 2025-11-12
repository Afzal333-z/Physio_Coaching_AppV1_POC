/**
 * MediaPipe Pose Detection Service
 * Handles pose estimation and skeleton rendering
 */

import { calculateJointAngles } from '../utils/angleCalculations';

let poseInstance = null;
let camera = null;

/**
 * Initialize MediaPipe Pose
 */
export async function initializePose(videoElement, onResults) {
  if (typeof window.Pose === 'undefined') {
    throw new Error('MediaPipe Pose library not loaded');
  }

  poseInstance = new window.Pose({
    locateFile: (file) => {
      return `https://cdn.jsdelivr.net/npm/@mediapipe/pose/${file}`;
    }
  });

  poseInstance.setOptions({
    modelComplexity: 1,
    smoothLandmarks: true,
    enableSegmentation: false,
    smoothSegmentation: false,
    minDetectionConfidence: 0.5,
    minTrackingConfidence: 0.5
  });

  poseInstance.onResults(onResults);

  camera = new window.Camera(videoElement, {
    onFrame: async () => {
      if (poseInstance) {
        await poseInstance.send({ image: videoElement });
      }
    },
    width: 640,
    height: 480
  });

  return { pose: poseInstance, camera };
}

export async function startPoseDetection() {
  if (camera) {
    await camera.start();
  }
}

export function stopPoseDetection() {
  if (camera) {
    camera.stop();
  }
}

export function drawPoseSkeleton(ctx, landmarks, width, height, jointStatus = {}) {
  if (!landmarks || landmarks.length === 0) return;

  ctx.clearRect(0, 0, width, height);

  const connections = [
    [11, 12], [11, 23], [12, 24], [23, 24],
    [11, 13], [13, 15], [12, 14], [14, 16],
    [23, 25], [25, 27], [24, 26], [26, 28]
  ];

  ctx.lineWidth = 3;
  connections.forEach(([startIdx, endIdx]) => {
    const start = landmarks[startIdx];
    const end = landmarks[endIdx];

    if (start && end && start.visibility > 0.5 && end.visibility > 0.5) {
      ctx.strokeStyle = '#00FF00';
      ctx.beginPath();
      ctx.moveTo(start.x * width, start.y * height);
      ctx.lineTo(end.x * width, end.y * height);
      ctx.stroke();
    }
  });

  const jointIndices = {
    leftShoulder: 11,
    rightShoulder: 12,
    leftElbow: 13,
    rightElbow: 14,
    leftWrist: 15,
    rightWrist: 16,
    leftHip: 23,
    rightHip: 24,
    leftKnee: 25,
    rightKnee: 26,
    leftAnkle: 27,
    rightAnkle: 28
  };

  Object.entries(jointIndices).forEach(([jointName, idx]) => {
    const landmark = landmarks[idx];
    if (landmark && landmark.visibility > 0.5) {
      const x = landmark.x * width;
      const y = landmark.y * height;

      let color = '#00FF00';
      if (jointStatus[jointName]) {
        color = jointStatus[jointName].color;
      }

      ctx.fillStyle = color;
      ctx.beginPath();
      ctx.arc(x, y, 8, 0, 2 * Math.PI);
      ctx.fill();

      ctx.strokeStyle = '#FFFFFF';
      ctx.lineWidth = 2;
      ctx.stroke();
    }
  });
}

export function drawAngleAnnotations(ctx, landmarks, angles, width, height) {
  if (!landmarks || !angles) return;

  const annotations = [
    { index: 25, label: `L Knee: ${Math.round(angles.leftKnee)}°` },
    { index: 26, label: `R Knee: ${Math.round(angles.rightKnee)}°` },
    { index: 13, label: `L Elbow: ${Math.round(angles.leftElbow)}°` },
    { index: 14, label: `R Elbow: ${Math.round(angles.rightElbow)}°` },
    { index: 11, label: `L Shoulder: ${Math.round(angles.leftShoulder)}°` },
    { index: 12, label: `R Shoulder: ${Math.round(angles.rightShoulder)}°` }
  ];

  ctx.font = '14px Arial';
  ctx.fillStyle = '#FFFFFF';
  ctx.strokeStyle = '#000000';
  ctx.lineWidth = 3;

  annotations.forEach(({ index, label }) => {
    const landmark = landmarks[index];
    if (landmark && landmark.visibility > 0.5) {
      const x = landmark.x * width + 15;
      const y = landmark.y * height - 10;
      ctx.strokeText(label, x, y);
      ctx.fillText(label, x, y);
    }
  });
}

export function processPoseResults(results) {
  if (!results || !results.poseLandmarks) {
    return null;
  }

  const landmarks = results.poseLandmarks;
  const angles = calculateJointAngles(landmarks);

  return {
    landmarks,
    angles,
    timestamp: Date.now()
  };
}

export function cleanupPose() {
  if (camera) {
    camera.stop();
    camera = null;
  }
  if (poseInstance) {
    poseInstance.close();
    poseInstance = null;
  }
}