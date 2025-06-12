/// 채팅방 모델
class ChatRoom {

  const ChatRoom({required this.id, required this.name, required this.owner});

  /// Map에서 ChatRoom 객체 생성
  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      owner: map['owner'] ?? '',
    );
  }
  final int id;
  final String name;
  final String owner;

  /// ChatRoom 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'owner': owner};
  }

  /// 이름이 변경된 새 객체 생성
  ChatRoom copyWith({String? name}) {
    return ChatRoom(id: id, name: name ?? this.name, owner: owner);
  }
}

/// 채팅 메시지 모델
class ChatMessage {

  const ChatMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.from,
    required this.owner,
  });

  /// Map에서 ChatMessage 객체 생성
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? 0,
      message: map['message'] ?? '',
      sender: map['sender'] ?? '',
      from: map['from'] ?? 0,
      owner: map['owner'] ?? '',
    );
  }
  final int id;
  final String message;
  final String sender; // 'user' 또는 'ai'
  final int from; // 채팅방 ID
  final String owner;

  /// ChatMessage 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'from': from,
      'owner': owner,
    };
  }

  /// 사용자 메시지인지 확인
  bool get isUser => sender == 'user';
}
