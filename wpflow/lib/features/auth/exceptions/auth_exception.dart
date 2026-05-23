class AuthException implements Exception {
  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'Endereço de e-mail já cadastrado.',
    'OPERATION_NOT_ALLOWED': 'Operação não permitida!',
    'TOO_MANY_ATTEMPTS_TRY_LATER':
        'Acesso bloqueado temporariamente, Tente novamente mais tarde',
    'EMAIL_NOT_FOUND': 'Email não encontrado',
    'INVALID_LOGIN_CREDENTIALS': 'Usuário ou senha incorretos.',
    'USER_DISABLED': 'A conta do uduário foi desabilitada',
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? 'Ocorreu um erro no processo de autenticação';
  }
}
