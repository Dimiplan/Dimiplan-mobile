import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter_web/webview_flutter_web.dart';

class Account extends StatefulWidget{
  const Account({super.key});
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account>{
  String? sessionId;
  static const String backend = "dimigo.co.kr:3000";

  void checkLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionId = prefs.getString('session_id');
    if(sessionId==null){
      prefs.setString('session_id', login());
    }
    else{
      var api = Uri.https(backend, '/api/user/registered');
      var response = await http.get(api, headers: {'cookie' : "session.id=${sessionId!}"});
      if(response.statusCode == 200){
        return;
      }
      else{
        prefs.setString('session_id', login());
      }
    }
  }

  String login(){
    // TODO create login
    return '';
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp();
  }
}