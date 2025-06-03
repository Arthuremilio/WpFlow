import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendMessageProvider with ChangeNotifier {
  final Map<String, String> _sessionTokens = {};
  final Map<String, String> _sessionLabels = {};

  void setToken(String session, String token) {
    _sessionTokens[session] = token;
    notifyListeners();
  }

  void setSessionLabel(String session, String label) {
    _sessionLabels[session] = label;
    notifyListeners();
  }

  Map<String, String> get sessionLabels => _sessionLabels;

  List<String> get availableSessions => _sessionTokens.keys.toList();

  Future<void> sendMessage({
    required String session,
    required String phone,
    required String message,
  }) async {
    final token = _sessionTokens[session];
    if (token == null) throw Exception("Token não encontrado para a sessão.");

    final url = Uri.parse('http://localhost:21465/api/$session/send-message');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"phone": phone, "message": message, "isGroup": false}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Erro ao enviar mensagem: ${response.body}");
    }
  }
}
