/**
 * Patient View Component
 * Shows video feed with pose overlay and receives therapist feedback
 */

import React, { useRef, useEffect, useState } from 'react';
import { useSession } from '../context/SessionContext';
import { initializePose, startPoseDetection, stopPoseDetection, drawPoseSkeleton, drawAngleAnnotations, processPoseResults } from '../services/poseDetection';
import { validateExercise, EXERCISES } from '../utils/exerciseValidation';
import { requestCameraPermissions, isNativePlatform } from '../utils/mobileUtils';

export default function PatientView() {
  const { 
    sessionCode, 
    userName, 
    leaveSession, 
    feedbackMessages,
    selectedExercise,
    sendAccuracyUpdate,
    isVideoEnabled,
    setIsVideoEnabled
  } = useSession();

  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const [isPoseActive, setIsPoseActive] = useState(false);
  const [currentAccuracy, setCurrentAccuracy] = useState(0);
  const [currentAngles, setCurrentAngles] = useState(null);
  const [validationResult, setValidationResult] = useState(null);

  useEffect(() => {
    if (isVideoEnabled) {
      initializeCamera();
    } else {
      cleanup();
    }

    return () => cleanup();
  }, [isVideoEnabled]);

  const initializeCamera = async () => {
    try {
      // Request camera permissions on mobile
      if (isNativePlatform()) {
        const hasPermission = await requestCameraPermissions();
        if (!hasPermission) {
          alert('Camera permission is required for pose detection. Please enable it in Settings.');
          setIsVideoEnabled(false);
          return;
        }
      }

      // Get camera stream with mobile-optimized settings
      const constraints = {
        video: {
          width: { ideal: 640 },
          height: { ideal: 480 },
          facingMode: 'user' // Front camera for self-view
        },
        audio: false
      };

      const stream = await navigator.mediaDevices.getUserMedia(constraints);

      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.onloadedmetadata = async () => {
          await setupPoseDetection();
        };
      }
    } catch (error) {
      console.error('Error accessing camera:', error);
      alert('Unable to access camera. Please grant camera permissions in Settings.');
      setIsVideoEnabled(false);
    }
  };

  const setupPoseDetection = async () => {
    try {
      const { camera } = await initializePose(videoRef.current, handlePoseResults);
      await startPoseDetection();
      setIsPoseActive(true);
    } catch (error) {
      console.error('Error initializing pose detection:', error);
    }
  };

  const handlePoseResults = (results) => {
    if (!canvasRef.current || !results.poseLandmarks) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    
    // Process pose data
    const poseData = processPoseResults(results);
    if (!poseData) return;

    const { landmarks, angles } = poseData;
    setCurrentAngles(angles);

    // Validate exercise
    const validation = validateExercise(angles, landmarks, selectedExercise);
    setValidationResult(validation);
    setCurrentAccuracy(validation.accuracy);

    // Send accuracy update to therapist every 2 seconds
    if (Date.now() % 2000 < 100) {
      sendAccuracyUpdate(validation.accuracy);
    }

    // Draw skeleton with color-coded joints
    drawPoseSkeleton(
      ctx, 
      landmarks, 
      canvas.width, 
      canvas.height, 
      validation.jointStatus
    );

    // Draw angle annotations
    drawAngleAnnotations(ctx, landmarks, angles, canvas.width, canvas.height);
  };

  const cleanup = () => {
    stopPoseDetection();
    if (videoRef.current && videoRef.current.srcObject) {
      const tracks = videoRef.current.srcObject.getTracks();
      tracks.forEach(track => track.stop());
    }
    setIsPoseActive(false);
  };

  const toggleVideo = () => {
    setIsVideoEnabled(!isVideoEnabled);
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <div className="bg-gray-800 p-4 shadow-lg">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold">Patient View</h1>
            <p className="text-gray-400">Session: {sessionCode} • {userName}</p>
          </div>
          <button
            onClick={leaveSession}
            className="bg-red-600 hover:bg-red-700 px-6 py-2 rounded-lg font-semibold transition-colors"
          >
            Leave Session
          </button>
        </div>
      </div>

      <div className="p-6 max-w-7xl mx-auto">
        <div className="grid lg:grid-cols-3 gap-6">
          {/* Video Feed with Pose Overlay */}
          <div className="lg:col-span-2">
            <div className="bg-gray-800 rounded-xl shadow-xl overflow-hidden">
              <div className="p-4 bg-gray-700 border-b border-gray-600">
                <h2 className="text-xl font-semibold">Your Exercise Feed</h2>
              </div>
              
              <div className="relative aspect-video bg-black">
                <video
                  ref={videoRef}
                  autoPlay
                  playsInline
                  muted
                  className="w-full h-full object-cover"
                  style={{ display: isVideoEnabled ? 'block' : 'none' }}
                />
                <canvas
                  ref={canvasRef}
                  width={640}
                  height={480}
                  className="absolute top-0 left-0 w-full h-full"
                  style={{ display: isVideoEnabled ? 'block' : 'none' }}
                />
                
                {!isVideoEnabled && (
                  <div className="absolute inset-0 flex items-center justify-center bg-gray-800">
                    <div className="text-center">
                      <svg className="w-16 h-16 mx-auto mb-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                      <p className="text-gray-400">Camera Off</p>
                    </div>
                  </div>
                )}

                {/* Accuracy Indicator */}
                {isPoseActive && validationResult && (
                  <div className="absolute top-4 left-4 bg-black bg-opacity-70 rounded-lg p-3">
                    <div className="text-sm text-gray-300 mb-1">Form Accuracy</div>
                    <div className="text-3xl font-bold">{currentAccuracy}%</div>
                    <div className={`text-sm mt-1 ${
                      currentAccuracy >= 90 ? 'text-green-400' :
                      currentAccuracy >= 70 ? 'text-yellow-400' :
                      'text-red-400'
                    }`}>
                      {currentAccuracy >= 90 ? 'Excellent!' :
                       currentAccuracy >= 70 ? 'Good' :
                       'Needs Improvement'}
                    </div>
                  </div>
                )}

                {/* Exercise Info */}
                <div className="absolute top-4 right-4 bg-black bg-opacity-70 rounded-lg p-3">
                  <div className="text-sm text-gray-300">Current Exercise</div>
                  <div className="text-lg font-bold">{EXERCISES[selectedExercise]?.name}</div>
                </div>
              </div>

              {/* Controls */}
              <div className="p-4 bg-gray-700 flex justify-center space-x-4">
                <button
                  onClick={toggleVideo}
                  className={`px-6 py-3 rounded-lg font-semibold transition-colors ${
                    isVideoEnabled 
                      ? 'bg-red-600 hover:bg-red-700' 
                      : 'bg-green-600 hover:bg-green-700'
                  }`}
                >
                  {isVideoEnabled ? 'Turn Off Camera' : 'Turn On Camera'}
                </button>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Feedback Messages */}
            <div className="bg-gray-800 rounded-xl shadow-xl p-6">
              <h3 className="text-xl font-semibold mb-4">Therapist Feedback</h3>
              <div className="space-y-3 max-h-96 overflow-y-auto">
                {feedbackMessages.length === 0 ? (
                  <p className="text-gray-400 text-sm">No feedback yet</p>
                ) : (
                  feedbackMessages.map((feedback) => (
                    <div
                      key={feedback.id}
                      className="bg-blue-900 bg-opacity-50 rounded-lg p-3 border-l-4 border-blue-500"
                    >
                      <p className="text-sm">{feedback.message}</p>
                      <p className="text-xs text-gray-400 mt-1">
                        {new Date(feedback.timestamp).toLocaleTimeString()}
                      </p>
                    </div>
                  ))
                )}
              </div>
            </div>

            {/* Current Angles */}
            {currentAngles && (
              <div className="bg-gray-800 rounded-xl shadow-xl p-6">
                <h3 className="text-xl font-semibold mb-4">Joint Angles</h3>
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span>Left Knee:</span>
                    <span className="font-mono">{Math.round(currentAngles.leftKnee)}°</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Right Knee:</span>
                    <span className="font-mono">{Math.round(currentAngles.rightKnee)}°</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Left Shoulder:</span>
                    <span className="font-mono">{Math.round(currentAngles.leftShoulder)}°</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Right Shoulder:</span>
                    <span className="font-mono">{Math.round(currentAngles.rightShoulder)}°</span>
                  </div>
                </div>
              </div>
            )}

            {/* Legend */}
            <div className="bg-gray-800 rounded-xl shadow-xl p-6">
              <h3 className="text-xl font-semibold mb-4">Color Guide</h3>
              <div className="space-y-3">
                <div className="flex items-center">
                  <div className="w-4 h-4 rounded-full bg-green-500 mr-3"></div>
                  <span className="text-sm">Correct Form</span>
                </div>
                <div className="flex items-center">
                  <div className="w-4 h-4 rounded-full bg-yellow-500 mr-3"></div>
                  <span className="text-sm">Slight Deviation</span>
                </div>
                <div className="flex items-center">
                  <div className="w-4 h-4 rounded-full bg-red-500 mr-3"></div>
                  <span className="text-sm">Incorrect Form</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}