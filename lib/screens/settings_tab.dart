import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/phone_number_manager.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure your security system',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Camera Connection
              _buildSection(
                icon: Icons.link,
                iconColor: const Color(0xFF60a5fa),
                title: 'Camera Connection',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RTSP Stream URL',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      enabled: !appState.isConnected,
                      onChanged: (value) => appState.setRtspUrl(value),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'rtsp://username:password@ip:port/stream',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF3b82f6),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Example: rtsp://admin:password@192.168.1.100:554/stream1',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: appState.isConnected
                          ? ElevatedButton(
                              onPressed: () => appState.setConnected(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFef4444).withOpacity(0.2),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: const Color(0xFFef4444).withOpacity(0.3),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Disconnect Camera',
                                style: TextStyle(
                                  color: Color(0xFFf87171),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: appState.rtspUrl.isNotEmpty
                                    ? () => appState.setConnected(true)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Connect Camera',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number Manager
              PhoneNumberManager(
                phoneNumbers: appState.phoneNumbers,
                onAdd: (phone) => appState.addPhoneNumber(phone),
                onRemove: (id) => appState.removePhoneNumber(id),
                onSetPrimary: (id) => appState.setPrimaryNumber(id),
              ),
              const SizedBox(height: 20),

              // Detection Settings
              _buildSection(
                icon: Icons.shield,
                iconColor: const Color(0xFFa855f7),
                title: 'Detection Settings',
                child: Column(
                  children: [
                    _buildToggle(
                      'Motion Detection',
                      'Detect unauthorized persons',
                      appState.detectionSettings['intrusion'] ?? false,
                      () => appState.toggleDetectionSetting('intrusion'),
                    ),
                    const SizedBox(height: 16),
                    _buildToggle(
                      'Fire Detection',
                      'Detect smoke and flames',
                      appState.detectionSettings['fire'] ?? false,
                      () => appState.toggleDetectionSetting('fire'),
                    ),
                    const SizedBox(height: 16),
                    _buildToggle(
                      'Weapon Detection',
                      'Detect dangerous objects',
                      appState.detectionSettings['weapon'] ?? false,
                      () => appState.toggleDetectionSetting('weapon'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildToggle(
    String title,
    String description,
    bool value,
    VoidCallback onToggle,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (_) => onToggle(),
          activeThumbColor: const Color(0xFF3b82f6),
        ),
      ],
    );
  }
}
