import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wpflow/models/session_manager.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = context.read<SessionManagerProvider>();
      final sessionId = HomeProvider.buildSessionId(
        context,
        widget.sessionName,
      );
      final label = sessionProvider.getSessionLabel(sessionId);

      if (label != null && widget.controller.text != label) {
        widget.controller.text = label;
      }

      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      await context.read<HomeProvider>().generateToken(
        context,
        widget.sessionName,
      );
      await _checkStatus();
    } catch (e) {
      _showError('Erro ao iniciar sessão: $e');
    }
  }

  Future<void> _connect() async {
    setState(() => _isLoading = true);
    try {
      final homeProvider = context.read<HomeProvider>();
      final sessionProvider = context.read<SessionManagerProvider>();

      homeProvider.setSessionLabel(
        context,
        widget.sessionName,
        widget.controller.text,
      );
      final sessionId = HomeProvider.buildSessionId(
        context,
        widget.sessionName,
      );

      final token = homeProvider.getToken(context, widget.sessionName);

      if (token == null) {
        _showError('Token não encontrado para a sessão.');
        return;
      }

      sessionProvider.setToken(sessionId, token);
      sessionProvider.setSessionLabel(sessionId, widget.controller.text);
      sessionProvider.setActiveSession(sessionId);

      const maxAttempts = 10;
      const delayBetweenAttempts = Duration(seconds: 2);

      String? qrCodeBase64;
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        qrCodeBase64 = await homeProvider.startSession(
          context,
          widget.sessionName,
        );
        if (qrCodeBase64 != null) {
          break;
        }
        await Future.delayed(delayBetweenAttempts);
      }

      if (qrCodeBase64 != null) {
        _showQrCodeDialog(qrCodeBase64);
      } else {
        _showError('Não foi possível gerar o QR Code após várias tentativas.');
      }
    } catch (e) {
      _showError('Erro ao conectar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isLoading = true);
    try {
      final sessionProvider = context.read<SessionManagerProvider>();
      final homeProvider = context.read<HomeProvider>();

      final sessionId = HomeProvider.buildSessionId(
        context,
        widget.sessionName,
      );

      await homeProvider.logout(context, widget.sessionName);
      sessionProvider.removeSession(sessionId);

      setState(() => status = "DESCONECTADO");
    } catch (e) {
      _showError('Erro ao desconectar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkStatus() async {
    try {
      final result = await context.read<HomeProvider>().getStatus(
        context,
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
            context,
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
          backgroundColor: const Color(0xFF2D2D2F),
          title: Center(
            child: const Text(
              'Escaneie o QR Code',
              style: TextStyle(color: Colors.white),
            ),
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
                  enabled: status != "CONECTADO",
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Identificação',
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
                    onPressed: _isLoading || isConnected ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading && !isConnected
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.greenAccent,
                              ),
                            )
                            : const Text('Conectar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading || !isConnected ? null : _disconnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading && isConnected
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.greenAccent,
                              ),
                            )
                            : const Text('Desconectar'),
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
