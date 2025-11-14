import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple camera test screen for debugging
/// This will show you exactly what's happening with the camera
class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  List<CameraDescription>? cameras;
  CameraController? controller;
  String status = 'Starting...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _testCamera();
  }

  Future<void> _testCamera() async {
    setState(() {
      status = '1️⃣ Checking camera permission...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 1: Check permission
    final permissionStatus = await Permission.camera.status;
    setState(() {
      status = 'Permission status: $permissionStatus';
    });
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!permissionStatus.isGranted) {
      setState(() {
        status = '2️⃣ Requesting camera permission...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      final result = await Permission.camera.request();
      setState(() {
        status = 'Permission result: $result';
      });
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!result.isGranted) {
        setState(() {
          status = '❌ FAILED: Permission denied!\n\nPlease grant camera permission.';
          isLoading = false;
        });
        return;
      }
    }

    // Step 2: Get cameras
    setState(() {
      status = '3️⃣ Looking for cameras...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      cameras = await availableCameras();
      setState(() {
        status = '✅ Found ${cameras!.length} camera(s):\n\n';
        for (var i = 0; i < cameras!.length; i++) {
          status += 'Camera $i: ${cameras![i].name}\n';
          status += '  - Lens: ${cameras![i].lensDirection}\n';
          status += '  - Sensor: ${cameras![i].sensorOrientation}°\n\n';
        }
      });
      await Future.delayed(const Duration(milliseconds: 2000));

      if (cameras!.isEmpty) {
        setState(() {
          status = '❌ FAILED: No cameras found!\n\n'
              'This means:\n'
              '• Emulator camera not configured\n'
              '• AVD settings: Front camera = Emulated\n'
              '• Need to set it to webcam0';
          isLoading = false;
        });
        return;
      }

      // Step 3: Initialize camera
      final cameraToUse = cameras!.length > 1 ? cameras![1] : cameras![0];
      setState(() {
        status = '4️⃣ Initializing camera: ${cameraToUse.name}...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      controller = CameraController(
        cameraToUse,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      setState(() {
        status = '✅ SUCCESS!\n\n'
            'Camera initialized successfully!\n'
            'You should see your laptop camera below.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        status = '❌ ERROR:\n\n$e\n\n'
            'This usually means:\n'
            '• Camera in use by another app\n'
            '• Emulator camera not working\n'
            '• Permission issue';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Diagnostic Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status text
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CAMERA DIAGNOSTIC',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Camera preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: controller != null && controller!.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CameraPreview(controller!),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLoading
                                  ? Icons.hourglass_empty
                                  : Icons.videocam_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isLoading
                                  ? 'Waiting for camera...'
                                  : 'No camera preview',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Retry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    controller?.dispose();
                    controller = null;
                  });
                  _testCamera();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
