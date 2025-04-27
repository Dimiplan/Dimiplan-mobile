import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:dimiplan/internal/model.dart';
import 'package:dimiplan/views/edit_profile.dart';

class Account extends StatefulWidget {
  const Account({super.key});
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String session = '';
  static const String backend = "dimigo.co.kr:3000";
  User? user;

  @override
  void initState() {
    super.initState();
    checkLogin();
    getUser();
  }

  void checkLogin() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      session = prefs.getString('session') ?? '';
    });
    if (session == '') {
      setState(() async {
        session = await login() ?? '';
      });
      prefs.setString('session', session);
    } else {
      var api = Uri.https(backend, '/api/user/registered');
      var response = await http.get(api, headers: {'X-Session-ID': session});
      if (response.statusCode == 200) {
        return;
      } else {
        setState(() async {
          session = await login() ?? '';
        });
        prefs.setString('session', session);
      }
    }
  }

  Future<String?> login() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();
    if (googleUser == null) {
      googleUser = await GoogleSignIn().signIn();
    }

    if (googleUser == null) {
      return null;
    }

    var api = Uri.https(backend, '/auth/login');
    Map<String, dynamic> body = {'userId': googleUser.id};
    String jsonBody = json.encode(body);

    var response = await http.post(
      api,
      body: jsonBody,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        // Parse the response body to get the session ID
        Map<String, dynamic> responseBody = json.decode(response.body);
        String? sessionId = responseBody['sessionId'];

        if (sessionId != null) {
          return sessionId;
        } else {
          print("No sessionId in response");
        }
      } catch (e) {
        print("Error parsing response: $e");
      }
    }

    return null;
  }

  Future<void> getUser() async {
    var api = Uri.https(backend, '/api/user/whoami');

    var response = await http.get(api, headers: {'X-Session-ID': session});
    if (response.statusCode == 200) {
      try {
        setState(() => user = User.fromMap(json.decode(response.body)));
        return;
      } catch (e) {
        print("Error parsing response: $e");
      }
    }
    print("No user data in response");
    return null;
  }

  void logout() {
    setState(() => session = '');
  }

  @override
  Widget build(BuildContext context) {
    checkLogin();
    getUser();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      user!.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    user!.grade != null && user!.classnum != null
                        ? Text(
                          "${user!.grade}학년 ${user!.classnum}반",
                          style: Theme.of(context).textTheme.headlineSmall,
                        )
                        : SizedBox.shrink(),
                  ],
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  onPressed: logout,
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 15.0),
            ),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => EditProfileScreen(
                          updateUserInfo: getUser,
                          user: user!,
                        ),
                  ),
                ),
            child: Text(
              '회원정보 수정',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
