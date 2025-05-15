import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth.dart';
import '../components/custom_app_bar.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final TextEditingController emailController = TextEditingController();
    final auth = Provider.of<Auth>(context, listen: false);

    Future<void> _resetPassword() async {
      try {
        await auth.resetPassword(emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email de recuperação enviado!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar email: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

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
                Container(
                  width: deviceSize.width * 0.6,
                  child: Image.asset(
                    'lib/assets/img/logo/wpFlow.png',
                    height: deviceSize.height * 0.2,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.7),
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 8,
                    color: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      width:
                          deviceSize.width > 600
                              ? deviceSize.width * 0.5
                              : deviceSize.width * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Título
                          const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Descrição
                          const Text(
                            'Informe seu email abaixo para receber a senha',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          // Formulário
                          Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 16),
                                // Botão
                                Container(
                                  width: deviceSize.width * 0.80,
                                  child: ElevatedButton(
                                    onPressed: _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Enviar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
