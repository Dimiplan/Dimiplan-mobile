import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

class Account extends StatefulWidget {
  const Account({super.key});
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String? session;
  static const String backend = "dimigo.co.kr:3000";

  void checkLogin() async {
    var prefs = await SharedPreferences.getInstance();
    session = prefs.getString('session');
    if (session == null || session == '') {
      prefs.setString('session', await login() ?? '');
    } else {
      var api = Uri.https(backend, '/api/user/registered');
      var response = await http.get(api, headers: {'cookie': session!});
      if (response.statusCode == 200) {
        return;
      } else {
        prefs.setString('session', await login() ?? '');
        session = prefs.getString('session');
      }
    }
  }

  Future<String?> login() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();
    if (googleUser == null) {
      googleUser = await GoogleSignIn().signIn();
    }
    var api = Uri.https(backend, '/auth/login');
    Map<String, dynamic> body = {'userId': googleUser?.id};
    String jsonBody = json.encode(body);
    var response = await http.post(
      api,
      body: jsonBody,
      headers: {'Content-Type': 'application/json'},
    );
    return response.headers['set-cookie'];
  }

  @override
  Widget build(BuildContext context) {
    checkLogin();
    return MaterialApp();
  }
}
