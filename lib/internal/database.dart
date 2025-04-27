import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dimiplan/internal/model.dart';
import 'dart:convert';

DatabaseHelper db = DatabaseHelper();

class DatabaseHelper {
  static const String backend = "dimigo.co.kr:3000";

  Future<String> getSession() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('session') ?? '';
  }

  Future<List<Task>> getTaskList() async {
    var session = await getSession();
    if (session == '') {
      return [];
    }
    var url = Uri.https(backend, '/api/plan/getEveryPlan');
    var response = await http.get(url, headers: {'X-Session-ID': session});
    if (response.statusCode == 200) {
      var j = json.decode(response.body);
      var tasks = <Task>[];
      for (var task in j) {
        tasks.add(Task.fromMap(task));
      }
      return tasks;
    } else {
      return [];
    }
  }

  Future<void> insertTask(Task task) async {
    var session = await getSession();
    if (session == '') {
      return null;
    }
    var url = Uri.https(backend, '/api/plan/addPlan');
    var taskMap = task.toMap();
    await http.post(
      url,
      body: json.encode(taskMap),
      headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
    );
    return;
  }

  Future<void> updateTask(Task task) async {
    var session = await getSession();
    if (session == '') {
      return null;
    }
    var url = Uri.https(backend, '/api/plan/updatePlan');
    var taskMap = task.toMap();
    await http.post(
      url,
      body: json.encode(taskMap),
      headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
    );
    return;
  }

  Future<void> deleteTask(int id) async {
    var session = await getSession();
    if (session == '') {
      return null;
    }
    var url = Uri.https(backend, '/api/plan/deletePlan');
    await http.post(
      url,
      body: json.encode({'id': id}),
      headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
    );
    return;
  }

  Future<void> updateUser(User user) async {
    var session = await getSession();
    if (session == '') {
      return null;
    }
    var url = Uri.https(backend, '/api/user/updateme');
    var userMap = user.toMap();
    await http.post(
      url,
      body: json.encode(userMap),
      headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
    );
    return;
  }
}
