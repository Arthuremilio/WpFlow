import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/user.dart';

class HomeProvider with ChangeNotifier {
  final Map<String, String> _sessionTokens = {};
  final Map<String, String> _sessionLabels = {};

  void setSessionLabel(BuildContext context, String session, String label) {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) throw Exception('Usuário não identificado');
    final sessionId = '$userId$session';
    _sessionLabels[sessionId] = label;
    notifyListeners();
  }

  List<String> get availableSessions {
    return _sessionLabels.entries
        .where((e) => _sessionTokens.containsKey(e.key))
        .map((e) => e.value)
        .toList();
  }

  static String buildSessionId(BuildContext context, String session) {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) throw Exception('userId não definido');
    return '$userId$session';
  }

  Future<void> generateToken(BuildContext context, String session) async {
    final sessionId = buildSessionId(context, session);
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

  String? getToken(BuildContext context, String session) {
    final sessionId = buildSessionId(context, session);
    return _sessionTokens[sessionId];
  }

  Future<String?> startSession(BuildContext context, String session) async {
    final sessionId = buildSessionId(context, session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/start-session',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${getToken(context, session)}',
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

  Future<String> getStatus(BuildContext context, String session) async {
    final sessionId = buildSessionId(context, session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/status-session',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${getToken(context, session)}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'];
    } else {
      throw Exception('Erro ao consultar status: ${response.body}');
    }
  }

  Future<void> logout(BuildContext context, String session) async {
    final sessionId = buildSessionId(context, session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/close-session',
    );
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer ${getToken(context, session)}'},
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao desconectar sessão: ${response.body}');
    }
  }
}
