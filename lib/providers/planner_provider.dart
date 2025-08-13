import 'package:flutter/material.dart';
import 'package:dimiplan/providers/http_provider.dart';
import 'package:dimiplan/models/planner_models.dart';
import 'package:dimiplan/utils/state_utils.dart';
import 'package:dimiplan/utils/api_utils.dart';
import 'package:dimiplan/constants/api_constants.dart';

class PlannerProvider extends ChangeNotifier with LoadingStateMixin {
  List<Planner> _planners = [];
  List<Task> _tasks = [];
  Planner? _selectedPlanner;

  // 게터
  List<Planner> get planners => _planners;
  List<Task> get tasks => _tasks;
  Planner? get selectedPlanner => _selectedPlanner;

  /// 플래너 목록 로드
  Future<void> loadPlanners() async {
    if (isLoading) return;

    await AsyncOperationHandler.execute(
      operation: () async {
        final isSessionValid = await httpClient.isSessionValid();
        if (!isSessionValid) {
          _planners = [];
          return;
        }

        final data = await ApiUtils.fetchData(
          ApiConstants.planner.list,
        );
        if (data != null) {
          final loadedPlanners =
              (data as List)
                  .map((plannerData) => Planner.fromMap(plannerData))
                  .toList();

          _planners = loadedPlanners;

          if (_planners.isNotEmpty && _selectedPlanner == null) {
            await selectPlanner(_planners.first);
          } else if (_selectedPlanner != null &&
              !_planners.any((p) => p.id == _selectedPlanner!.id)) {
            if (_planners.isNotEmpty) {
              await selectPlanner(_planners.first);
            } else {
              _selectedPlanner = null;
              _tasks = [];
            }
          }
        } else {
          _planners = [];
        }
      },
      setLoading: setLoading,
      errorContext: '플래너 목록 로드',
      onError: (_) {
        _planners = [];
      },
    );
    safeNotifyListeners();
  }

  /// 플래너 선택
  Future<void> selectPlanner(Planner planner) async {
    // 이미 같은 플래너가 선택된 경우 중복 처리 방지
    if (_selectedPlanner?.id == planner.id) {
      // 데이터 새로고침만 수행
      await loadTasks();
      return;
    }

    _selectedPlanner = planner;
    notifyListeners();

    // 작업 로드
    await _loadTasksForPlanner(planner.id);
  }

  // 작업 로드 메서드 (내부용)
  Future<void> _loadTasksForPlanner(int plannerId) async {
    if (_selectedPlanner == null || isLoading) return;

    await AsyncOperationHandler.execute(
      operation: () async {
        final isSessionValid = await httpClient.isSessionValid();
        if (!isSessionValid) {
          _tasks = [];
          return;
        }

        final data = await ApiUtils.fetchData(
          ApiConstants.planner.tasks(_selectedPlanner!.id.toString()),
        );
        if (data != null) {
          final loadedTasks =
              (data as List).map((taskData) => Task.fromMap(taskData)).toList();

          _tasks = loadedTasks;
        } else {
          _tasks = [];
        }
      },
      setLoading: setLoading,
      errorContext: '작업 목록 로드',
      onError: (_) {
        _tasks = [];
      },
    );
    safeNotifyListeners();
  }

  // 작업 목록 로드 (공개 API)
  Future<void> loadTasks() async {
    if (_selectedPlanner == null) return;
    await _loadTasksForPlanner(_selectedPlanner!.id);
  }

  /// 전체 데이터 새로고침
  Future<void> refreshAll() async {
    await loadPlanners();
    if (_selectedPlanner != null) {
      await loadTasks();
    }
  }

  /// 플래너 생성
  Future<void> createPlanner(String name, {bool isDaily = false}) async {
    await _performPlannerOperation(
      () => ApiUtils.postData(
        ApiConstants.planner.create,
        data: {'name': name, 'isDaily': isDaily},
      ),
      errorContext: '플래너 생성',
    );
  }

  /// 작업 추가
  Future<void> addTask(Task task) async {
    await _performPlannerOperation(
      () => ApiUtils.postData(ApiConstants.task.create, data: task.toMap()),
      errorContext: '작업 추가',
    );
  }

  /// 작업 업데이트
  Future<void> updateTask(Task task) async {
    await _performPlannerOperation(
      () => ApiUtils.patchData(
        ApiConstants.task.update(task.id.toString()),
        data: task.toMap(),
      ),
      errorContext: '작업 업데이트',
    );
  }

  /// 작업 삭제
  Future<void> deleteTask(int id) async {
    await _performPlannerOperation(
      () => ApiUtils.deleteData(ApiConstants.task.delete(id.toString())),
      errorContext: '작업 삭제',
    );
  }

  /// 플래너 이름 변경
  Future<void> renamePlanner(int id, String newName) async {
    await _performPlannerOperation(
      () => ApiUtils.patchData(
        ApiConstants.planner.update(id.toString()),
        data: {'name': newName},
      ),
      errorContext: '플래너 이름 변경',
    );
  }

  /// 플래너 삭제
  Future<void> deletePlanner(int id) async {
    await _performPlannerOperation(
      () => ApiUtils.deleteData(ApiConstants.planner.delete(id.toString())),
      errorContext: '플래너 삭제',
    );
  }

  /// API 작업을 수행하고 성공 시 데이터를 새로고침하는 헬퍼 메소드
  Future<void> _performPlannerOperation(
    Future<dynamic> Function() operation, {
    String? errorContext,
  }) async {
    await AsyncOperationHandler.execute(
      operation: () async {
        final isSessionValid = await httpClient.isSessionValid();
        if (!isSessionValid) throw Exception('로그인이 필요합니다.');
        await operation();
        await refreshAll(); // 작업 성공 후 항상 데이터 새로고침
      },
      setLoading: setLoading,
      errorContext: errorContext,
    );
  }
}
