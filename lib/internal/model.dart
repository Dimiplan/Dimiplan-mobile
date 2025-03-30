class Task {
  int? id;
  String title;
  DateTime date;
  String priority;
  bool status; // true : processing, false : finished

  Task({this.id, required this.title, required this.date, required this.priority, this.status=true});
}