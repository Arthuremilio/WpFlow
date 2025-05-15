import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeProvider with ChangeNotifier {
  String? userId;

  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }

}
