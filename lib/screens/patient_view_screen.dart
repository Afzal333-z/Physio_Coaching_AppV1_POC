import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../providers/session_provider.dart';
import '../utils/exercise_validation.dart';
import '../services/pose_detector_service.dart';
import '../utils/pose_painter.dart';
import '../utils/rep_counter.dart';

class PatientViewScreen extends StatefulWidget {
  const PatientViewScreen({super.key});

  @override
  State<PatientViewScreen> createState() => _PatientViewScreenState();
}

class _PatientViewScreenState extends State<PatientViewScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  String? _cameraError;

  // Pose detection
  final PoseDetectorService _poseDetector = PoseDetectorService();
  final RepCounter _repCounter = RepCounter();
  List<Pose> _detectedPoses = [];
  bool _isPoseDetectionActive = false;
  double _accuracy = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });

      try {
        // Get available cameras
        _cameras = await availableCameras();

        if (_cameras == null || _cameras!.isEmpty) {
          setState(() {
            _cameraError = 'No cameras found on this device';
          });
          return;
        }

        // Use front camera (index 1) if available, otherwise use first camera
        final camera = _cameras!.length > 1 ? _cameras![1] : _cameras![0];

        // Initialize camera controller
        _cameraController = CameraController(
          camera,
          ResolutionPreset.low, // Changed to low for better performance
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420, // YUV format required for ML Kit
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });

          // Start pose detection
          _startPoseDetection();
        }
      } catch (e) {
        setState(() {
          _cameraError = 'Camera initialization failed: ${e.toString()}';
        });
        print('❌ Camera error: $e');
      }
    } else {
      setState(() {
        _isCameraPermissionGranted = false;
        _cameraError = 'Camera permission denied';
      });
    }
  }

  int _frameCount = 0;

  void _startPoseDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isPoseDetectionActive = true;
    });

    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isPoseDetectionActive) return;

      // Process only every 3rd frame for better performance
      _frameCount++;
      if (_frameCount % 3 != 0) return;

      final poses = await _poseDetector.detectPoses(image);

      if (mounted && poses.isNotEmpty) {
        setState(() {
          _detectedPoses = poses;

          // Process first pose for rep counting
          final pose = poses.first;
          _repCounter.processPose(pose);
          _accuracy = _repCounter.getAccuracy(pose);
        });
      }
    });
  }

  void _stopPoseDetection() {
    setState(() {
      _isPoseDetectionActive = false;
      _detectedPoses = [];
    });

    _cameraController?.stopImageStream();
  }

  @override
  void dispose() {
    _stopPoseDetection();
    _cameraController?.dispose();
    _poseDetector.dispose();
    super.dispose();
  }

  Widget _buildCameraWidget() {
    if (!_isCameraPermissionGranted) {
      return _buildErrorWidget(
        icon: Icons.no_photography,
        title: 'Camera Permission Required',
        message: 'Please grant camera permission to use this feature',
        action: ElevatedButton(
          onPressed: () async {
            await openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      );
    }

    if (_cameraError != null) {
      return _buildErrorWidget(
        icon: Icons.error_outline,
        title: 'Camera Error',
        message: _cameraError!,
        action: ElevatedButton(
          onPressed: _initializeCamera,
          child: const Text('Retry'),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Camera preview with skeleton overlay
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: _cameraController!.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            CameraPreview(_cameraController!),

            // Pose skeleton overlay
            if (_detectedPoses.isNotEmpty)
              CustomPaint(
                painter: PosePainter(
                  poses: _detectedPoses,
                  imageSize: Size(
                    _cameraController!.value.previewSize!.width,
                    _cameraController!.value.previewSize!.height,
                  ),
                  rotation: InputImageRotation.rotation0deg, // Rotation handled in painter
                  isFrontCamera: true, // Mirror for front camera selfie mode
                ),
              ),

            // Accuracy indicator (top-left)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Accuracy: ${_accuracy.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _accuracy > 70 ? Colors.green : Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Rep counter (top-right)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reps: ${_repCounter.repCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

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
                const SizedBox(height: 12),
                // Camera Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCameraInitialized && provider.isVideoEnabled
                        ? Colors.green.shade900.withOpacity(0.3)
                        : Colors.orange.shade900.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isCameraInitialized && provider.isVideoEnabled
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCameraInitialized && provider.isVideoEnabled
                            ? Icons.videocam
                            : Icons.videocam_off,
                        size: 16,
                        color: _isCameraInitialized && provider.isVideoEnabled
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCameraInitialized && provider.isVideoEnabled
                            ? 'Camera Active • ${_cameras?.length ?? 0} camera(s) found'
                            : provider.isVideoEnabled
                                ? 'Camera Initializing...'
                                : 'Camera Off',
                        style: TextStyle(
                          color: _isCameraInitialized && provider.isVideoEnabled
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                              ? _buildCameraWidget()
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
                            onPressed: () async {
                              final newValue = !provider.isVideoEnabled;
                              provider.setIsVideoEnabled(newValue);

                              // Start or stop camera and pose detection based on toggle
                              if (newValue) {
                                if (!_isCameraInitialized) {
                                  await _initializeCamera();
                                } else if (!_isPoseDetectionActive) {
                                  _startPoseDetection();
                                }
                              } else {
                                _stopPoseDetection();
                              }
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

