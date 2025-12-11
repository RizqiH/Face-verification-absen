import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../domain/repositories/face_recognition_repository.dart';
import '../../../bloc/attendance/attendance_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';

/// Improved Camera Attendance Page with face verification BEFORE confirmation
class CameraAttendanceImproved extends StatefulWidget {
  final String userId;
  final bool isClockIn;
  
  const CameraAttendanceImproved({
    super.key,
    required this.userId,
    required this.isClockIn,
  });

  @override
  State<CameraAttendanceImproved> createState() => _CameraAttendanceImprovedState();
}

class _CameraAttendanceImprovedState extends State<CameraAttendanceImproved> {
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
      var cameraStatus = await Permission.camera.status;
      
      if (cameraStatus.isDenied || cameraStatus.isRestricted) {
        cameraStatus = await Permission.camera.request();
      }
      
      if (!cameraStatus.isGranted) {
        if (mounted) {
          setState(() {
            if (cameraStatus.isPermanentlyDenied) {
              _errorMessage = 'Izin kamera ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.';
            } else {
              _errorMessage = 'Izin kamera diperlukan untuk mengambil foto absensi';
            }
          });
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Tidak ada kamera yang tersedia';
          });
        }
        return;
      }

      // Find front camera for face recognition
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras![0], // Fallback to first camera if no front camera
      );

      _controller = CameraController(
        frontCamera,
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

  /// NEW IMPROVED FLOW: Verify face IMMEDIATELY after capture
  Future<void> _captureAndVerifyPhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() => _isCapturing = true);

    try {
      // 1. CAPTURE PHOTO
      final XFile photo = await _controller!.takePicture();
      AppLogger.info('Photo captured: ${photo.path}');
      
      if (!mounted) return;
      
      // 2. GET LOCATION
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
            location = '${placemark.street ?? ''}, ${placemark.subLocality ?? ''}, ${placemark.locality ?? ''}'
                .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
          } else {
            location = '${position.latitude}, ${position.longitude}';
          }
        }
      } catch (e) {
        AppLogger.warning('Location error: $e');
      }
      
      if (!mounted) return;
      
      // 3. SHOW LOADING - VERIFYING FACE
      _showVerificationDialog(context);
      
      // 4. VERIFY FACE - REAL IMPLEMENTATION
      try {
        AppLogger.info('Starting face verification...');
        
        // Get AuthBloc to get user info for verification
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) {
          throw Exception('User not authenticated');
        }
        
        // Call REAL face verification API
        final faceRecognitionRepo = sl<FaceRecognitionRepository>();
        final isVerified = await faceRecognitionRepo.verifyFace(
          photo.path,
          authState.user.id,
        );
        
        AppLogger.info('Face verification result: $isVerified');
        
        if (!mounted) return;
        
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        if (isVerified) {
          // 5a. VERIFICATION SUCCESS → Navigate to confirmation
          AppLogger.info('Face verification SUCCESS');
          _navigateToConfirmation(photo.path, location, verified: true);
        } else {
          // 5b. VERIFICATION FAILED → Show error
          AppLogger.error('Face verification FAILED');
          _showVerificationFailedDialog(context);
        }
        
      } catch (e) {
        if (!mounted) return;
        
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        // Check if error is about profile not found
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('profile not found') || 
            errorMessage.contains('user profile not found') ||
            errorMessage.contains('404')) {
          _showProfileNotFoundDialog(context);
        } else {
          // Show generic error
        _showVerificationErrorDialog(context, e.toString());
        }
      }
      
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Memverifikasi Wajah...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mohon tunggu sebentar',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVerificationFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 64,
        ),
        title: const Text(
          'Wajah Tidak Cocok',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Wajah yang terdeteksi tidak cocok dengan foto profil Anda. Pastikan:\n\n• Pencahayaan cukup\n• Wajah menghadap kamera\n• Tidak ada yang menutupi wajah',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _isCapturing = false);
            },
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showProfileNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.account_circle_outlined,
          color: Colors.orange,
          size: 64,
        ),
        title: const Text('Profil Belum Lengkap'),
        content: const Text(
          'Anda belum mengupload foto profil untuk verifikasi wajah.\n\n'
          'Silakan upload foto profil Anda terlebih dahulu di menu Profil → Edit Profil → Tap icon kamera.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Navigate back to home
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: const Text('Ke Profil'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _isCapturing = false);
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showVerificationErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 64,
        ),
        title: const Text('Verifikasi Gagal'),
        content: Text(
          'Terjadi kesalahan saat verifikasi wajah:\n\n$error',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _isCapturing = false);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _navigateToConfirmation(String photoPath, String location, {required bool verified}) {
    context.navigateToAttendanceConfirmation(
      photoPath: photoPath,
      location: location,
      userId: widget.userId,
      isClockIn: widget.isClockIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          widget.isClockIn ? 'Clock In' : 'Clock Out',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _errorMessage != null
          ? _buildErrorState()
          : _isInitialized && _controller != null && _controller!.value.isInitialized
              ? _buildCameraView()
              : _buildLoadingState(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            FutureBuilder<PermissionStatus>(
              future: Permission.camera.status,
              builder: (context, snapshot) {
                final isPermanentlyDenied = snapshot.data?.isPermanentlyDenied ?? false;
                
                return Column(
                  children: [
                    if (isPermanentlyDenied)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await openAppSettings();
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Buka Pengaturan'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isInitialized = false;
                          });
                          _initializeCamera();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
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
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        SizedBox.expand(
          child: CameraPreview(_controller!),
        ),
        // Face detection guide overlay
        Center(
          child: Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(150),
            ),
          ),
        ),
        // Instructions
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.face, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  'Posisikan wajah Anda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Pastikan wajah Anda terlihat jelas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // Capture button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isCapturing ? null : _captureAndVerifyPhoto,
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
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Menginisialisasi kamera...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

