import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authinticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCQhCdIRv2fiwi0-MvZY7vQFgHD0CTGDDg';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else {
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      }
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();

      final userData = json.encode({
        'userToken': _token,
        'userId': userId,
        'expiryDate': _expiryDate,
      });

      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signup(String email, String password) async {
    _authinticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    _authinticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    _authTimer = Timer(
        Duration(seconds: _expiryDate.difference(DateTime.now()).inSeconds),
        logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = prefs.get('userData');
    json.decode(extractedUserData) as Map<String, dynamic>;
    final expiryData = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryData.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['userToken'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryData;
    notifyListeners();
    _autoLogout();
    return true;
  }
}
