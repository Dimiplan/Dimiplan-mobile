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
  String get get => '$_base/get';
  String get registered => '$_base/registered';
  String get update => '$_base/update';
}

class TaskPaths {
  const TaskPaths();
  final String _base = '/api/task';
  String get get => '$_base/get';
  String get add => '$_base/add';
  String get update => '$_base/update';
  String get delete => '$_base/delete';
}

class PlannerPaths {
  const PlannerPaths();
  final String _base = '/api/planner';
  String get getEveryPlanners => '$_base/getPlanners';
  String get getInfo => '$_base/getInfo';
  String get add => '$_base/add';
  String get rename => '$_base/rename';
  String get delete => '$_base/delete';
}

class AiPaths {
  const AiPaths();
  final String _base = '/api/ai';
  String get auto => '$_base/auto';
  String get getRoomList => '$_base/getRoomList';
  String get getChatInRoom => '$_base/getChatInRoom';
  String get addRoom => '$_base/addRoom';
}
