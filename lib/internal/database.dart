import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dimiplan/internal/model.dart';
import 'package:intl/intl.dart';

DatabaseHelper db = DatabaseHelper();

class DatabaseHelper {
  String? _session;
  static const String backend = "dimigo.co.kr:3000";
  final DateFormat _dateFormatter = DateFormat.yMd('ko_KR');

  Future<String?> get session async {
    var prefs = await SharedPreferences.getInstance();
    _session ??= await prefs.getString('session');
    return _session;
  }

  Future<List<Task>> getTaskList(DateTime date) async {
    var session = await this.session;
    if (session == null) {
      return [];
    }
    String cdate = _dateFormatter.format(date);
    var url = Uri.https(backend, '/getTasks?date=${cdate}');
    var response = await http.get(
      url,
      headers: {'cookie': "connect.sid=${session}"},
    );
    print(response.body);
    if (response.statusCode == 200) {
      return [];
    } else {
      return [];
    }
  }

  Future<void> insertTask(Task task) async {
    var session = await this.session;
    if (session == null) {
      return null;
    }
    var url = Uri.https(backend, '/addTask');
    var data = {task.content, task.date, task.priority};
    var response = await http.post(
      url,
      body: data,
      headers: {'cookie': session},
    );
    if (response.statusCode == 200) {
      print(response.body);
      return null;
    } else {
      return null;
    }
  }

  Future<void> updateTask(Task task) async {
    var session = await this.session;
    if (session == null) {
      return null;
    }
    var url = Uri.https(backend, '/updateTask');
    var data = {task.content, task.date, task.priority};
    var response = await http.put(
      url,
      body: data,
      headers: {'cookie': session},
    );
    if (response.statusCode == 200) {
      print(response.body);
      return null;
    } else {
      return null;
    }
  }

  Future<void> deleteTask(int id) async {
    var session = await this.session;
    if (session == null) {
      return null;
    }
    var url = Uri.https(backend, '/deleteTask?id=${id}');
    var response = await http.delete(url, headers: {'cookie': session});
    if (response.statusCode == 200) {
      print(response.body);
      return null;
    } else {
      return null;
    }
  }

  Future<void> deleteAllTask() async {
    var session = await this.session;
    if (session == null) {
      return null;
    }
    var url = Uri.https(backend, '/deleteAllTask');
    var response = await http.delete(url, headers: {'cookie': session});
    if (response.statusCode == 200) {
      print(response.body);
      return null;
    } else {
      return null;
    }
  }
}
