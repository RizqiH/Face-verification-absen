import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';

/// Camera page specifically for profile photo with face guide overlay
class CameraProfilePage extends StatefulWidget {
  const CameraProfilePage({super.key});

  @override
  State<CameraProfilePage> createState() => _CameraProfilePageState();
}

class _CameraProfilePageState extends State<CameraProfilePage> {
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
              _errorMessage = 'Izin kamera diperlukan untuk mengambil foto profil';
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

      // Find front camera for profile photo
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras![0],
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

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;
    
    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      
      if (!mounted) return;
      
      // Navigate back with photo path
      if (context.mounted) {
        context.pop(photo.path);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Foto Profil'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final isPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
                        if (isPermanentlyDenied) {
                          openAppSettings();
                        } else {
                          _initializeCamera();
                        }
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : !_isInitialized
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Stack(
                  children: [
                    // Camera preview
                    Positioned.fill(
                      child: CameraPreview(_controller!),
                    ),
                    
                    // Face guide overlay
                    _buildFaceGuideOverlay(),
                    
                    // Bottom controls
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomControls(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFaceGuideOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: FaceGuidePainter(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Instructions
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Posisikan wajah Anda di dalam frame',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Face guide rectangle
                      Container(
                        width: 240,
                        height: 320,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Corner indicators
                            Positioned(
                              top: 0,
                              left: 0,
                              child: _buildCornerIndicator(true, true),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: _buildCornerIndicator(true, false),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: _buildCornerIndicator(false, true),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: _buildCornerIndicator(false, false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.light_mode, size: 16, color: Colors.yellow[300]),
                            const SizedBox(width: 8),
                            const Text(
                              'Pastikan pencahayaan cukup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerIndicator(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white,
            width: isTop ? 3 : 0,
          ),
          left: BorderSide(
            color: Colors.white,
            width: isLeft ? 3 : 0,
          ),
          right: BorderSide(
            color: Colors.white,
            width: !isLeft ? 3 : 0,
          ),
          bottom: BorderSide(
            color: Colors.white,
            width: !isTop ? 3 : 0,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.7),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isCapturing ? null : _capturePhoto,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    color: _isCapturing ? Colors.grey : Colors.white.withOpacity(0.3),
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for face guide overlay
class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Calculate guide rectangle position (centered, 240x320)
    final guideWidth = 240.0;
    final guideHeight = 320.0;
    final guideLeft = (size.width - guideWidth) / 2;
    final guideTop = (size.height - guideHeight) / 2 - 20; // Slight offset up

    // Draw semi-transparent overlay
    // Top
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, guideTop),
      paint,
    );
    // Bottom
    canvas.drawRect(
      Rect.fromLTWH(0, guideTop + guideHeight, size.width, size.height - (guideTop + guideHeight)),
      paint,
    );
    // Left
    canvas.drawRect(
      Rect.fromLTWH(0, guideTop, guideLeft, guideHeight),
      paint,
    );
    // Right
    canvas.drawRect(
      Rect.fromLTWH(guideLeft + guideWidth, guideTop, size.width - (guideLeft + guideWidth), guideHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
