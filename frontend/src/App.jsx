import React, { useState } from 'react';
import { SessionProvider, useSession } from './context/SessionContext';
import TherapistDashboard from './components/TherapistDashboard';
import PatientView from './components/PatientView';

function AppContent() {
  const { isInSession, userRole } = useSession();
  const [view, setView] = useState('landing');

  if (isInSession) {
    return userRole === 'therapist' ? <TherapistDashboard /> : <PatientView />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {view === 'landing' && <LandingPage onViewChange={setView} />}
      {view === 'create' && <CreateSessionView onBack={() => setView('landing')} />}
      {view === 'join' && <JoinSessionView onBack={() => setView('landing')} />}
    </div>
  );
}

function LandingPage({ onViewChange }) {
  return (
    <div className="flex items-center justify-center min-h-screen p-4">
      <div className="max-w-4xl w-full">
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-800 mb-4">
            Physio Platform
          </h1>
          <p className="text-xl text-gray-600">
            Remote physiotherapy sessions with AI-powered motion tracking
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-white rounded-2xl shadow-xl p-8 hover:shadow-2xl transition-shadow">
            <div className="text-center">
              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-10 h-10 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
              <h2 className="text-2xl font-bold text-gray-800 mb-3">
                I'm a Therapist
              </h2>
              <p className="text-gray-600 mb-6">
                Create a session and monitor multiple patients with real-time pose tracking
              </p>
              <button
                onClick={() => onViewChange('create')}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
              >
                Create Session
              </button>
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-xl p-8 hover:shadow-2xl transition-shadow">
            <div className="text-center">
              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-10 h-10 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h2 className="text-2xl font-bold text-gray-800 mb-3">
                I'm a Patient
              </h2>
              <p className="text-gray-600 mb-6">
                Join a session using your therapist's code and get real-time feedback
              </p>
              <button
                onClick={() => onViewChange('join')}
                className="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
              >
                Join Session
              </button>
            </div>
          </div>
        </div>

        <div className="mt-12 text-center text-gray-600">
          <p className="text-sm">
            Powered by MediaPipe AI • WebRTC Video • Real-time Pose Analysis
          </p>
        </div>
      </div>
    </div>
  );
}

function CreateSessionView({ onBack }) {
  const { createSession } = useSession();
  const [therapistName, setTherapistName] = useState('');
  const [isCreating, setIsCreating] = useState(false);
  const [error, setError] = useState('');

  const handleCreate = async (e) => {
    e.preventDefault();
    if (!therapistName.trim()) {
      setError('Please enter your name');
      return;
    }

    setIsCreating(true);
    setError('');

    const result = await createSession(therapistName);
    if (!result.success) {
      setError(result.error);
      setIsCreating(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen p-4">
      <div className="bg-white rounded-2xl shadow-xl p-8 max-w-md w-full">
        <button
          onClick={onBack}
          className="text-gray-600 hover:text-gray-800 mb-6 flex items-center"
        >
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back
        </button>

        <h2 className="text-3xl font-bold text-gray-800 mb-6">Create Session</h2>

        <form onSubmit={handleCreate}>
          <div className="mb-6">
            <label className="block text-gray-700 font-medium mb-2">
              Your Name
            </label>
            <input
              type="text"
              value={therapistName}
              onChange={(e) => setTherapistName(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your name"
              disabled={isCreating}
            />
          </div>

          {error && (
            <div className="mb-4 p-3 bg-red-100 border border-red-300 text-red-700 rounded-lg">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={isCreating}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors disabled:bg-gray-400"
          >
            {isCreating ? 'Creating...' : 'Create Session'}
          </button>
        </form>

        <div className="mt-6 p-4 bg-blue-50 rounded-lg">
          <p className="text-sm text-gray-700">
            <strong>Note:</strong> After creating, you'll receive a session code to share with your patients (max 3).
          </p>
        </div>
      </div>
    </div>
  );
}

function JoinSessionView({ onBack }) {
  const { joinSession } = useSession();
  const [sessionCode, setSessionCode] = useState('');
  const [patientName, setPatientName] = useState('');
  const [isJoining, setIsJoining] = useState(false);
  const [error, setError] = useState('');

  const handleJoin = async (e) => {
    e.preventDefault();
    if (!sessionCode.trim() || !patientName.trim()) {
      setError('Please enter both session code and your name');
      return;
    }

    setIsJoining(true);
    setError('');

    const result = await joinSession(sessionCode.toUpperCase(), patientName);
    if (!result.success) {
      setError(result.error);
      setIsJoining(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen p-4">
      <div className="bg-white rounded-2xl shadow-xl p-8 max-w-md w-full">
        <button
          onClick={onBack}
          className="text-gray-600 hover:text-gray-800 mb-6 flex items-center"
        >
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back
        </button>

        <h2 className="text-3xl font-bold text-gray-800 mb-6">Join Session</h2>

        <form onSubmit={handleJoin}>
          <div className="mb-4">
            <label className="block text-gray-700 font-medium mb-2">
              Session Code
            </label>
            <input
              type="text"
              value={sessionCode}
              onChange={(e) => setSessionCode(e.target.value.toUpperCase())}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 uppercase"
              placeholder="ABC123"
              maxLength={6}
              disabled={isJoining}
            />
          </div>

          <div className="mb-6">
            <label className="block text-gray-700 font-medium mb-2">
              Your Name
            </label>
            <input
              type="text"
              value={patientName}
              onChange={(e) => setPatientName(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="Enter your name"
              disabled={isJoining}
            />
          </div>

          {error && (
            <div className="mb-4 p-3 bg-red-100 border border-red-300 text-red-700 rounded-lg text-sm">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={isJoining}
            className="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors disabled:bg-gray-400"
          >
            {isJoining ? 'Joining...' : 'Join Session'}
          </button>
        </form>

        <div className="mt-6 p-4 bg-green-50 rounded-lg">
          <p className="text-sm text-gray-700">
            <strong>Tip:</strong> Get the session code from your therapist before joining.
          </p>
        </div>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <SessionProvider>
      <AppContent />
    </SessionProvider>
  );
}