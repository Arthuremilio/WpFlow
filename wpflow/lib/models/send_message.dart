import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/session_manager.dart';

class SendMessageProvider with ChangeNotifier {
  final SessionManagerProvider sessionManager;

  SendMessageProvider({required this.sessionManager});

  Future<void> sendTextMessage({
    required String session,
    required String phone,
    required String message,
  }) async {
    final token = sessionManager.getToken(session);
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

  Future<void> sendImageBase64({
    required String session,
    required String phone,
    required String base64Data,
  }) async {
    final token = sessionManager.getToken(session);
    if (token == null) throw Exception("Token não encontrado para a sessão.");

    final url = Uri.parse(
      'http://localhost:21465/api/$session/send-file-base64',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'base64': base64Data,
        'isGroup': false,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao enviar imagem base64: ${response.body}');
    }
  }
}
