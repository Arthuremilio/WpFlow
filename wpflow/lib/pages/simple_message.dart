import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/user_menu.dart';
import '../components/header.dart';
import '../models/send_message.dart';

class SimpleMessagePage extends StatefulWidget {
  const SimpleMessagePage({super.key});

  @override
  State<SimpleMessagePage> createState() => _SimpleMessagePageState();
}

class _SimpleMessagePageState extends State<SimpleMessagePage> {
  String? selectedSession;
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SendMessageProvider>(context);
    final sessions = provider.availableSessions;

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2F),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.98,
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Card(
              child: Row(
                children: [
                  const UserMenu(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        children: [
                          const Header(titulo: 'Envio de uma única mensagem!'),
                          const SizedBox(height: 20),
                          DropdownButton<String>(
                            value: selectedSession,
                            hint: const Text('Selecione uma sessão'),
                            items:
                                provider.sessionLabels.entries
                                    .map(
                                      (entry) => DropdownMenuItem<String>(
                                        value: entry.key, // sessionId completo
                                        child: Text(
                                          entry.value,
                                        ), // rótulo (identificação)
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSession = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),
                          TextField(
                            controller: phoneController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white12,
                              labelText:
                                  'Número de telefone (ex: 5517999999999)',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: messageController,
                            maxLines: 5,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white12,
                              labelText: 'Mensagem',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedSession != null &&
                                  phoneController.text.isNotEmpty &&
                                  messageController.text.isNotEmpty) {
                                try {
                                  await provider.sendMessage(
                                    session: selectedSession!,
                                    phone: phoneController.text,
                                    message: messageController.text,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Mensagem enviada com sucesso!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Enviar Mensagem'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
