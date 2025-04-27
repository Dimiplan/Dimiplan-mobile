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
  bool userLogout = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    if (userLogout) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var prefs = await SharedPreferences.getInstance();
      String storedSession = prefs.getString('session') ?? '';

      setState(() {
        session = storedSession;
      });

      if (session == '') {
        // Need to perform login
        String? newSession = await login();
        if (newSession != null && newSession.isNotEmpty) {
          setState(() {
            session = newSession;
          });
          await prefs.setString('session', newSession);
          await getUser(); // Fetch user data after getting session
        }
        var api = Uri.https(backend, '/api/user/registered');
        var response = await http.get(api, headers: {'X-Session-ID': session});
        if (response.statusCode != 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      EditProfileScreen(updateUserInfo: getUser, user: user!),
            ),
          );
        }
      } else {
        // Verify existing session
        var api = Uri.https(backend, '/api/user/registered');
        var response = await http.get(api, headers: {'X-Session-ID': session});
        if (response.statusCode != 200) {
          // Session invalid, need new login
          String? newSession = await login();
          if (newSession != null && newSession.isNotEmpty) {
            setState(() {
              session = newSession;
            });
            await prefs.setString('session', newSession);
          }
          var api = Uri.https(backend, '/api/user/registered');
          var response = await http.get(
            api,
            headers: {'X-Session-ID': session},
          );
          if (response.statusCode != 200) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        EditProfileScreen(updateUserInfo: getUser, user: user!),
              ),
            );
          }
        }
        await getUser(); // Fetch user data regardless
      }
    } catch (e) {
      print("Error during login check: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> login() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => userLogout = true);
        return null;
      }

      var api = Uri.https(backend, '/auth/login');
      Map<String, dynamic> body = {
        'userId': googleUser.id,
        'email': googleUser.email,
        'photo': googleUser.photoUrl,
        'name': googleUser.displayName,
      };
      String jsonBody = json.encode(body);

      var response = await http.post(
        api,
        body: jsonBody,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['sessionId'];
      } else {
        print("Login failed with status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error during login: $e");
    }
    return null;
  }

  Future<void> getUser() async {
    if (session.isEmpty) {
      print("Cannot fetch user: No session available");
      return;
    }

    try {
      var api = Uri.https(backend, '/api/user/whoami');
      var response = await http.get(api, headers: {'X-Session-ID': session});

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        print(userData);
        setState(() => user = User.fromMap(userData));
      } else {
        var prefs = await SharedPreferences.getInstance();
        await prefs.remove('session');
        setState(() {
          session = '';
          user = null;
          userLogout = true;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void logout() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');
    setState(() {
      session = '';
      user = null;
      userLogout = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (!userLogout && user != null) {
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
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              '로그인이 필요합니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
              ),
              onPressed: () async {
                setState(() {
                  userLogout = false;
                  isLoading = true;
                });
                await checkLogin();
                setState(() {
                  isLoading = false;
                });
              },
              child: Text(
                '로그인',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
