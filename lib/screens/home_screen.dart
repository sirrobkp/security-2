import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/detection_provider.dart';
import '../widgets/header.dart';
import '../widgets/bottom_nav.dart';
import 'monitor_tab.dart';
import 'alerts_tab.dart';
import 'settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize detection provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetectionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0a0e1a),
                  Color(0xFF111827),
                  Color(0xFF1e3a8a),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Header(
                    isConnected: appState.isConnected,
                    onMenuClick: () {},
                  ),
                  Expanded(
                    child: _buildCurrentTab(appState.activeTab),
                  ),
                  BottomNav(
                    activeTab: appState.activeTab,
                    onTabChange: (tab) => appState.setActiveTab(tab),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentTab(String activeTab) {
    switch (activeTab) {
      case 'monitor':
        return const MonitorTab();
      case 'alerts':
        return const AlertsTab();
      case 'settings':
        return const SettingsTab();
      default:
        return const MonitorTab();
    }
  }
}
