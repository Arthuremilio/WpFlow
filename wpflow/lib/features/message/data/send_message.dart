import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendMessageProvider with ChangeNotifier {
  Future<void> sendTextMessage({
    required String session,
    required String phone,
    required String message,
    required String token,
  }) async {
    final url = Uri.parse('http://localhost:21465/api/$session/send-message');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"phone": phone, "message": message, "isGroup": false}),
    );
    print(
      'Sessão: $session / Token: $token / URL: $url / phone: $phone / message: $message',
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Erro ao enviar mensagem: ${response.body}");
    }
  }

  Future<void> sendImageBase64({
    required String session,
    required String phone,
    required String base64Data,
    required String token,
  }) async {
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
