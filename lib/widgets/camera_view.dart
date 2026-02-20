import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraView extends StatelessWidget {
  final bool isConnected;
  final CameraController? cameraController;

  const CameraView({
    super.key,
    required this.isConnected,
    this.cameraController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return _buildDisconnectedView();
    }

    if (cameraController == null || !cameraController!.value.isInitialized) {
      return _buildLoadingView();
    }

    return _buildCameraView();
  }

  Widget _buildDisconnectedView() {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1f2937).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.videocam_off,
                size: 48,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Camera Connected',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your RTSP camera in settings',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              'Connecting to stream...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(cameraController!),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            
            // Live Indicator
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Controls
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlButton(Icons.videocam),
                  _buildControlButton(Icons.fullscreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
