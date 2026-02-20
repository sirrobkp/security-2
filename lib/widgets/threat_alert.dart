import 'package:flutter/material.dart';
import '../models/alert.dart';

class ThreatAlert extends StatelessWidget {
  final Alert alert;
  final VoidCallback onDismiss;
  final VoidCallback onSendWhatsApp;

  const ThreatAlert({
    super.key,
    required this.alert,
    required this.onDismiss,
    required this.onSendWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config['colors'] as List<Color>,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (config['colors'] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  config['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config['description'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence Level',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                '${alert.confidence}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: alert.confidence / 100,
              backgroundColor: Colors.black.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                _getTimeAgo(alert.timestamp),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSendWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366).withOpacity(0.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF25D366).withOpacity(0.3),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Color(0xFF86efac), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Send to WhatsApp',
                    style: TextStyle(
                      color: Color(0xFF86efac),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getAlertConfig() {
    switch (alert.type) {
      case 'intrusion':
        return {
          'icon': Icons.shield_outlined,
          'colors': [const Color(0xFFf97316), const Color(0xFFea580c), const Color(0xFFc2410c)],
          'title': 'Intrusion Detected',
          'description': 'Unauthorized person detected in frame',
        };
      case 'fire':
        return {
          'icon': Icons.local_fire_department,
          'colors': [const Color(0xFFef4444), const Color(0xFFdc2626), const Color(0xFFb91c1c)],
          'title': 'Fire Detected',
          'description': 'Smoke or flames detected in frame',
        };
      case 'weapon':
        return {
          'icon': Icons.warning,
          'colors': [const Color(0xFFdc2626), const Color(0xFFb91c1c), const Color(0xFF991b1b)],
          'title': 'Weapon Detected',
          'description': 'Dangerous object identified in frame',
        };
      default:
        return {
          'icon': Icons.warning,
          'colors': [const Color(0xFFef4444), const Color(0xFFdc2626)],
          'title': 'Alert',
          'description': 'Security threat detected',
        };
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
  }
}
