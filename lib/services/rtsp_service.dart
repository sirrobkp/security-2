// import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'dart:async';
import 'dart:typed_data';

// import 'package:screenshot/screenshot.dart';

class RtspStreamService {
  VlcPlayerController? _videoPlayerController;
  // final ScreenshotController _screenshotController = ScreenshotController();
  bool _isConnected = false;
  StreamController<Uint8List>? _frameStreamController;

  bool get isConnected => _isConnected;
  VlcPlayerController? get controller => _videoPlayerController;

  Future<bool> connect(String rtspUrl) async {
    try {
      print('🔌 Connecting to RTSP: $rtspUrl');
      
      _videoPlayerController = VlcPlayerController.network(
        rtspUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(1000),
            VlcAdvancedOptions.clockJitter(0)
            // VlcAdvancedOptions.clockSynchro(0),
          ]),
          video: VlcVideoOptions([
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true),
          ]),
        ),
      );

      await _videoPlayerController!.initialize();
      
      // Wait for stream to start playing
      await Future.delayed(const Duration(seconds: 2));
      
      if (_videoPlayerController!.value.isPlaying) {
        _isConnected = true;
        print('✅ RTSP Connected Successfully!');
        _startFrameCapture();
        return true;
      } else {
        print('❌ RTSP Failed to play');
        return false;
      }
    } catch (e) {
      print('❌ RTSP Connection Error: $e');
      _isConnected = false;
      return false;
    }
  }

  void _startFrameCapture() {
    // Capture frames every 500ms for detection
    _frameStreamController = StreamController<Uint8List>.broadcast();
    
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!_isConnected || _videoPlayerController == null) {
        timer.cancel();
        return;
      }

      // try {
      //   // Capture current frame
      //   final frame = await _screenshotController.captureFromWidget(
      //     VlcPlayer(
      //       controller: _videoPlayerController!,
      //       aspectRatio: 16 / 9,
      //       placeholder: const Center(child: CircularProgressIndicator()),
      //     ),
      //   );
        
      //   _frameStreamController?.add(frame);
      // } catch (e) {
      //   print('Frame capture error: $e');
      // }
    });
  }

  Stream<Uint8List>? get frameStream => _frameStreamController?.stream;

  void disconnect() {
    print('🔌 Disconnecting RTSP...');
    _isConnected = false;
    _videoPlayerController?.stop();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _frameStreamController?.close();
    _frameStreamController = null;
  }

  void dispose() {
    disconnect();
  }
}
