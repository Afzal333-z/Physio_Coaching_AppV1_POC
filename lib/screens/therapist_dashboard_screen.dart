import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../utils/exercise_validation.dart';

class TherapistDashboardScreen extends StatelessWidget {
  const TherapistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('Therapist Dashboard'),
        backgroundColor: Colors.grey.shade800,
        actions: [
          Consumer<SessionProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('End Session'),
                      content: const Text(
                        'Are you sure you want to end this session? A report will be generated.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('End Session'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await provider.endSession();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  }
                },
                child: const Text(
                  'End Session',
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
                  'Welcome, ${provider.userName}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade900,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Share this code with your patients:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.sessionCode,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
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
                          'Selected Exercise',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ExerciseUtils.exercises.entries.map((entry) {
                            final isSelected = provider.selectedExercise == entry.key;
                            return FilterChip(
                              label: Text(entry.value.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  provider.setSelectedExercise(entry.key);
                                }
                              },
                              selectedColor: Colors.blue,
                              checkmarkColor: Colors.white,
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
                        Text(
                          'Active Patients (${provider.patientStats.length}/3)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        provider.patientStats.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Waiting for patients to join...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: provider.patientStats.values.map((stats) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: Colors.grey.shade700,
                                    child: ListTile(
                                      title: Text(
                                        'Patient ${stats.patientId.split('_')[1]}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: stats.accuracy != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${stats.accuracy!.toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getAccuracyColor(
                                                      stats.accuracy!,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                LinearProgressIndicator(
                                                  value: stats.accuracy! / 100,
                                                  backgroundColor: Colors.grey,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                    _getAccuracyColor(
                                                      stats.accuracy!,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Text(
                                              'No data yet',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          _showFeedbackDialog(context, stats.patientId);
                                        },
                                        child: const Text('Send Feedback'),
                                      ),
                                    ),
                                  );
                                }).toList(),
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

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 70) return Colors.yellow;
    return Colors.red;
  }

  void _showFeedbackDialog(BuildContext context, String patientId) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Feedback to Patient ${patientId.split('_')[1]}'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'Type your feedback message...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (feedbackController.text.trim().isNotEmpty) {
                Provider.of<SessionProvider>(context, listen: false)
                    .sendFeedback(patientId, feedbackController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback sent!')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

