import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';

class CameraAttendancePageRefactored extends StatefulWidget {
  final String userId;
  final bool isClockIn;
  
  const CameraAttendancePageRefactored({
    super.key,
    required this.userId,
    required this.isClockIn,
  });

  @override
  State<CameraAttendancePageRefactored> createState() => _CameraAttendancePageRefactoredState();
}

class _CameraAttendancePageRefactoredState extends State<CameraAttendancePageRefactored> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Check current permission status
      var cameraStatus = await Permission.camera.status;
      
      // If permission is denied or restricted, request it
      if (cameraStatus.isDenied || cameraStatus.isRestricted) {
        // Request permission - this should show the system dialog
        cameraStatus = await Permission.camera.request();
      }
      
      // If still not granted, show error
      if (!cameraStatus.isGranted) {
        if (mounted) {
          setState(() {
            if (cameraStatus.isPermanentlyDenied) {
              _errorMessage = 'Izin kamera ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.';
            } else if (cameraStatus.isDenied) {
              _errorMessage = 'Izin kamera ditolak. Silakan klik "Coba Lagi" untuk memberikan izin.';
            } else {
              _errorMessage = 'Izin kamera diperlukan untuk mengambil foto absensi';
            }
          });
        }
        return;
      }

      // Permission granted, proceed with camera initialization
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Tidak ada kamera yang tersedia';
          });
        }
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal menginisialisasi kamera: $e';
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();
      
      // Request location permission and get location
      String location = 'Lokasi tidak tersedia';
      try {
        final locationStatus = await Permission.location.request();
        if (locationStatus.isGranted) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          );
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            location = '${placemark.street ?? ''}, ${placemark.subLocality ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}'.replaceAll(RegExp(r'^,\s*|,\s*$'), '');
          } else {
            location = '${position.latitude}, ${position.longitude}';
          }
        }
      } catch (e) {
        // Location error, continue with default location
        print('Location error: $e');
      }
      
      if (mounted) {
        context.navigateToAttendanceConfirmation(
          photoPath: photo.path,
          location: location,
          userId: widget.userId,
          isClockIn: widget.isClockIn,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Catat Kehadiran',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Show different buttons based on permission status
                    FutureBuilder<PermissionStatus>(
                      future: Permission.camera.status,
                      builder: (context, snapshot) {
                        final isPermanentlyDenied = snapshot.data?.isPermanentlyDenied ?? false;
                        
                        return Column(
                          children: [
                            if (isPermanentlyDenied)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final opened = await openAppSettings();
                                  if (!opened && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Silakan buka pengaturan aplikasi secara manual'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.settings),
                                label: const Text('Buka Pengaturan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () async {
                                  // Reset and try again - force request permission
                                  setState(() {
                                    _errorMessage = null;
                                    _isInitialized = false;
                                  });
                                  // Force request permission again
                                  await Permission.camera.request();
                                  _initializeCamera();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Kembali',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : _isInitialized && _controller != null && _controller!.value.isInitialized
              ? Stack(
                  children: [
                    SizedBox.expand(
                      child: CameraPreview(_controller!),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _isCapturing ? null : _capturePhoto,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 3,
                              ),
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 35,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Menginisialisasi kamera...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
    );
  }
}

