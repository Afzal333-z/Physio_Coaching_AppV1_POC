class SessionModel {
  final String sessionCode;
  final String userId;
  final String userRole; // 'therapist' or 'patient'
  final String userName;
  final bool isInSession;
  final bool isConnected;

  SessionModel({
    required this.sessionCode,
    required this.userId,
    required this.userRole,
    required this.userName,
    required this.isInSession,
    required this.isConnected,
  });

  SessionModel copyWith({
    String? sessionCode,
    String? userId,
    String? userRole,
    String? userName,
    bool? isInSession,
    bool? isConnected,
  }) {
    return SessionModel(
      sessionCode: sessionCode ?? this.sessionCode,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      userName: userName ?? this.userName,
      isInSession: isInSession ?? this.isInSession,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class PatientStats {
  final String patientId;
  final double? accuracy;
  final List<double> accuracyHistory;
  final DateTime? lastUpdate;
  final Map<String, dynamic>? lastPoseData;

  PatientStats({
    required this.patientId,
    this.accuracy,
    required this.accuracyHistory,
    this.lastUpdate,
    this.lastPoseData,
  });

  PatientStats copyWith({
    String? patientId,
    double? accuracy,
    List<double>? accuracyHistory,
    DateTime? lastUpdate,
    Map<String, dynamic>? lastPoseData,
  }) {
    return PatientStats(
      patientId: patientId ?? this.patientId,
      accuracy: accuracy ?? this.accuracy,
      accuracyHistory: accuracyHistory ?? this.accuracyHistory,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      lastPoseData: lastPoseData ?? this.lastPoseData,
    );
  }
}

class FeedbackMessage {
  final String id;
  final String message;
  final DateTime timestamp;

  FeedbackMessage({
    required this.id,
    required this.message,
    required this.timestamp,
  });
}

