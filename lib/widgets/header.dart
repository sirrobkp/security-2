import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onMenuClick;

  const Header({
    super.key,
    required this.isConnected,
    required this.onMenuClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0e1a).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3b82f6).withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SecureVision',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.wifi : Icons.wifi_off,
                        color: isConnected
                            ? const Color(0xFF4ade80)
                            : const Color(0xFFf87171),
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: isConnected
                              ? const Color(0xFF4ade80)
                              : const Color(0xFFf87171),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: onMenuClick,
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
