import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeProvider with ChangeNotifier {
  final Map<String, String> _sessionTokens = {};
  String? _userId;

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  String _buildSessionId(String session) {
    if (_userId == null) throw Exception('userId não definido');
    return '$_userId$session';
  }

  Future<void> generateToken(String session) async {
    final sessionId = _buildSessionId(session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/THISISMYSECURETOKEN/generate-token',
    );
    final response = await http.post(url);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _sessionTokens[sessionId] = data['token'];
      notifyListeners();
    } else {
      throw Exception('Falha ao gerar token: ${response.body}');
    }
  }

  String? getToken(String session) {
    final sessionId = _buildSessionId(session);
    return _sessionTokens[sessionId];
  }

  Future<String?> startSession(String session) async {
    final sessionId = _buildSessionId(session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/start-session',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${getToken(session)}',
      },
      body: jsonEncode({'webhook': null, 'waitQrCode': false}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['qrcode'];
    } else {
      throw Exception('Erro ao iniciar sessão: ${response.body}');
    }
  }

  Future<String> getStatus(String session) async {
    final sessionId = _buildSessionId(session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/status-session',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${getToken(session)}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'];
    } else {
      throw Exception('Erro ao consultar status: ${response.body}');
    }
  }

  Future<void> logout(String session) async {
    final sessionId = _buildSessionId(session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/logout-session',
    );
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer ${getToken(session)}'},
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao desconectar sessão: ${response.body}');
    }
  }
}
