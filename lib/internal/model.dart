class Task {
  int? id;
  String contents;
  int priority;
  int from;
  int isCompleted; // true : processing, false : finished

  Task({
    this.id,
    required this.contents,
    required this.priority,
    required this.from,
    this.isCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['contents'] = contents;
    map['priority'] = priority;
    map['from'] = from;
    map['isCompleted'] = isCompleted;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      contents: map['contents'],
      priority: map['priority'],
      from: map['from'],
      isCompleted: map['isCompleted'],
    );
  }
}
