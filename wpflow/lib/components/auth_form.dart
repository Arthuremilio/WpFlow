import 'package:flutter/material.dart';
import '../exceptions/auth_exception.dart';
import '../models/auth.dart';
import '../models/home_user.dart';
import '../utils/app-routes.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  bool _isLogin() => _authMode == AuthMode.Login;
  bool _isSignup() => _authMode == AuthMode.Signup;
  Map<String, String> _authData = {'email': '', 'password': ''};

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.Signup;
      } else {
        _authMode = AuthMode.Login;
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Ocorreu um erro'),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Fechar'),
              ),
            ],
          ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);
    HomeProvider homeProvider = Provider.of<HomeProvider>(
      context,
      listen: false,
    );
    try {
      if (_isLogin()) {
        await auth.login(_authData['email']!, _authData['password']!, (userId) {
          homeProvider.setUserId(userId);
        });
      } else {
        await auth.signup(_authData['email']!, _authData['password']!, (
          userId,
        ) {
          homeProvider.setUserId(userId);
        });
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.HOMEUSER);
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      print(error);
      _showErrorDialog('Ocorreu um erro inesperado!');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: _isLogin() ? 300 : 360,
          width:
              deviceSize.width > 600
                  ? deviceSize.width * 0.5
                  : deviceSize.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'E-mail',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  onSaved: (email) => _authData['email'] = email ?? '',
                  validator: (_email) {
                    final email = _email ?? '';
                    if (email.trim().isEmpty || !email.contains('@')) {
                      return 'Informe um email válido';
                    }
                    return null;
                  },
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    labelText: 'Senha',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  controller: _passwordController,
                  onSaved: (password) => _authData['password'] = password ?? '',
                  validator: (_password) {
                    final password = _password ?? '';
                    if (password.isEmpty || password.length < 5) {
                      return 'Informe uma senha válida';
                    }
                    return null;
                  },
                ),
                if (_isSignup()) SizedBox(height: 16),
                if (_isSignup())
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Confirmar Senha',
                      labelText: 'Confirmar Senha',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    style: TextStyle(color: Colors.black),
                    obscureText: true,
                  ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Container(
                    width: deviceSize.width * 0.80,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _authMode == AuthMode.Login ? 'Entrar' : 'Registrar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.FORGOT_PASSWORD);
                      },
                      child: Text(
                        'Esqueceu a senha?',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    _isLogin()
                        ? 'Deseja se registrar?'
                        : 'Já possui uma conta?',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.bodyLarge?.color,
                    overlayColor: Colors.transparent,
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
