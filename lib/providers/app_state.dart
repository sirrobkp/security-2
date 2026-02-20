import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../models/phone_number.dart';

class AppState extends ChangeNotifier {
  String _activeTab = 'monitor';
  bool _isConnected = false;
  String _rtspUrl = '';
  Alert? _currentThreat;
  final List<Alert> _alertHistory = [];
  List<PhoneNumber> _phoneNumbers = [];
  final Map<String, bool> _detectionSettings = {
    'intrusion': true,
    'fire': true,
    'weapon': true,
  };

  // Getters
  String get activeTab => _activeTab;
  bool get isConnected => _isConnected;
  String get rtspUrl => _rtspUrl;
  Alert? get currentThreat => _currentThreat;
  List<Alert> get alertHistory => _alertHistory;
  List<PhoneNumber> get phoneNumbers => _phoneNumbers;
  Map<String, bool> get detectionSettings => _detectionSettings;

  // Setters
  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setConnected(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void setRtspUrl(String url) {
    _rtspUrl = url;
    notifyListeners();
  }

  void setCurrentThreat(Alert? threat) {
    _currentThreat = threat;
    if (threat != null) {
      _alertHistory.insert(0, threat);
    }
    notifyListeners();
  }

  void dismissCurrentThreat() {
    _currentThreat = null;
    notifyListeners();
  }

  void addPhoneNumber(PhoneNumber phone) {
    _phoneNumbers.add(phone);
    notifyListeners();
  }

  void removePhoneNumber(String id) {
    _phoneNumbers.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void setPrimaryNumber(String id) {
    _phoneNumbers = _phoneNumbers.map((p) {
      return PhoneNumber(
        id: p.id,
        name: p.name,
        number: p.number,
        isPrimary: p.id == id,
      );
    }).toList();
    notifyListeners();
  }

  void toggleDetectionSetting(String key) {
    _detectionSettings[key] = !(_detectionSettings[key] ?? false);
    notifyListeners();
  }

  void clearAlertHistory() {
    _alertHistory.clear();
    notifyListeners();
  }
}
