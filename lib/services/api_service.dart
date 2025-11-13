import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  static Future<Map<String, dynamic>> createSession(String therapistName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'therapist_name': therapistName}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to create session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> joinSession(String sessionCode, String patientName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_code': sessionCode,
          'patient_name': patientName,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? 'Failed to join session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<void> submitPoseData({
    required String sessionCode,
    required String userId,
    required Map<String, dynamic> poseData,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/pose-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_code': sessionCode,
          'user_id': userId,
          'pose_data': poseData,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (e) {
      print('Error submitting pose data: $e');
    }
  }

  static Future<Map<String, dynamic>> endSession(String sessionCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/$sessionCode/end'),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to end session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

