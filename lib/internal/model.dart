class Task {
  int? seq;
  String content;
  DateTime date;
  int priority;
  bool status; // true : processing, false : finished

  Task({
    this.seq,
    required this.content,
    required this.date,
    required this.priority,
    this.status = true,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (seq != null) {
      map['seq'] = seq;
    }
    map['content'] = content;
    map['date'] = [date.year, date.month, date.day];
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      seq: map['seq'],
      content: map['content'],
      date: DateTime(map['date'][0], map['date'][1], map['date'][2]),
      priority: map['priority'],
      status: map['status'],
    );
  }
}
