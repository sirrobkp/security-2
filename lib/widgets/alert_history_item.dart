import 'package:flutter/material.dart';
import '../models/alert.dart';

class AlertHistoryItem extends StatelessWidget {
  final Alert alert;

  const AlertHistoryItem({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (config['bgColor'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (config['borderColor'] as Color).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: config['colors'] as List<Color>,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config['icon'] as IconData,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${config['title']} Detected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${alert.confidence}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(alert.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
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
          'colors': [const Color(0xFFf97316), const Color(0xFFea580c)],
          'bgColor': const Color(0xFFf97316),
          'borderColor': const Color(0xFFf97316),
          'title': 'Intrusion',
        };
      case 'fire':
        return {
          'icon': Icons.local_fire_department,
          'colors': [const Color(0xFFef4444), const Color(0xFFdc2626)],
          'bgColor': const Color(0xFFef4444),
          'borderColor': const Color(0xFFef4444),
          'title': 'Fire',
        };
      case 'weapon':
        return {
          'icon': Icons.warning,
          'colors': [const Color(0xFFdc2626), const Color(0xFFb91c1c)],
          'bgColor': const Color(0xFFdc2626),
          'borderColor': const Color(0xFFdc2626),
          'title': 'Weapon',
        };
      default:
        return {
          'icon': Icons.warning,
          'colors': [const Color(0xFFef4444), const Color(0xFFdc2626)],
          'bgColor': const Color(0xFFef4444),
          'borderColor': const Color(0xFFef4444),
          'title': 'Alert',
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
