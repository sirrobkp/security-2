import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/alert.dart';
import '../models/phone_number.dart';

class WhatsAppService {
  static Future<bool> sendAlert({
    required Alert alert,
    required List<PhoneNumber> recipients,
    Uint8List? snapshot,
  }) async {
    try {
      print('📱 Sending WhatsApp alerts to ${recipients.length} recipients...');

      // Save snapshot to temporary file
      String? imagePath;
      if (snapshot != null) {
        imagePath = await _saveSnapshot(snapshot, alert);
      }

      bool allSent = true;

      for (var recipient in recipients) {
        final success = await _sendToRecipient(
          recipient: recipient,
          alert: alert,
          imagePath: imagePath,
        );
        
        if (!success) allSent = false;
      }

      return allSent;
    } catch (e) {
      print('❌ WhatsApp send error: $e');
      return false;
    }
  }

  static Future<String?> _saveSnapshot(Uint8List snapshot, Alert alert) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/threat_${alert.type}_$timestamp.jpg';
      
      final file = File(filePath);
      await file.writeAsBytes(snapshot);
      
      print('💾 Snapshot saved: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Failed to save snapshot: $e');
      return null;
    }
  }

  static Future<bool> _sendToRecipient({
    required PhoneNumber recipient,
    required Alert alert,
    String? imagePath,
  }) async {
    try {
      // Format phone number (remove spaces, dashes, etc.)
      String formattedNumber = recipient.number.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Create alert message
      String message = _createAlertMessage(alert);

      // Method 1: Try WhatsApp Business API format (works better on Android)
      final whatsappUrl = 'whatsapp://send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        print('✅ Sending to ${recipient.name} ($formattedNumber)');
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        
        // Wait a bit before sending image
        if (imagePath != null) {
          await Future.delayed(const Duration(seconds: 2));
          await _shareImage(imagePath, recipient);
        }
        
        return true;
      } else {
        // Method 2: Try alternative format
        final altUrl = 'https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}';
        
        if (await canLaunchUrl(Uri.parse(altUrl))) {
          await launchUrl(Uri.parse(altUrl));
          
          if (imagePath != null) {
            await Future.delayed(const Duration(seconds: 2));
            await _shareImage(imagePath, recipient);
          }
          
          return true;
        }
      }

      print('⚠️ WhatsApp not available for ${recipient.name}');
      return false;
    } catch (e) {
      print('❌ Error sending to ${recipient.name}: $e');
      return false;
    }
  }

  static Future<void> _shareImage(String imagePath, PhoneNumber recipient) async {
    try {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '🚨 Security Alert - Snapshot',
      );
    } catch (e) {
      print('❌ Failed to share image: $e');
    }
  }

  static String _createAlertMessage(Alert alert) {
    final emoji = _getAlertEmoji(alert.type);
    final typeTitle = _getAlertTitle(alert.type);
    
    return '''
$emoji *SECURITY ALERT* $emoji

*$typeTitle DETECTED*
━━━━━━━━━━━━━━━━━
📊 Confidence: ${alert.confidence}%
⏰ Time: ${_formatTime(alert.timestamp)}
📍 Location: Security Camera
━━━━━━━━━━━━━━━━━

⚠️ IMMEDIATE ATTENTION REQUIRED

Powered by SecureVision AI
    ''';
  }

  static String _getAlertEmoji(String type) {
    switch (type) {
      case 'weapon':
        return '🔴';
      case 'fire':
        return '🔥';
      case 'intrusion':
        return '🚨';
      default:
        return '⚠️';
    }
  }

  static String _getAlertTitle(String type) {
    switch (type) {
      case 'weapon':
        return 'WEAPON';
      case 'fire':
        return 'FIRE';
      case 'intrusion':
        return 'INTRUSION';
      default:
        return 'THREAT';
    }
  }

  static String _formatTime(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }

  static Future<bool> isWhatsAppInstalled() async {
    const url = 'whatsapp://send?phone=';
    return await canLaunchUrl(Uri.parse(url));
  }
}
