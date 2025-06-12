import 'package:flutter/material.dart';
import '../utils/app-routes.dart';

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
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
