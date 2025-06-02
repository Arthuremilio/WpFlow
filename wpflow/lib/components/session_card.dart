import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/home_user.dart';

class SessionCard extends StatefulWidget {
  final String title;
  final String sessionName;
  final TextEditingController controller;

  const SessionCard({
    super.key,
    required this.title,
    required this.sessionName,
    required this.controller,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  String status = "DESCONECTADO";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await context.read<HomeProvider>().generateToken(widget.sessionName);
      await _checkStatus();
    } catch (e) {
      _showError('Erro ao iniciar sessão: $e');
    }
  }

  Future<void> _connect() async {
    try {
      final qrCodeBase64 = await context.read<HomeProvider>().startSession(
        widget.sessionName,
      );
      if (qrCodeBase64 != null) {
        _showQrCodeDialog(qrCodeBase64);
      }
    } catch (e) {
      _showError('Erro ao conectar: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await context.read<HomeProvider>().logout(widget.sessionName);
      setState(() => status = "DESCONECTADO");
    } catch (e) {
      _showError('Erro ao desconectar: $e');
    }
  }

  Future<void> _checkStatus() async {
    try {
      final result = await context.read<HomeProvider>().getStatus(
        widget.sessionName,
      );
      setState(() {
        status = result == "CONNECTED" ? "CONECTADO" : "DESCONECTADO";
      });
    } catch (e) {
      _showError('Erro ao verificar status: $e');
    }
  }

  void _showQrCodeDialog(String base64Data) {
    final base64String = base64Data.split(',').last;
    showDialog(
      context: context,
      builder: (context) {
        Timer(const Duration(seconds: 40), () {
          if (mounted) {
            Navigator.of(context).pop();
            _checkStatus();
          }
        });
        return AlertDialog(
          title: const Text('Escaneie o QR Code'),
          content: Image.memory(base64Decode(base64String)),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = status == "CONECTADO";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: $status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isConnected ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Conectar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isConnected ? _disconnect : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Desconectar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
