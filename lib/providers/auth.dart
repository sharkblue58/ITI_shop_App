import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';
import 'dart:async';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userId;
  Timer? _authTimer;

  bool get isSignedIn {
    return token != "";
  }

  String get userId {
    return _userId == null ? "" : _userId!;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return "";
  }

  Future<void> _authenticate(String email, String password, Uri url) async {
    try {
      final result = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      final data = json.decode(result.body);

      if (data['error'] != null) {
        throw HttpException(data['error']['message']);
      }

      _token = data['idToken'];
      _userId = data['localId'];
      _expireDate =
          DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));

      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': userId,
        'expireDate': _expireDate!.toIso8601String()
      });
      prefs.setString('loginInfo', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('loginInfo')) {
        return false;
      }
      final extractedUserData =
          json.decode(prefs.getString('loginInfo')!) as Map<String, dynamic>;
      final expireDate =
          DateTime.parse(extractedUserData['expireDate'].toString());
      if (expireDate.isBefore(DateTime.now())) {
        print('token expired');
        return false;
      }
      print('token not expired yet');
      _token = extractedUserData['token'].toString();
      _userId = extractedUserData['userId'].toString();
      _expireDate = expireDate;
      notifyListeners();
      autoLogout();
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAwfWVgX_YRwHxdci2FN8qNbZSFO91HgVA");

    return _authenticate(email, password, url);
  }

  Future<void> signin(String email, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAwfWVgX_YRwHxdci2FN8qNbZSFO91HgVA");

    return _authenticate(email, password, url);
  }

  Future<void> logout() async{
    try {
      _token = null;
      _userId = null;
      _expireDate = null;
      if (_authTimer != null) {
        _authTimer!.cancel();
        _authTimer = null;
      }

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      prefs.remove('loginInfo');
    } catch (error) {
      print(error);
    }
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    } else {
      final timeToExpiry = _expireDate!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    }
  }
}
