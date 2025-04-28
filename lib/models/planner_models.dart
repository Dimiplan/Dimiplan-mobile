/// 작업(Task) 모델
class Task {
  final int? id;
  final String contents;
  final int priority;
  final int from; // 플래너 ID
  final int isCompleted; // 0: 진행 중, 1: 완료됨

  const Task({
    this.id,
    required this.contents,
    required this.priority,
    required this.from,
    this.isCompleted = 0,
  });

  /// Map에서 Task 객체 생성
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      contents: map['contents'] ?? '',
      priority: map['priority'] ?? 0,
      from: map['from'] ?? 0,
      isCompleted: map['isCompleted'] ?? 0,
    );
  }

  /// Task 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'contents': contents,
      'priority': priority,
      'from': from,
      'isCompleted': isCompleted,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// 업데이트된 정보로 새 객체 생성
  Task copyWith({
    int? id,
    String? contents,
    int? priority,
    int? from,
    int? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      contents: contents ?? this.contents,
      priority: priority ?? this.priority,
      from: from ?? this.from,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// 플래너 모델
class Planner {
  final int id;
  final String name;
  final int from; // 폴더 ID
  final int isDaily; // 일일 플래너 여부 (0: 일반, 1: 일일)

  const Planner({
    required this.id,
    required this.name,
    required this.from,
    this.isDaily = 0,
  });

  /// Map에서 Planner 객체 생성
  factory Planner.fromMap(Map<String, dynamic> map) {
    return Planner(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      from: map['from'] ?? 0,
      isDaily: map['isDaily'] ?? 0,
    );
  }

  /// Planner 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'from': from, 'isDaily': isDaily};
  }

  /// 업데이트된 정보로 새 객체 생성
  Planner copyWith({String? name, int? isDaily}) {
    return Planner(
      id: id,
      name: name ?? this.name,
      from: from,
      isDaily: isDaily ?? this.isDaily,
    );
  }
}

/// 폴더 모델
class Folder {
  final int id;
  final String name;
  final int from; // 상위 폴더 ID (0: 루트)

  const Folder({required this.id, required this.name, required this.from});

  /// Map에서 Folder 객체 생성
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      from: map['from'] ?? 0,
    );
  }

  /// Folder 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'from': from};
  }
}
