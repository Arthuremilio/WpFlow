import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wpflow/models/session_manager.dart';
import '../components/user_menu.dart';
import '../components/header.dart';
import '../models/send_message.dart';
import '../components/dropdown_session.dart';
import '../components/simple_message_tab.dart';
import '../components/simple_send_button.dart';

class SimpleMessagePage extends StatefulWidget {
  const SimpleMessagePage({super.key});

  @override
  State<SimpleMessagePage> createState() => _SimpleMessagePageState();
}

class _SimpleMessagePageState extends State<SimpleMessagePage>
    with TickerProviderStateMixin {
  final phoneController = TextEditingController();
  final messageController = TextEditingController();
  PlatformFile? selectedImage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      context.read<SessionManagerProvider>().fetchSessionsForContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sendProvider = Provider.of<SendMessageProvider>(context);
    final sessionProvider = Provider.of<SessionManagerProvider>(context);
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2F),
      body: Center(
        child: Container(
          width: deviceSize.width * 0.98,
          height: deviceSize.height * 0.95,
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
                          Consumer<SessionManagerProvider>(
                            builder: (context, sessionProvider, _) {
                              final sessionLabels =
                                  sessionProvider.sessionLabels;
                              final selected =
                                  sessionLabels.containsKey(
                                        sessionProvider.selectedSession,
                                      )
                                      ? sessionProvider.selectedSession
                                      : null;

                              return SizedBox(
                                height: 30,
                                child: DropdownSession(
                                  items: sessionLabels,
                                  selectedValue: selected,
                                  onChanged: (value) {
                                    sessionProvider.setSelectedSession(value);
                                  },
                                ),
                              );
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
                          MessageTabs(
                            controller: _tabController,
                            messageController: messageController,
                            selectedImage: selectedImage,
                            onImageSelected: (image) {
                              setState(() {
                                selectedImage = image;
                              });
                            },
                          ),
                          SendButton(
                            selectedSession:
                                context
                                    .watch<SessionManagerProvider>()
                                    .selectedSession,
                            phoneController: phoneController,
                            messageController: messageController,
                            selectedImage: selectedImage,
                            tabController: _tabController,
                            provider: sendProvider,
                            sessionProvider: sessionProvider,
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
