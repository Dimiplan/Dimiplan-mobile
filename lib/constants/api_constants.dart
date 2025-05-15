/// API 관련 상수
class ApiConstants {
  /// 백엔드 서버 호스트
  static const String backendHost = "api.dimiplan.com";

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
  static const String authPath = "/auth";
  static const String userPath = "/api/user";
  static const String taskPath = "/api/task";
  static const String plannerPath = "/api/planner";
  static const String folderPath = "/api/folder";
  static const String aiPath = "/api/ai";

  /// 로그인 API
  static const String loginPath = "$authPath/login";
  static const String logoutPath = "$authPath/logout";

  /// 사용자 API
  static const String getUserPath = "$userPath/get";
  static const String registeredPath = "$userPath/registered";
  static const String updateUserPath = "$userPath/update";

  /// 플래너 API
  static const String createRootFolderPath = "$folderPath/createRoot";
  static const String addFolderPath = "$folderPath/add";

  static const String getEveryPlanners = "$plannerPath/getPlanners";
  static const String getPlannerInfoPath = "$plannerPath/getInfo";
  static const String addPlannerPath = "$plannerPath/add";
  static const String renamePlannerPath = "$plannerPath/rename";
  static const String deletePlannerPath = "$plannerPath/delete";

  static const String getTaskPath = "$taskPath/get";
  static const String addTaskPath = "$taskPath/add";
  static const String updateTaskPath = "$taskPath/update";
  static const String deleteTaskPath = "$taskPath/delete";

  /// AI API
  static const String autoAIPath = "$aiPath/auto";
  static const String getRoomListPath = "$aiPath/getRoomList";
  static const String getChatInRoomPath = "$aiPath/getChatInRoom";
  static const String addRoomPath = "$aiPath/addRoom";
}
