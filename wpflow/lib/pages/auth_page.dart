import 'package:flutter/material.dart';
import '../components/auth_form.dart';
import '../components/custom_app_bar.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: deviceSize.height * 0.05),
                Container(
                  width: deviceSize.width * 0.6,
                  child: Image.asset(
                    'lib/assets/img/logo/wpFlow.png',
                    height: deviceSize.height * 0.2,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: deviceSize.height * 0.03),
                AuthForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
