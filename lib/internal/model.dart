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
    map['date'] = [date.year, date.month, date.day];
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      date: DateTime(map['date'][0], map['date'][1], map['date'][2]),
      priority: map['priority'],
      status: map['status'],
    );
  }
}