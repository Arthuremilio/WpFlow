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
    Timer? timeoutTimer;
    Timer? pollingTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        timeoutTimer = Timer(const Duration(seconds: 50), () {
          if (mounted) Navigator.of(context).pop();
        });

        pollingTimer = Timer.periodic(const Duration(seconds: 2), (
          timer,
        ) async {
          final result = await context.read<HomeProvider>().getStatus(
            widget.sessionName,
          );
          if (result == "CONNECTED" && mounted) {
            timer.cancel();
            timeoutTimer?.cancel();
            Navigator.of(context).pop();
            setState(() => status = "CONECTADO");
          }
        });

        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2F), // fundo escuro
          title: const Text(
            'Escaneie o QR Code',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Image.memory(base64Decode(base64String)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    ).then((_) {
      timeoutTimer?.cancel();
      pollingTimer?.cancel();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = status == "CONECTADO";

    return SizedBox(
      width: 300,
      height: 230,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Identificação',
                    border: OutlineInputBorder(),
                  ),
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
                mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
