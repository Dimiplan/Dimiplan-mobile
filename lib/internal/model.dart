class Task {
  int id;
  String title;
  DateTime date;
  String priority;
  bool status; // true : processing, false : finished

  Task({required this.id, required this.title, required this.date, required this.priority, required this.status});
}