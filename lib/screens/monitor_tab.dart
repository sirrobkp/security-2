import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securevision_flutter/models/alert.dart';
import '../providers/app_state.dart';
import '../providers/detection_provider.dart';
import '../widgets/threat_alert.dart';
import '../widgets/camera_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/whatsapp_modal.dart';

class MonitorTab extends StatelessWidget {
  const MonitorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, DetectionProvider>(
      builder: (context, appState, detectionProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Active Threat Alert
              if (appState.currentThreat != null) ...[
                ThreatAlert(
                  alert: appState.currentThreat!,
                  onDismiss: () => appState.dismissCurrentThreat(),
                  onSendWhatsApp: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => WhatsAppModal(
                        alert: appState.currentThreat!,
                        phoneNumbers: appState.phoneNumbers,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Camera View
              CameraView(
                isConnected: appState.isConnected,
                cameraController: detectionProvider.cameraController,
              ),
              const SizedBox(height: 20),

              // Stats Grid
              if (appState.isConnected) ...[
                const Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.shield,
                        label: 'Status',
                        value: 'Active',
                        colors: [Color(0xFF22c55e), Color(0xFF16a34a)],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.access_time,
                        label: 'Uptime',
                        value: '24h',
                        colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.warning,
                        label: 'Alerts Today',
                        value: appState.alertHistory.where((a) {
                          final today = DateTime.now();
                          return a.timestamp.year == today.year &&
                              a.timestamp.month == today.month &&
                              a.timestamp.day == today.day;
                        }).length.toString(),
                        colors: const [Color(0xFFf97316), Color(0xFFea580c)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: StatCard(
                        icon: Icons.check_circle,
                        label: 'Detection',
                        value: '98.7%',
                        colors: [Color(0xFFa855f7), Color(0xFF9333ea)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Simulate Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3b82f6).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Simulate threat detection
                        final types = ['intrusion', 'fire', 'weapon'];
                        final randomType = types[DateTime.now().millisecond % 3];
                        
                        appState.setCurrentThreat(
                          Alert(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            type: randomType,
                            confidence: 85 + (DateTime.now().millisecond % 15),
                            timestamp: DateTime.now(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: const Text(
                          'Simulate Threat Detection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
