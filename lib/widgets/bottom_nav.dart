import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'id': 'monitor', 'icon': Icons.home, 'label': 'Monitor'},
      {'id': 'alerts', 'icon': Icons.history, 'label': 'Alerts'},
      {'id': 'settings', 'icon': Icons.settings, 'label': 'Settings'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0e1a).withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = activeTab == item['id'];
          return Expanded(
            child: InkWell(
              onTap: () => onTabChange(item['id'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF3b82f6).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isActive
                          ? const Color(0xFF60a5fa)
                          : Colors.white.withOpacity(0.4),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF60a5fa)
                            : Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
