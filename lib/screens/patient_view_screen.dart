import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../utils/exercise_validation.dart';

class PatientViewScreen extends StatelessWidget {
  const PatientViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('Patient View'),
        backgroundColor: Colors.grey.shade800,
        actions: [
          Consumer<SessionProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: () {
                  provider.leaveSession();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Leave Session',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SessionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session: ${provider.sessionCode} • ${provider.userName}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Exercise Feed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: provider.isVideoEnabled
                              ? const Center(
                                  child: Text(
                                    'Camera Feed\n(Pose detection will be shown here)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.videocam_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.setIsVideoEnabled(!provider.isVideoEnabled);
                            },
                            icon: Icon(
                              provider.isVideoEnabled ? Icons.videocam_off : Icons.videocam,
                            ),
                            label: Text(
                              provider.isVideoEnabled
                                  ? 'Turn Off Camera'
                                  : 'Turn On Camera',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: provider.isVideoEnabled
                                  ? Colors.red
                                  : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Therapist Feedback',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        provider.feedbackMessages.isEmpty
                            ? const Text(
                                'No feedback yet',
                                style: TextStyle(color: Colors.grey),
                              )
                            : Column(
                                children: provider.feedbackMessages.map((feedback) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade900.withOpacity(0.5),
                                      border: Border(
                                        left: BorderSide(
                                          color: Colors.blue,
                                          width: 4,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          feedback.message,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${feedback.timestamp.hour}:${feedback.timestamp.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Exercise',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ExerciseUtils.exercises[provider.selectedExercise]?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

