/**
 * Therapist Dashboard Component
 * Monitors multiple patients with real-time accuracy tracking
 */

import React, { useState } from 'react';
import { useSession } from '../context/SessionContext';
import { EXERCISES } from '../utils/exerciseValidation';

export default function TherapistDashboard() {
  const { 
    sessionCode, 
    userName,
    patientStats,
    endSession,
    sendFeedback,
    selectedExercise,
    setSelectedExercise
  } = useSession();

  const [selectedPatient, setSelectedPatient] = useState(null);
  const [feedbackText, setFeedbackText] = useState('');
  const [showSessionCode, setShowSessionCode] = useState(true);

  const patients = Object.entries(patientStats);

  const handleSendFeedback = () => {
    if (selectedPatient && feedbackText.trim()) {
      sendFeedback(selectedPatient, feedbackText);
      setFeedbackText('');
      alert('Feedback sent!');
    }
  };

  const handleEndSession = async () => {
    if (window.confirm('Are you sure you want to end this session? A report will be generated.')) {
      await endSession();
    }
  };

  const getAccuracyColor = (accuracy) => {
    if (accuracy >= 90) return 'text-green-400';
    if (accuracy >= 70) return 'text-yellow-400';
    return 'text-red-400';
  };

  const getAccuracyBgColor = (accuracy) => {
    if (accuracy >= 90) return 'bg-green-900 border-green-500';
    if (accuracy >= 70) return 'bg-yellow-900 border-yellow-500';
    return 'bg-red-900 border-red-500';
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <div className="bg-gray-800 p-4 shadow-lg">
        <div className="max-w-7xl mx-auto">
          <div className="flex justify-between items-center mb-4">
            <div>
              <h1 className="text-2xl font-bold">Therapist Dashboard</h1>
              <p className="text-gray-400">Welcome, {userName}</p>
            </div>
            <button
              onClick={handleEndSession}
              className="bg-red-600 hover:bg-red-700 px-6 py-2 rounded-lg font-semibold transition-colors"
            >
              End Session
            </button>
          </div>

          {/* Session Code Banner */}
          {showSessionCode && (
            <div className="bg-blue-900 border-2 border-blue-500 rounded-lg p-4 flex justify-between items-center">
              <div>
                <p className="text-sm text-gray-300 mb-1">Share this code with your patients:</p>
                <p className="text-3xl font-bold font-mono tracking-wider">{sessionCode}</p>
              </div>
              <button
                onClick={() => setShowSessionCode(false)}
                className="text-gray-400 hover:text-white"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          )}
        </div>
      </div>

      <div className="p-6 max-w-7xl mx-auto">
        <div className="grid lg:grid-cols-3 gap-6">
          {/* Patient Monitoring Grid */}
          <div className="lg:col-span-2 space-y-6">
            {/* Exercise Selector */}
            <div className="bg-gray-800 rounded-xl shadow-xl p-6">
              <h2 className="text-xl font-semibold mb-4">Selected Exercise</h2>
              <div className="grid grid-cols-2 gap-4">
                {Object.entries(EXERCISES).map(([key, exercise]) => (
                  <button
                    key={key}
                    onClick={() => setSelectedExercise(key)}
                    className={`p-4 rounded-lg border-2 transition-all ${
                      selectedExercise === key
                        ? 'border-blue-500 bg-blue-900 bg-opacity-50'
                        : 'border-gray-600 hover:border-gray-500'
                    }`}
                  >
                    <div className="text-lg font-bold mb-1">{exercise.name}</div>
                    <div className="text-sm text-gray-400">{exercise.description}</div>
                  </button>
                ))}
              </div>
            </div>

            {/* Patient Cards */}
            <div className="bg-gray-800 rounded-xl shadow-xl p-6">
              <h2 className="text-xl font-semibold mb-4">
                Active Patients ({patients.length}/3)
              </h2>
              
              {patients.length === 0 ? (
                <div className="text-center py-12">
                  <svg className="w-16 h-16 mx-auto mb-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                  <p className="text-gray-400">Waiting for patients to join...</p>
                  <p className="text-sm text-gray-500 mt-2">Share session code: <span className="font-mono font-bold">{sessionCode}</span></p>
                </div>
              ) : (
                <div className="grid md:grid-cols-2 gap-4">
                  {patients.map(([patientId, stats]) => (
                    <div
                      key={patientId}
                      className={`rounded-lg border-2 p-4 cursor-pointer transition-all ${
                        selectedPatient === patientId
                          ? 'border-blue-500 bg-blue-900 bg-opacity-30'
                          : 'border-gray-600 hover:border-gray-500'
                      }`}
                      onClick={() => setSelectedPatient(patientId)}
                    >
                      <div className="flex items-start justify-between mb-3">
                        <div>
                          <h3 className="font-semibold text-lg">Patient {patientId.split('_')[1]}</h3>
                          <p className="text-xs text-gray-400">ID: {patientId}</p>
                        </div>
                        {stats.accuracy !== undefined && (
                          <div className={`text-2xl font-bold ${getAccuracyColor(stats.accuracy)}`}>
                            {stats.accuracy}%
                          </div>
                        )}
                      </div>

                      {/* Accuracy Progress Bar */}
                      {stats.accuracy !== undefined && (
                        <div className="mb-3">
                          <div className="w-full bg-gray-700 rounded-full h-3">
                            <div
                              className={`h-3 rounded-full transition-all ${
                                stats.accuracy >= 90 ? 'bg-green-500' :
                                stats.accuracy >= 70 ? 'bg-yellow-500' :
                                'bg-red-500'
                              }`}
                              style={{ width: `${stats.accuracy}%` }}
                            />
                          </div>
                        </div>
                      )}

                      {/* Stats */}
                      <div className="text-xs text-gray-400 space-y-1">
                        {stats.accuracyHistory && (
                          <div>Readings: {stats.accuracyHistory.length}</div>
                        )}
                        {stats.lastUpdate && (
                          <div>Last update: {new Date(stats.lastUpdate).toLocaleTimeString()}</div>
                        )}
                      </div>

                      {/* Quick Actions */}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedPatient(patientId);
                        }}
                        className="mt-3 w-full bg-blue-600 hover:bg-blue-700 text-sm py-2 rounded transition-colors"
                      >
                        Send Feedback
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Alerts Section */}
            <div className="bg-gray-800 rounded-xl shadow-xl p-6">
              <h2 className="text-xl font-semibold mb-4">Alerts & Notifications</h2>
              <div className="space-y-3">
                {patients.map(([patientId, stats]) => {
                  if (stats.accuracy !== undefined && stats.accuracy < 70) {
                    return (
                      <div
                        key={patientId}
                        className="bg-red-900 bg-opacity-50 border-l-4 border-red-500 rounded p-3"
                      >
                        <div className="flex items-center">
                          <svg className="w-5 h-5 mr-2 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                          </svg>
                          <div>
                            <div className="font-semibold">Patient {patientId.split('_')[1]} - Form Needs Correction</div>
                            <div className="text-sm text-gray-300">Current accuracy: {stats.accuracy}%</div>
                          </div>
                        </div>
                      </div>
                    );
                  }
                  return null;
                })}
                
                {patients.every(([_, stats]) => stats.accuracy === undefined || stats.accuracy >= 70) && (
                  <p className="text-gray-400 text-sm">No alerts. All patients performing well!</p>
                )}
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Feedback Panel */}
            <div className="bg-gray-800 rounded-xl shadow-xl p-6">
              <h3 className="text-xl font-semibold mb-4">Send Feedback</h3>
              
              {selectedPatient ? (
                <div>
                  <div className="mb-3 p-3 bg-blue-900 bg-opacity-30 rounded-lg">
                    <p className="text-sm text-gray-300">Sending to:</p>
                    <p className="font-semibold">Patient {selectedPatient.split('_')[1]}</p>
                  </div>

                  <textarea
                    value={feedbackText}
                    onChange={(e) => setFeedbackText(e.target.value)}
                    placeholder="Type your feedback message..."
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg p-3 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                    rows={4}
                  />

                  <div className="mt-3 space-y-2">
                    <button
                      onClick={handleSendFeedback}
                      disabled={!feedbackText.trim()}
                      className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 disabled:cursor-not-allowed py-2 rounded-lg font-semibold transition-colors"
                    >
                      Send Feedback
                    </button>

                    {/* Quick Feedback Buttons */}
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => setFeedbackText('Great form! Keep it up!')}
                        className="text-xs bg-green-700 hover:bg-green-600 py-2 rounded transition-colors"
                      >
                        👍 Great Form
                      </button>
                      <button
                        onClick={() => setFeedbackText('Check your knee angle')}
                        className="text-xs bg-yellow-700 hover:bg-yellow-600 py-2 rounded transition-colors"
                      >
                        ⚠️ Check Knees
                      </button>
                      <button
                        onClick={() => setFeedbackText('Keep your back straight')}
                        className="text-xs bg-orange-700 hover:bg-orange-600 py-2 rounded transition-colors"
                      >
                        📏 Back Straight
                      </button>
                      <button
                        onClick={() => setFeedbackText('Slow down your movement')}
                        className="text-xs bg-purple-700 hover:bg-purple-600 py-2 rounded transition-colors"
                      >
                        🐢 Slow Down
                      </button>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-center py-8 text-gray-400">
                  <svg className="w-12 h-12 mx-auto mb-3 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
                  </svg>
                  <p className="text-sm">Select a patient to send feedback</p>
                </div>
              )}
            </div>

            {/* Session Info */}
            <div className="bg-gray-800 rounded-xl shadow-xl p-6">
              <h3 className="text-xl font-semibold mb-4">Session Info</h3>
              <div className="space-y-3 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-400">Session Code:</span>
                  <span className="font-mono font-bold">{sessionCode}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Active Patients:</span>
                  <span className="font-semibold">{patients.length}/3</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Exercise:</span>
                  <span className="font-semibold">{EXERCISES[selectedExercise]?.name}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Status:</span>
                  <span className="text-green-400 font-semibold">● Active</span>
                </div>
              </div>
            </div>

            {/* Statistics Summary */}
            {patients.length > 0 && (
              <div className="bg-gray-800 rounded-xl shadow-xl p-6">
                <h3 className="text-xl font-semibold mb-4">Overall Statistics</h3>
                <div className="space-y-4">
                  {patients.map(([patientId, stats]) => {
                    const avgAccuracy = stats.accuracyHistory && stats.accuracyHistory.length > 0
                      ? Math.round(stats.accuracyHistory.reduce((a, b) => a + b, 0) / stats.accuracyHistory.length)
                      : 0;

                    return (
                      <div key={patientId} className="border-t border-gray-700 pt-3">
                        <div className="text-sm font-semibold mb-2">
                          Patient {patientId.split('_')[1]}
                        </div>
                        <div className="text-xs text-gray-400 space-y-1">
                          <div className="flex justify-between">
                            <span>Current:</span>
                            <span className={stats.accuracy ? getAccuracyColor(stats.accuracy) : ''}>
                              {stats.accuracy || 0}%
                            </span>
                          </div>
                          <div className="flex justify-between">
                            <span>Average:</span>
                            <span>{avgAccuracy}%</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Samples:</span>
                            <span>{stats.accuracyHistory?.length || 0}</span>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Instructions */}
            <div className="bg-blue-900 bg-opacity-30 rounded-xl border border-blue-700 p-6">
              <h3 className="text-lg font-semibold mb-3">💡 Tips</h3>
              <ul className="text-sm text-gray-300 space-y-2">
                <li>• Monitor patient accuracy scores in real-time</li>
                <li>• Send corrective feedback when form deviates</li>
                <li>• Use quick feedback buttons for common corrections</li>
                <li>• Session report will be generated when you end the session</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}