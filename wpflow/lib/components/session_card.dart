import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wpflow/models/user.dart';
import '../models/home_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    print('Entrou no initState');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _restoreSessionIfActive();
    });
  }

  Future<void> _restoreSessionIfActive() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId == null) {
        debugPrint('Abortado: userId é null');
        return;
      }

      final sessionId = '$userId${widget.sessionName}';

      final query =
          await FirebaseFirestore.instance
              .collection('whatsapp_sessions')
              .where('session', isEqualTo: widget.sessionName)
              .where('userId', isEqualTo: userId)
              .where('disconnectAt', isNull: true)
              .orderBy('connectAt', descending: true)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final token = data['token'] as String?;
        final label = data['label'] as String?;

        if (label != null && widget.controller.text != label) {
          widget.controller.text = label;
        }

        if (token != null) {
          final result = await context.read<HomeProvider>().getStatus(
            context,
            widget.sessionName,
            sessionId: sessionId,
            token: token,
          );

          setState(() {
            status = result == "CONNECTED" ? "CONECTADO" : "DESCONECTADO";
          });
        }
      } else {
        debugPrint('Nenhuma sessão ativa encontrada no Firestore');
      }
    } catch (e) {
      debugPrint('Erro ao restaurar sessão: $e');
      _showError('Erro ao restaurar sessão: $e');
    }
  }

  Future<void> _saveSessionToFirestore({
    required String session,
    required String label,
    required String token,
    required String userId,
  }) async {
    final payload = {
      'session': session,
      'label': label,
      'token': token,
      'userId': userId,
      'connectAt': FieldValue.serverTimestamp(),
      'disconnectAt': null,
    };

    try {
      debugPrint('Salvando no Firestore: $payload');
      await FirebaseFirestore.instance
          .collection('whatsapp_sessions')
          .add(payload);
    } on FirebaseException catch (e) {
      debugPrint('Erro Firebase: ${e.message}');
      throw Exception('Erro ao salvar sessão no Firestore: ${e.message}');
    } catch (e) {
      debugPrint('Erro inesperado: ${e.toString()}');
      throw Exception('Erro inesperado ao salvar sessão');
    }
  }

  Future<void> _updateSessionDisconnection(String session, String token) async {
    final query =
        await FirebaseFirestore.instance
            .collection('whatsapp_sessions')
            .where('session', isEqualTo: session)
            .where('token', isEqualTo: token)
            .where('disconnectAt', isNull: true)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'disconnectAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _connect() async {
    setState(() {
      _isLoading = true;
      status = 'CONECTANDO';
    });
    try {
      final hp = context.read<HomeProvider>();
      final userId = Provider.of<UserProvider>(context, listen: false).userId!;
      final label = widget.controller.text;

      final token = await hp.generateToken(context, widget.sessionName);
      final sessionId = '$userId${widget.sessionName}';

      final qr = await hp.startSession(
        context: context,
        session: widget.sessionName,
        token: token,
      );

      if (qr != null) {
        await _showQrCodeDialog(
          qrBase64: qr,
          sessionId: sessionId,
          token: token,
          label: label,
          userId: userId,
        );
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
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      final sessionId = '$userId${widget.sessionName}';

      final query =
          await FirebaseFirestore.instance
              .collection('whatsapp_sessions')
              .where('session', isEqualTo: widget.sessionName)
              .where('userId', isEqualTo: userId)
              .where('disconnectAt', isNull: true)
              .orderBy('connectAt', descending: true)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        _showError('Sessão ativa não encontrada para desconectar.');
        return;
      }

      final data = query.docs.first.data();
      final token = data['token'] as String?;

      if (token == null) {
        _showError('Token não encontrado para desconectar.');
        return;
      }

      await context.read<HomeProvider>().logout(
        context,
        widget.sessionName,
        sessionId: sessionId,
        token: token,
      );

      await _updateSessionDisconnection(widget.sessionName, token);
    } catch (e) {
      _showError('Erro ao desconectar: $e');
    } finally {
      setState(() {
        _isLoading = false;
        status = 'DESCONECTADO';
      });
    }
  }

  Future<void> _showQrCodeDialog({
    required String qrBase64,
    required String sessionId,
    required String token,
    required String label,
    required String userId,
  }) async {
    final base64String = qrBase64.split(',').last;
    Timer? timeoutTimer;
    Timer? pollingTimer;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        timeoutTimer = Timer(const Duration(seconds: 50), () {
          if (mounted) Navigator.of(context).pop();
        });

        pollingTimer = Timer.periodic(const Duration(seconds: 2), (
          timer,
        ) async {
          try {
            final result = await context.read<HomeProvider>().getStatus(
              context,
              widget.sessionName,
              sessionId: sessionId,
              token: token,
            );

            if (result == "CONNECTED" && mounted) {
              timer.cancel();
              timeoutTimer?.cancel();
              Navigator.of(context).pop();

              await _saveSessionToFirestore(
                session: widget.sessionName,
                label: label,
                token: token,
                userId: userId,
              );

              setState(() => status = "CONECTADO");
            }
          } catch (e) {
            // ignore erros de polling silenciosamente
          }
        });

        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2F),
          title: const Center(
            child: Text(
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
