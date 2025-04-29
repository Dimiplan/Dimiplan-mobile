import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dimiplan/models/planner_models.dart';
import 'package:dimiplan/constants/api_constants.dart';

class PlannerProvider extends ChangeNotifier {
  List<Planner> _planners = [];
  List<Task> _tasks = [];
  Planner? _selectedPlanner;
  bool _isLoading = false;

  // 게터
  List<Planner> get planners => _planners;
  List<Task> get tasks => _tasks;
  Planner? get selectedPlanner => _selectedPlanner;
  bool get isLoading => _isLoading;

  /// 세션 ID 가져오기
  Future<String> _getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session') ?? '';
  }

  /// 플래너 목록 로드
  Future<void> loadPlanners() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        _planners = [];
        _setLoading(false);
        return;
      }

      // 루트 폴더가 없는 경우 자동 생성
      await http.post(
        Uri.https(ApiConstants.backendHost, ApiConstants.createRootFolderPath),
        headers: {'X-Session-ID': session},
      );

      // 루트 폴더(id=0)의 플래너 목록 가져오기
      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.getPlannersInFolderPath,
        {'id': '0'},
      );

      final response = await http.get(url, headers: {'X-Session-ID': session});

      if (response.statusCode == ApiConstants.success) {
        final data = json.decode(response.body);
        final List<Planner> loadedPlanners = [];

        for (var planner in data) {
          loadedPlanners.add(Planner.fromMap(planner));
        }

        _planners = loadedPlanners;

        // 플래너가 있고 선택된 플래너가 없을 경우 첫 번째 플래너 선택
        if (_planners.isNotEmpty && _selectedPlanner == null) {
          _selectedPlanner = _planners[0];
          await loadTasks();
        }

        notifyListeners();
      } else {
        print('플래너 목록 가져오기 실패: ${response.statusCode}');
        _planners = [];
      }
    } catch (e) {
      print('플래너 목록 로드 중 오류 발생: $e');
      _planners = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectPlanner(Planner planner) async {
    // 이미 같은 플래너가 선택된 경우 중복 처리 방지
    if (_selectedPlanner?.id == planner.id) return;

    _selectedPlanner = planner;

    // 상태 업데이트 후 작업 로드 (별도 함수로 분리)
    notifyListeners();

    // 작업 로드는 별도로 실행
    await _loadTasksForPlanner(planner.id);
  }

  // 작업 로드 메서드 (내부용)
  Future<void> _loadTasksForPlanner(int plannerId) async {
    if (_selectedPlanner == null || _isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        _tasks = [];
        _setLoading(false);
        return;
      }

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.getPlanInPlannerPath,
        {'id': _selectedPlanner!.id.toString()},
      );

      final response = await http.get(url, headers: {'X-Session-ID': session});

      if (response.statusCode == ApiConstants.success) {
        final data = json.decode(response.body);
        final List<Task> loadedTasks = [];

        for (var task in data) {
          loadedTasks.add(Task.fromMap(task));
        }

        _tasks = loadedTasks;
        notifyListeners();
      } else {
        print('작업 목록 가져오기 실패: ${response.statusCode}');
        _tasks = [];
        notifyListeners();
      }
    } catch (e) {
      print('작업 목록 로드 중 오류 발생: $e');
      _tasks = [];
      notifyListeners(); // 에러 발생 시에도 갱신
    } finally {
      _setLoading(false);
    }
  }

  // 작업 목록 로드 (공개 API)
  Future<void> loadTasks() async {
    if (_selectedPlanner == null) return;
    await _loadTasksForPlanner(_selectedPlanner!.id);
  }

  /// 플래너 생성
  Future<void> createPlanner(
    String name, {
    int isDaily = 0,
    int folderId = 0,
  }) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.addPlannerPath,
      );
      final response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'isDaily': isDaily, 'from': folderId}),
      );

      if (response.statusCode == ApiConstants.created) {
        // 플래너 목록 새로고침
        await loadPlanners();
        await loadTasks();
      } else {
        throw Exception('플래너 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('플래너 생성 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 폴더 생성
  Future<void> createFolder(String name, {int parentFolderId = 0}) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.addFolderPath,
      );
      final response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'from': parentFolderId}),
      );

      if (response.statusCode == ApiConstants.created) {
        // 폴더 목록 새로고침
        await loadPlanners();
        await loadTasks();
      } else {
        throw Exception('폴더 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('폴더 생성 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 작업 추가
  Future<void> addTask(Task task) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(ApiConstants.backendHost, ApiConstants.addPlanPath);
      final response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode(task.toMap()),
      );

      if (response.statusCode == ApiConstants.created) {
        // 작업 목록 새로고침
        await loadTasks();
      } else {
        throw Exception('작업 추가 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('작업 추가 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 작업 업데이트
  Future<void> updateTask(Task task) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.updatePlanPath,
      );
      final response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode(task.toMap()),
      );

      if (response.statusCode == ApiConstants.success) {
        // 작업 목록 새로고침
        await loadTasks();
      } else {
        throw Exception('작업 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('작업 업데이트 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 작업 삭제
  Future<void> deleteTask(int id) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.deletePlanPath,
      );
      final response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      if (response.statusCode == ApiConstants.success) {
        // 작업 목록 새로고침
        await loadTasks();
      } else {
        throw Exception('작업 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('작업 삭제 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 플래너 이름 변경
  Future<void> renamePlanner(int id, String newName) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.renamePlannerPath,
      );
      final response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'name': newName}),
      );

      if (response.statusCode == ApiConstants.success) {
        // 플래너 목록 새로고침
        await loadPlanners();
        await loadTasks();
      } else {
        throw Exception('플래너 이름 변경 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('플래너 이름 변경 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 플래너 삭제
  Future<void> deletePlanner(int id) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session = await _getSession();
      if (session.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.deletePlannerPath,
      );
      final response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      if (response.statusCode == ApiConstants.success) {
        // 플래너 목록 새로고침
        await loadPlanners();
        await loadTasks();
      } else {
        throw Exception('플래너 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('플래너 삭제 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
