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

  Future<List<Planner>> getPlanners() async {
    var session = await getSession();
    if (session == '') {
      return [];
    }
    await http.post(
      Uri.https(backend, '/api/plan/createRootFolder'),
      headers: {'X-Session-ID': session},
    );

    // Get planners from root folder (id=0)
    var url = Uri.https(backend, '/api/plan/getPlannersInFolder', {'id': '0'});
    var response = await http.get(url, headers: {'X-Session-ID': session});

    if (response.statusCode == 200) {
      var j = json.decode(response.body);
      var planners = <Planner>[];
      for (var planner in j) {
        planners.add(Planner.fromMap(planner));
      }
      return planners;
    } else {
      return [];
    }
  }

  Future<List<Task>> getTasksForPlanner(int plannerId) async {
    var session = await getSession();
    if (session == '') {
      return [];
    }
    var url = Uri.https(backend, '/api/plan/getPlanInPlanner', {
      'id': plannerId.toString(),
    });
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

  Future<void> addPlanner(String name, int isDaily, int folderId) async {
    var session = await getSession();
    if (session == '') {
      return null;
    }
    var url = Uri.https(backend, '/api/plan/addPlanner');
    var plannerData = {'name': name, 'isDaily': isDaily, 'from': folderId};

    var response = await http.post(
      url,
      body: json.encode(plannerData),
      headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add planner: ${response.statusCode}');
    }

    return;
  }
}
