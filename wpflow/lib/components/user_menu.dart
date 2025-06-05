import 'package:flutter/material.dart';
import 'package:wpflow/models/home_user.dart';
import 'package:wpflow/models/session_manager.dart';
import '../utils/app-routes.dart';
import 'package:provider/provider.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.HOMEUSER);
            },
            child: Image.asset(
              'lib/assets/img/logo/wpFlow_logo.png',
              width: 40,
              height: 40,
            ),
          ),
          IconButton(
            icon: Icon(Icons.message, color: Colors.white),
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.SIMPLE_MESSAGE);
            },
          ),
          IconButton(
            icon: Icon(Icons.table_rows, color: Colors.white),
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.BUCK_MESSAGE_EXCEL);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.SETTINGS);
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              final sessionProvider = Provider.of<SessionManagerProvider>(
                context,
                listen: false,
              );
              final homeProvider = Provider.of<HomeProvider>(
                context,
                listen: false,
              );

              final sessionIds = sessionProvider.availableSessions;

              for (final sessionId in sessionIds) {
                final sessionName = sessionId.replaceAll(
                  RegExp(r'^.*(?=session\d)'),
                  '',
                );

                try {
                  await homeProvider.logout(context, sessionName);
                  sessionProvider.removeSession(sessionId);
                } catch (e) {
                  debugPrint('Erro ao desconectar $sessionName: $e');
                }
              }

              Navigator.of(context).pop(); // ou outra rota final
            },
          ),
        ],
      ),
    );
  }
}
