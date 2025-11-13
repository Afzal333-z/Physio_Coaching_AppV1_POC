import 'package:flutter/foundation.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../utils/exercise_validation.dart';

class SessionProvider extends ChangeNotifier {
  // Session state
  String _sessionCode = '';
  String _userId = '';
  String _userRole = '';
  String _userName = '';
  bool _isInSession = false;
  bool _isConnected = false;

  // Participants state
  Map<String, PatientStats> _patientStats = {};
  
  // Exercise state
  String _selectedExercise = 'SQUAT';
  
  // Video/Audio state
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  
  // Feedback state
  List<FeedbackMessage> _feedbackMessages = [];
  
  // WebSocket service
  final WebSocketService _webSocketService = WebSocketService();

  // Getters
  String get sessionCode => _sessionCode;
  String get userId => _userId;
  String get userRole => _userRole;
  String get userName => _userName;
  bool get isInSession => _isInSession;
  bool get isConnected => _isConnected;
  Map<String, PatientStats> get patientStats => _patientStats;
  String get selectedExercise => _selectedExercise;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isAudioEnabled => _isAudioEnabled;
  List<FeedbackMessage> get feedbackMessages => _feedbackMessages;

  SessionProvider() {
    _setupWebSocketListener();
  }

  void _setupWebSocketListener() {
    _webSocketService.messageStream?.listen((data) {
      final type = data['type'];
      
      switch (type) {
        case 'user_joined':
          print('User joined: ${data['user_id']}');
          break;
          
        case 'user_left':
          final userId = data['user_id'];
          _patientStats.remove(userId);
          notifyListeners();
          break;
          
        case 'feedback':
          addFeedbackMessage(data['message'] as String);
          break;
          
        case 'pose_update':
          if (_userRole == 'therapist') {
            updatePatientPoseData(
              data['user_id'] as String,
              data['pose_data'] as Map<String, dynamic>,
            );
          }
          break;
          
        case 'accuracy_update':
          if (_userRole == 'therapist') {
            updatePatientAccuracy(
              data['user_id'] as String,
              (data['accuracy'] as num).toDouble(),
            );
          }
          break;
          
        case 'session_ended':
          handleSessionEnd(data['report'] as Map<String, dynamic>);
          break;
      }
    });
  }

  Future<Map<String, dynamic>> createSession(String therapistName) async {
    final result = await ApiService.createSession(therapistName);
    
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      _sessionCode = data['session_code'] as String;
      _userId = data['therapist_id'] as String;
      _userRole = 'therapist';
      _userName = therapistName;
      _isInSession = true;
      
      _webSocketService.connect(_sessionCode, _userId);
      _isConnected = true;
      
      notifyListeners();
      return {'success': true, 'sessionCode': _sessionCode};
    } else {
      return {'success': false, 'error': result['error']};
    }
  }

  Future<Map<String, dynamic>> joinSession(String code, String patientName) async {
    final result = await ApiService.joinSession(code.toUpperCase(), patientName);
    
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      _sessionCode = data['session_code'] as String;
      _userId = data['patient_id'] as String;
      _userRole = 'patient';
      _userName = patientName;
      _isInSession = true;
      
      _webSocketService.connect(_sessionCode, _userId);
      _isConnected = true;
      
      notifyListeners();
      return {'success': true};
    } else {
      return {'success': false, 'error': result['error']};
    }
  }

  void sendFeedback(String patientId, String message) {
    _webSocketService.sendMessage({
      'type': 'feedback',
      'target_patient': patientId,
      'message': message,
    });
  }

  void sendAccuracyUpdate(double accuracy) {
    _webSocketService.sendMessage({
      'type': 'accuracy_update',
      'accuracy': accuracy,
    });

    ApiService.submitPoseData(
      sessionCode: _sessionCode,
      userId: _userId,
      poseData: {'accuracy': accuracy},
    );
  }

  void updatePatientPoseData(String patientId, Map<String, dynamic> poseData) {
    final stats = _patientStats[patientId] ?? PatientStats(
      patientId: patientId,
      accuracyHistory: [],
    );
    
    _patientStats[patientId] = stats.copyWith(
      lastPoseData: poseData,
      lastUpdate: DateTime.now(),
    );
    
    notifyListeners();
  }

  void updatePatientAccuracy(String patientId, double accuracy) {
    final stats = _patientStats[patientId] ?? PatientStats(
      patientId: patientId,
      accuracyHistory: [],
    );
    
    final updatedHistory = List<double>.from(stats.accuracyHistory)..add(accuracy);
    
    _patientStats[patientId] = stats.copyWith(
      accuracy: accuracy,
      accuracyHistory: updatedHistory,
    );
    
    notifyListeners();
  }

  void addFeedbackMessage(String message) {
    _feedbackMessages.add(FeedbackMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      timestamp: DateTime.now(),
    ));
    
    notifyListeners();
    
    // Auto-remove after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _feedbackMessages.removeWhere((f) => f.message == message);
      notifyListeners();
    });
  }

  Future<void> endSession() async {
    final result = await ApiService.endSession(_sessionCode);
    if (result['success'] == true) {
      handleSessionEnd(result['data'] as Map<String, dynamic>);
    }
  }

  void handleSessionEnd(Map<String, dynamic> report) {
    print('Session ended. Report: $report');
    leaveSession();
  }

  void leaveSession() {
    _webSocketService.disconnect();
    _sessionCode = '';
    _userId = '';
    _userRole = '';
    _isInSession = false;
    _isConnected = false;
    _patientStats.clear();
    _feedbackMessages.clear();
    notifyListeners();
  }

  void setSelectedExercise(String exercise) {
    _selectedExercise = exercise;
    notifyListeners();
  }

  void setIsVideoEnabled(bool enabled) {
    _isVideoEnabled = enabled;
    notifyListeners();
  }

  void setIsAudioEnabled(bool enabled) {
    _isAudioEnabled = enabled;
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}

