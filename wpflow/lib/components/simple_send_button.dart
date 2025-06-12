import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wpflow/models/session_manager.dart';
import 'package:wpflow/models/user.dart';
import '../models/send_message.dart';
import 'package:provider/provider.dart';

class SendButton extends StatelessWidget {
  final String? selectedSession;
  final TextEditingController phoneController;
  final TextEditingController messageController;
  final PlatformFile? selectedImage;
  final TabController tabController;
  final SendMessageProvider provider;
  final SessionManagerProvider sessionProvider;

  const SendButton({
    super.key,
    required this.selectedSession,
    required this.phoneController,
    required this.messageController,
    required this.selectedImage,
    required this.tabController,
    required this.provider,
    required this.sessionProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250,
        child: ElevatedButton(
          onPressed: () async {
            if (selectedSession == null || phoneController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preencha sessão e telefone.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final token = sessionProvider.getToken(selectedSession!);
            if (token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Token não encontrado para a sessão.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            final userId = userProvider.userId ?? '';
            final sessionName = '${userId}$selectedSession';

            try {
              switch (tabController.index) {
                case 0:
                  await provider.sendTextMessage(
                    session: sessionName,
                    phone: phoneController.text,
                    message: messageController.text,
                    token: token,
                  );
                  break;
                case 1:
                  if (selectedImage == null || selectedImage!.bytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecione uma imagem válida.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final mimeType =
                      selectedImage!.extension == 'png'
                          ? 'image/png'
                          : 'image/jpeg';
                  final base64Str = base64Encode(selectedImage!.bytes!);
                  final base64Data = 'data:$mimeType;base64,$base64Str';

                  await provider.sendImageBase64(
                    session: sessionName,
                    phone: phoneController.text,
                    base64Data: base64Data,
                    token: token,
                  );
                  break;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Mensagem enviada com sucesso!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.greenAccent,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Enviar Mensagem'),
        ),
      ),
    );
  }
}
