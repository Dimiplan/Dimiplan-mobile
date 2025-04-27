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

class User {
  String id;
  String name;
  int? grade;
  int? classnum;
  String email;
  String profile_image;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.grade,
    this.classnum,
    required this.profile_image,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['name'] = name;
    if (grade != null) {
      map['grade'] = grade;
    }
    if (classnum != null) {
      map['class'] = classnum;
    }
    map['profile_image'] = profile_image;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      grade: map['grade'],
      classnum: map['class'],
      profile_image: map['profile_image'],
    );
  }
}
