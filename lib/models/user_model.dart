/// 사용자 모델
class User {

  const User({
    required this.id,
    required this.name,
    required this.email, required this.profileImage, this.grade,
    this.classnum,
  });

  /// Map에서 User 객체 생성
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      grade: map['grade'],
      classnum: map['class'],
      email: map['email'] ?? '',
      profileImage: map['profile_image'] ?? '',
    );
  }
  final String id;
  final String name;
  final int? grade;
  final int? classnum;
  final String email;
  final String profileImage;

  /// User 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
    };

    if (grade != null) {
      map['grade'] = grade;
    }

    if (classnum != null) {
      map['class'] = classnum;
    }

    return map;
  }

  /// 사용자 정보 업데이트된 새 객체 생성
  User copyWith({
    String? name,
    int? grade,
    int? classnum,
    String? email,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      classnum: classnum ?? this.classnum,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
