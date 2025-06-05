import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/session_manager.dart';

class SendBuckMessageExcelProvider with ChangeNotifier {
  SendBuckMessageExcelProvider({required this.sessionManager});

  SessionManagerProvider sessionManager;

  bool isSending = false;
  int totalMessages = 0;
  int messagesSent = 0;

  List<String> get availableSessions => sessionManager.availableSessions;

  Map<String, String> get sessionLabels => sessionManager.sessionLabels;

  String? getSessionLabel(String sessionId) {
    return sessionManager.getSessionLabel(sessionId);
  }

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

  Future<void> sendMessagesFromExcel({
    required String session,
    required List<Map<String, String>> records,
    required String nameColumn,
    required String phoneColumn,
    required String messageColumn,
    required VoidCallback onProgress,
  }) async {
    isSending = true;
    totalMessages = records.length;
    messagesSent = 0;
    notifyListeners();

    for (int i = 0; i < records.length; i++) {
      final rec = records[i];
      final phone = rec[phoneColumn] ?? '';
      final name = rec[nameColumn] ?? '';
      final rawMessage = rec[messageColumn] ?? '';

      final now = DateTime.now();
      String saudacao;
      if (now.hour < 12) {
        saudacao = "Bom dia";
      } else if (now.hour < 18) {
        saudacao = "Boa tarde";
      } else {
        saudacao = "Boa noite";
      }

      final message = "$saudacao $name, $rawMessage";

      try {
        await sendTextMessage(session: session, phone: phone, message: message);
        rec['Status'] = 'Enviado';
      } catch (e) {
        rec['Status'] = 'Erro';
      }

      messagesSent++;
      notifyListeners();
      onProgress();

      await Future.delayed(
        Duration(seconds: 5 + (DateTime.now().millisecondsSinceEpoch % 26)),
      );
    }

    isSending = false;
    notifyListeners();
  }
}
