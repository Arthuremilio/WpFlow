import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendBuckMessageExcelProvider with ChangeNotifier {
  bool isSending = false;
  bool shouldStop = false;
  bool isPaused = false;
  int totalMessages = 0;
  int messagesSent = 0;

  void stopSending() {
    shouldStop = true;
  }

  void pauseSending() {
    isPaused = true;
    notifyListeners();
  }

  void resumeSending() {
    isPaused = false;
    notifyListeners();
  }

  void reset() {
    isSending = false;
    shouldStop = false;
    isPaused = false;
    totalMessages = 0;
    messagesSent = 0;
    notifyListeners();
  }

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

  Future<void> sendMessagesFromExcel({
    required String session,
    required List<Map<String, String>> records,
    required String nameColumn,
    required String phoneColumn,
    required String messageColumn,
    required String token,
    required VoidCallback onProgress,
  }) async {
    isSending = true;
    shouldStop = false;
    isPaused = false;
    totalMessages = records.length;
    messagesSent = 0;
    notifyListeners();

    for (int i = 0; i < records.length; i++) {
      if (shouldStop) break;

      while (isPaused) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (shouldStop) break;
      }

      if (shouldStop) break;

      final rec = records[i];
      final phone = rec[phoneColumn] ?? '';
      final name = rec[nameColumn] ?? '';
      final rawMessage = rec[messageColumn] ?? '';

      final now = DateTime.now();
      String saudacao =
          now.hour < 12
              ? "Bom dia"
              : now.hour < 18
              ? "Boa tarde"
              : "Boa noite";

      final message = "$saudacao $name, $rawMessage";

      try {
        await sendTextMessage(
          session: session,
          phone: phone,
          message: message,
          token: token,
        );
        rec['Status'] = 'Enviado';
        messagesSent++;
      } catch (e) {
        rec['Status'] = 'Erro';
      }

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
