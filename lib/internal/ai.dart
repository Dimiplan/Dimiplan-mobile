import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// AI service class to handle all AI related API calls
class AIService {
  static const String backend = "dimigo.co.kr:3000";

  Future<String> getSession() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('session') ?? '';
  }

  // Model for Chat Room
  Future<List<ChatRoom>> getChatRooms() async {
    var session = await getSession();
    if (session == '') {
      return [];
    }

    try {
      var url = Uri.https(backend, '/api/ai/getRoomList');
      var response = await http.get(url, headers: {'X-Session-ID': session});

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var rooms = <ChatRoom>[];
        for (var room in data['roomData']) {
          rooms.add(ChatRoom.fromMap(room));
        }
        return rooms;
      } else {
        print('Failed to get chat rooms: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return [];
    }
  }

  // Create a new chat room
  Future<bool> createChatRoom(String name) async {
    var session = await getSession();
    if (session == '') {
      return false;
    }

    try {
      var url = Uri.https(backend, '/api/ai/addRoom');
      var response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error creating chat room: $e');
      return false;
    }
  }

  // Get messages from a chat room
  Future<List<ChatMessage>> getChatMessages(int roomId) async {
    var session = await getSession();
    if (session == '') {
      return [];
    }

    try {
      var url = Uri.https(backend, '/api/ai/getChatInRoom', {
        'from': roomId.toString(),
      });
      var response = await http.get(url, headers: {'X-Session-ID': session});

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var messages = <ChatMessage>[];
        for (var message in data['chatData']) {
          messages.add(ChatMessage.fromMap(message));
        }
        return messages;
      } else {
        print('Failed to get chat messages: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching chat messages: $e');
      return [];
    }
  }

  // Send a message to the AI (using GPT-4o-mini)
  Future<Map<String, dynamic>?> sendMessage(String message, int roomId) async {
    var session = await getSession();
    if (session == '') {
      return null;
    }

    try {
      var url = Uri.https(backend, '/api/ai/gpt4o-mini');
      var response = await http.post(
        url,
        headers: {'X-Session-ID': session, 'Content-Type': 'application/json'},
        body: json.encode({'prompt': message, 'room': roomId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to send message: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
}

// Model for Chat Room
class ChatRoom {
  final int id;
  final String name;
  final String owner;

  ChatRoom({required this.id, required this.name, required this.owner});

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(id: map['id'], name: map['name'], owner: map['owner']);
  }
}

// Model for Chat Message
class ChatMessage {
  final int id;
  final String message;
  final String sender; // 'user' or 'ai'
  final int from; // room id
  final String owner;

  ChatMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.from,
    required this.owner,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      message: map['message'],
      sender: map['sender'],
      from: map['from'],
      owner: map['owner'],
    );
  }

  bool get isUser => sender == 'user';
}
