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

  Future<String> generateToken(BuildContext context, String session) async {
    final sessionId = buildSessionId(context, session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/THISISMYSECURETOKEN/generate-token',
    );

    debugPrint('Gerando token: POST $url');

    final response = await http.post(url);

    debugPrint('Resposta do token: ${response.statusCode} — ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Token vazio recebido da API');
      }
      _sessionTokens[sessionId] = token;
      notifyListeners();
      return token;
    } else {
      throw Exception(
        'Falha ao gerar token: ${response.statusCode} ${response.body}',
      );
    }
  }

  String? getToken(BuildContext context, String session) {
    final sessionId = buildSessionId(context, session);
    return _sessionTokens[sessionId];
  }

  Future<String?> startSession({
    required BuildContext context,
    required String session,
    required String token,
  }) async {
    final sessionId = buildSessionId(context, session);
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/start-session',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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

  Future<String> getStatus(
    BuildContext context,
    String session, {
    String? sessionId,
    String? token,
  }) async {
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/status-session',
    );

    print('Dentro do getStatus sessionId: $sessionId Token: $token');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Status code da consulta: ${response.statusCode}');
    print('Status recebido: ${jsonDecode(response.body)['status']}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'];
    } else {
      throw Exception('Erro ao consultar status: ${response.body}');
    }
  }

  Future<void> logout(
    BuildContext context,
    String session, {
    String? sessionId,
    String? token,
  }) async {
    final url = Uri.parse(
      'http://localhost:21465/api/$sessionId/logout-session',
    );

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao desconectar sessão: ${response.body}');
    }
  }

  Future<void> CloseSession(BuildContext context, String session) async {
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
