/**
 * Session Context for managing application state
 * Uses React Context API (no Redux)
 */

import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

const SessionContext = createContext();

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';
const WS_URL = import.meta.env.VITE_WS_URL || 'ws://localhost:8000';

export function SessionProvider({ children }) {
  // Session state
  const [sessionCode, setSessionCode] = useState('');
  const [userId, setUserId] = useState('');
  const [userRole, setUserRole] = useState(''); // 'therapist' or 'patient'
  const [userName, setUserName] = useState('');
  const [isInSession, setIsInSession] = useState(false);
  
  // Participants state
  const [participants, setParticipants] = useState([]);
  const [patientStats, setPatientStats] = useState({});
  
  // Exercise state
  const [selectedExercise, setSelectedExercise] = useState('SQUAT');
  
  // Video/Audio state
  const [isVideoEnabled, setIsVideoEnabled] = useState(true);
  const [isAudioEnabled, setIsAudioEnabled] = useState(true);
  
  // Feedback state
  const [feedbackMessages, setFeedbackMessages] = useState([]);
  
  // WebSocket state
  const [ws, setWs] = useState(null);
  const [isConnected, setIsConnected] = useState(false);

  /**
   * Create a new therapy session
   */
  const createSession = async (therapistName) => {
    try {
      const response = await axios.post(`${API_URL}/api/sessions/create`, {
        therapist_name: therapistName
      });

      const { session_code, therapist_id } = response.data;
      
      setSessionCode(session_code);
      setUserId(therapist_id);
      setUserRole('therapist');
      setUserName(therapistName);
      setIsInSession(true);

      // Connect to WebSocket
      connectWebSocket(session_code, therapist_id);

      return { success: true, sessionCode: session_code };
    } catch (error) {
      console.error('Error creating session:', error);
      return { success: false, error: error.message };
    }
  };

  /**
   * Join an existing session as a patient
   */
  const joinSession = async (code, patientName) => {
    try {
      const response = await axios.post(`${API_URL}/api/sessions/join`, {
        session_code: code,
        patient_name: patientName
      });

      const { session_code, patient_id } = response.data;
      
      setSessionCode(session_code);
      setUserId(patient_id);
      setUserRole('patient');
      setUserName(patientName);
      setIsInSession(true);

      // Connect to WebSocket
      connectWebSocket(session_code, patient_id);

      return { success: true };
    } catch (error) {
      console.error('Error joining session:', error);
      return { success: false, error: error.response?.data?.detail || error.message };
    }
  };

  /**
   * Connect to WebSocket for real-time communication
   */
  const connectWebSocket = (code, user_id) => {
    const websocket = new WebSocket(`${WS_URL}/ws/${code}/${user_id}`);

    websocket.onopen = () => {
      console.log('WebSocket connected');
      setIsConnected(true);
    };

    websocket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      handleWebSocketMessage(data);
    };

    websocket.onclose = () => {
      console.log('WebSocket disconnected');
      setIsConnected(false);
    };

    websocket.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    setWs(websocket);
  };

  /**
   * Handle incoming WebSocket messages
   */
  const handleWebSocketMessage = (data) => {
    const { type } = data;

    switch (type) {
      case 'user_joined':
        console.log('User joined:', data.user_id);
        // Refresh participants list
        break;

      case 'user_left':
        console.log('User left:', data.user_id);
        setParticipants(prev => prev.filter(p => p.id !== data.user_id));
        break;

      case 'feedback':
        // Patient receives feedback from therapist
        addFeedbackMessage(data.message);
        break;

      case 'pose_update':
        // Therapist receives pose updates from patients
        if (userRole === 'therapist') {
          updatePatientPoseData(data.user_id, data.pose_data);
        }
        break;

      case 'accuracy_update':
        // Therapist receives accuracy updates
        if (userRole === 'therapist') {
          updatePatientAccuracy(data.user_id, data.accuracy);
        }
        break;

      case 'session_ended':
        handleSessionEnd(data.report);
        break;

      case 'webrtc_signal':
        // Handle WebRTC signaling (will be processed by WebRTC service)
        window.dispatchEvent(new CustomEvent('webrtc_signal', { detail: data }));
        break;

      default:
        console.log('Unknown message type:', type);
    }
  };

  /**
   * Send WebSocket message
   */
  const sendMessage = (data) => {
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(data));
    }
  };

  /**
   * Send feedback to a patient
   */
  const sendFeedback = (patientId, message) => {
    sendMessage({
      type: 'feedback',
      target_patient: patientId,
      message
    });
  };

  /**
   * Send pose update to therapist
   */
  const sendPoseUpdate = (poseData) => {
    sendMessage({
      type: 'pose_update',
      pose_data: poseData
    });
  };

  /**
   * Send accuracy update to therapist
   */
  const sendAccuracyUpdate = (accuracy) => {
    sendMessage({
      type: 'accuracy_update',
      accuracy
    });

    // Also submit to backend for storage
    submitPoseData({ accuracy });
  };

  /**
   * Submit pose data to backend
   */
  const submitPoseData = async (poseData) => {
    try {
      await axios.post(`${API_URL}/api/pose-data`, {
        session_code: sessionCode,
        user_id: userId,
        pose_data: poseData,
        timestamp: Date.now()
      });
    } catch (error) {
      console.error('Error submitting pose data:', error);
    }
  };

  /**
   * Update patient pose data (therapist side)
   */
  const updatePatientPoseData = (patientId, poseData) => {
    setPatientStats(prev => ({
      ...prev,
      [patientId]: {
        ...prev[patientId],
        lastPoseData: poseData,
        lastUpdate: Date.now()
      }
    }));
  };

  /**
   * Update patient accuracy (therapist side)
   */
  const updatePatientAccuracy = (patientId, accuracy) => {
    setPatientStats(prev => ({
      ...prev,
      [patientId]: {
        ...prev[patientId],
        accuracy,
        accuracyHistory: [...(prev[patientId]?.accuracyHistory || []), accuracy]
      }
    }));
  };

  /**
   * Add feedback message
   */
  const addFeedbackMessage = (message) => {
    const feedback = {
      id: Date.now(),
      message,
      timestamp: new Date().toISOString()
    };
    setFeedbackMessages(prev => [...prev, feedback]);

    // Auto-remove after 5 seconds
    setTimeout(() => {
      setFeedbackMessages(prev => prev.filter(f => f.id !== feedback.id));
    }, 5000);
  };

  /**
   * End session
   */
  const endSession = async () => {
    try {
      const response = await axios.post(`${API_URL}/api/sessions/${sessionCode}/end`);
      handleSessionEnd(response.data);
    } catch (error) {
      console.error('Error ending session:', error);
    }
  };

  /**
   * Handle session end
   */
  const handleSessionEnd = (report) => {
    console.log('Session ended. Report:', report);
    
    // Download report as JSON
    downloadReport(report);
    
    // Cleanup
    if (ws) {
      ws.close();
    }
    
    setIsInSession(false);
  };

  /**
   * Download session report
   */
  const downloadReport = (report) => {
    const dataStr = JSON.stringify(report, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = `session-report-${sessionCode}-${Date.now()}.json`;
    link.click();
    
    URL.revokeObjectURL(url);
  };

  /**
   * Leave session
   */
  const leaveSession = () => {
    if (ws) {
      ws.close();
    }
    setIsInSession(false);
    setSessionCode('');
    setUserId('');
    setUserRole('');
    setParticipants([]);
    setPatientStats({});
    setFeedbackMessages([]);
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (ws) {
        ws.close();
      }
    };
  }, [ws]);

  const value = {
    // Session state
    sessionCode,
    userId,
    userRole,
    userName,
    isInSession,
    isConnected,
    
    // Participants
    participants,
    patientStats,
    
    // Exercise
    selectedExercise,
    setSelectedExercise,
    
    // Media controls
    isVideoEnabled,
    setIsVideoEnabled,
    isAudioEnabled,
    setIsAudioEnabled,
    
    // Feedback
    feedbackMessages,
    
    // Actions
    createSession,
    joinSession,
    endSession,
    leaveSession,
    sendFeedback,
    sendPoseUpdate,
    sendAccuracyUpdate,
    sendMessage,
  };

  return (
    <SessionContext.Provider value={value}>
      {children}
    </SessionContext.Provider>
  );
}

export function useSession() {
  const context = useContext(SessionContext);
  if (!context) {
    throw new Error('useSession must be used within a SessionProvider');
  }
  return context;
}