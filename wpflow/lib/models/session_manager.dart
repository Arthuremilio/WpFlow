import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wpflow/models/user.dart';
import 'package:provider/provider.dart';

class SessionManagerProvider with ChangeNotifier {
  final Map<String, String> _sessionTokens = {};
  final Map<String, String> _sessionLabels = {};
  String? _selectedSession;

  String? get selectedSession => _selectedSession;

  void setSelectedSession(String? sessionId) {
    _selectedSession = sessionId;
    notifyListeners();
  }

  Map<String, String> get sessionLabels => _sessionLabels;

  Future<void> fetchConnectedSessions(String userId) async {
    final query =
        await FirebaseFirestore.instance
            .collection('whatsapp_sessions')
            .where('userId', isEqualTo: userId)
            .where('disconnectAt', isNull: true)
            .orderBy('connectAt', descending: true)
            .get();

    _sessionLabels.clear();
    _sessionTokens.clear();

    for (final doc in query.docs) {
      final data = doc.data();
      final session = data['session'];
      final label = data['label'] ?? session;
      final token = data['token'];

      print('Session: $session, Label: $label, Token: $token'); // <-- debug

      if (session != null && token != null) {
        _sessionLabels[session] = label;
        _sessionTokens[session] = token;
      }
    }

    notifyListeners();
  }

  String? getToken(String sessionId) => _sessionTokens[sessionId];

  Future<void> fetchSessionsForContext(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId != null) {
      await fetchConnectedSessions(userId);
    }
  }
}
