class Task {
  int? id;
  String contents;
  int priority;
  int isCompleted; // true : processing, false : finished

  Task({
    this.id,
    required this.contents,
    required this.priority,
    this.isCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['contents'] = contents;
    map['priority'] = priority;
    map['isCompleted'] = isCompleted;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      contents: map['contents'],
      priority: map['priority'],
      isCompleted: map['isCompleted'],
    );
  }
}
