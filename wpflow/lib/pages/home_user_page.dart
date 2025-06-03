import 'package:flutter/material.dart';
import '../components/user_menu.dart';
import '../components/header.dart';
import '../components/session_card.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage> {
  final _phoneController1 = TextEditingController();
  final _phoneController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.all(20.0),
                      child: ListView(
                        children: [
                          const Header(titulo: 'Seja bem-vindo!'),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: deviceSize.height * 0.6,
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SessionCard(
                                    title: 'WhatsApp 1',
                                    sessionName: 'session1',
                                    controller: _phoneController1,
                                  ),
                                  SessionCard(
                                    title: 'WhatsApp 2',
                                    sessionName: 'session2',
                                    controller: _phoneController2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
