import 'package:flutter/material.dart';

class SessionManagerProvider with ChangeNotifier {
  final Map<String, String> _sessionTokens = {};
  final Map<String, String> _sessionLabels = {};
  String? _activeSessionId;
  String? _selectedSession;

  void setActiveSession(String sessionId) {
    _activeSessionId = sessionId;
    notifyListeners();
  }

  String? get activeSession => _activeSessionId;

  void setToken(String session, String token) {
    _sessionTokens[session] = token;
    notifyListeners();
  }

  void setSessionLabel(String session, String label) {
    _sessionLabels[session] = label;
    notifyListeners();
  }

  String? getSessionLabel(String sessionId) {
    return _sessionLabels[sessionId];
  }

  void removeSession(String sessionId) {
    _sessionTokens.remove(sessionId);
    _sessionLabels.remove(sessionId);

    if (_activeSessionId == sessionId) {
      _activeSessionId = null;
    }
    if (_selectedSession == sessionId) {
      _selectedSession = null;
    }

    notifyListeners();
  }

  Map<String, String> get sessionLabels => _sessionLabels;

  List<String> get availableSessions => _sessionTokens.keys.toList();

  String? getToken(String sessionId) => _sessionTokens[sessionId];

  String? get selectedSession => _selectedSession;

  void setSelectedSession(String? sessionId) {
    _selectedSession = sessionId;
    notifyListeners();
  }
}
