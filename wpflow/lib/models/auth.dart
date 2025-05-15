import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _email;
  String? _uid;
  DateTime? _expiryDate;

  bool get isAuth {
    final isValid = _expiryDate?.isAfter(DateTime.now()) ?? false;
    return _token != null && isValid;
  }

  String? get token {
    return isAuth ? _token : null;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  String? get uid {
    return isAuth ? _uid : null;
  }

  Future<void> _authenticate(String email, String password, String urlFragment,
      Function(String) onUserIdReceived) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlFragment?key=AIzaSyBEfYuZ7av3wOyPAPcfs6VtZlVUpYd_0sc';
    final response = await http
        .post(
      Uri.parse(url),
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    )
        .timeout(Duration(seconds: 10), onTimeout: () {
      throw AuthException('A requisição demorou muito. Tente novamente.');
    });

    final body = jsonDecode(response.body);

    if (body['error'] != null && body['error']['message'] != null) {
      throw AuthException(body['error']['message']);
    } else {
      _token = body['idToken'];
      _email = body['email'];
      _uid = body['localId'];

      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(body['expiresIn']),
        ),
      );
      onUserIdReceived(_uid!);

      notifyListeners();
    }
  }

  Future<void> signup(
      String email, String password, Function(String) onUserIdReceived) async {
    return _authenticate(email, password, 'signUp', onUserIdReceived);
  }

  Future<void> login(
      String email, String password, Function(String) onUserIdReceived) async {
    return _authenticate(
        email, password, 'signInWithPassword', onUserIdReceived);
  }

  Future<void> resetPassword(String email) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyBEfYuZ7av3wOyPAPcfs6VtZlVUpYd_0sc';
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        'requestType': 'PASSWORD_RESET',
        'email': email,
      }),
    );

    final body = jsonDecode(response.body);

    if (body['error'] != null && body['error']['message'] != null) {
      throw AuthException(body['error']['message']);
    }
  }
}
