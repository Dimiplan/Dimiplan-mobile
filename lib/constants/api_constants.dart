/// API 관련 상수
class ApiConstants {
  /// 백엔드 서버 호스트 (dev 브랜치에서는 개발 서버 사용)
  static const String backendHost =
      bool.fromEnvironment('DEV_BUILD')
          ? 'api-dev.dimiplan.com'
          : 'api.dimiplan.com';

  /// API 응답 코드
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int serverError = 500;

  /// API 경로
  static const AuthPaths auth = AuthPaths();
  static const UserPaths user = UserPaths();
  static const TaskPaths task = TaskPaths();
  static const PlannerPaths planner = PlannerPaths();
  static const AiPaths ai = AiPaths();
}

class AuthPaths {
  const AuthPaths();
  final String _base = '/auth';
  String get login => '$_base/login';
  String get logout => '$_base/logout';
}

class UserPaths {
  const UserPaths();
  final String _base = '/api/user';
  String get get => _base;
  String get update => _base;
  String get register => '/auth/register';
}

class TaskPaths {
  const TaskPaths();
  final String _base = '/api/tasks';
  String get create => _base;
  String update(String taskId) => '$_base/$taskId';
  String delete(String taskId) => '$_base/$taskId';
}

class PlannerPaths {
  const PlannerPaths();
  final String _base = '/api/planners';
  String get list => _base;
  String get create => _base;
  String info(String plannerId) => '$_base/$plannerId/info';
  String tasks(String plannerId) => '$_base/$plannerId/tasks';
  String update(String plannerId) => '$_base/$plannerId';
  String delete(String plannerId) => '$_base/$plannerId';
}

class AiPaths {
  const AiPaths();
  final String _base = '/api/ai';
  String get models => _base;
  String get auto => '$_base/auto';
  String get custom => '$_base/custom';
  String get rooms => '$_base/rooms';
  String get createRoom => '$_base/rooms';
  String roomMessages(String roomId) => '$_base/rooms/$roomId';
  String updateRoom(String roomId) => '$_base/rooms/$roomId';
  String deleteRoom(String roomId) => '$_base/rooms/$roomId';
}
