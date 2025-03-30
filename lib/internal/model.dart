class Task {
  int? id;
  String title;
  DateTime date;
  String priority;
  bool status; // true : processing, false : finished

  Task({this.id, required this.title, required this.date, required this.priority, this.status=true});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      status: map['status'],
    );
  }
}