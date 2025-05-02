/// API 관련 상수
class ApiConstants {
  /// 백엔드 서버 호스트
  static const String backendHost = "https://dimigo.co.kr:3000";

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
  static const String planPath = "/api/plan";
  static const String aiPath = "/api/ai";

  /// 로그인 API
  static const String loginPath = "$authPath/login";
  static const String logoutPath = "$authPath/logout";

  /// 사용자 API
  static const String whoamiPath = "$userPath/whoami";
  static const String registeredPath = "$userPath/registered";
  static const String updateUserPath = "$userPath/updateme";

  /// 플래너 API
  static const String createRootFolderPath = "$planPath/createRootFolder";
  static const String getPlannersInFolderPath = "$planPath/getPlannersInFolder";
  static const String getPlannerInfoPath = "$planPath/getPlannerInfoByID";
  static const String getPlanInPlannerPath = "$planPath/getPlanInPlanner";
  static const String getAllPlansPath = "$planPath/getEveryPlan";
  static const String addPlannerPath = "$planPath/addPlanner";
  static const String renamePlannerPath = "$planPath/renamePlanner";
  static const String deletePlannerPath = "$planPath/deletePlanner";
  static const String addFolderPath = "$planPath/addFolder";
  static const String addPlanPath = "$planPath/addPlan";
  static const String updatePlanPath = "$planPath/updatePlan";
  static const String deletePlanPath = "$planPath/deletePlan";

  /// AI API
  static const String gpt4oMiniPath = "$aiPath/gpt4o-mini";
  static const String gpt4oPath = "$aiPath/gpt4o";
  static const String gpt41Path = "$aiPath/gpt41";
  static const String getRoomListPath = "$aiPath/getRoomList";
  static const String getChatInRoomPath = "$aiPath/getChatInRoom";
  static const String addRoomPath = "$aiPath/addRoom";
}
