import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dimiplan/providers/http_provider.dart';
import 'package:dimiplan/models/chat_models.dart';
import 'package:dimiplan/constants/api_constants.dart';

class AIProvider extends ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  ChatRoom? _selectedRoom;
  bool _isLoading = false;

  // 게터
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  ChatRoom? get selectedChatRoom => _selectedRoom;
  bool get isLoading => _isLoading;

  /// 전체 데이터 새로고침
  Future<void> refreshAll() async {
    await loadChatRooms();
    if (_selectedRoom != null) {
      await loadMessages();
    }
  }

  /// 채팅방 목록 로드
  Future<void> loadChatRooms() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      // 세션 유효성 검사
      final isSessionValid = await Http.isSessionValid();
      if (!isSessionValid) {
        _chatRooms = [];
        _setLoading(false);
        return;
      }

      final url = Uri.https(ApiConstants.backendHost, '/api/ai/getRoomList');
      final response = await Http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rooms = <ChatRoom>[];

        for (var room in data['roomData']) {
          rooms.add(ChatRoom.fromMap(room));
        }

        _chatRooms = rooms;

        // 채팅방이 있으면 첫 번째 채팅방 선택
        if (_chatRooms.isNotEmpty && _selectedRoom == null) {
          selectChatRoom(_chatRooms.first);
        }
        // 선택된 채팅방이 더 이상 존재하지 않는 경우
        else if (_selectedRoom != null &&
            !_chatRooms.any((r) => r.id == _selectedRoom!.id)) {
          if (_chatRooms.isNotEmpty) {
            selectChatRoom(_chatRooms.first);
          } else {
            _selectedRoom = null;
            _messages = [];
          }
        }

        notifyListeners();
      } else {
        print('채팅방 목록 가져오기 실패: ${response.body}');
        _chatRooms = [];
      }
    } catch (e) {
      print('채팅방 목록 로드 중 오류 발생: $e');
      _chatRooms = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 채팅방 생성
  Future<void> createChatRoom(String name) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      // 세션 유효성 검사
      final isSessionValid = await Http.isSessionValid();
      if (!isSessionValid) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(ApiConstants.backendHost, '/api/ai/addRoom');
      final response = await Http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        // 채팅방 목록 새로고침
        await refreshAll();
      } else {
        throw Exception('채팅방 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('채팅방 생성 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 채팅방 선택
  Future<void> selectChatRoom(ChatRoom room) async {
    // 이미 같은 채팅방이 선택된 경우 데이터 새로고침만 수행
    if (_selectedRoom?.id == room.id) {
      await loadMessages();
      return;
    }

    _selectedRoom = room;
    await loadMessages();
    notifyListeners();
  }

  /// 채팅 메시지 로드
  Future<void> loadMessages() async {
    if (_selectedRoom == null || _isLoading) return;

    _setLoading(true);

    try {
      // 세션 유효성 검사
      final isSessionValid = await Http.isSessionValid();
      if (!isSessionValid) {
        _messages = [];
        _setLoading(false);
        return;
      }

      final url = Uri.https(ApiConstants.backendHost, '/api/ai/getChatInRoom', {
        'from': _selectedRoom!.id.toString(),
      });

      final response = await Http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = <ChatMessage>[];

        for (var message in data['chatData']) {
          messages.add(ChatMessage.fromMap(message));
        }

        _messages = messages;
        notifyListeners();
      } else {
        print('채팅 메시지 가져오기 실패: ${response.statusCode}');
        _messages = [];
      }
    } catch (e) {
      print('채팅 메시지 로드 중 오류 발생: $e');
      _messages = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 메시지 전송
  Future<void> sendMessage({
    required String message,
    required String model,
  }) async {
    if (_selectedRoom == null || _isLoading) return;

    _setLoading(true);

    try {
      // 세션 유효성 검사
      final isSessionValid = await Http.isSessionValid();
      if (!isSessionValid) {
        throw Exception('로그인이 필요합니다.');
      }

      // 사용자 메시지 추가 (낙관적 UI 업데이트)
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        message: message,
        sender: 'user',
        from: _selectedRoom!.id,
        owner: '',
      );

      _messages.add(userMessage);
      notifyListeners();

      // API에 따라 AI 모델 엔드포인트 선택
      final endpoint = _getModelEndpoint(model);
      final url = Uri.https(ApiConstants.backendHost, endpoint);

      final response = await Http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': message, 'room': _selectedRoom!.id}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // AI 응답 메시지 추가
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch + 1,
          message:
              responseData['response']['choices'][0]['message']['content'] ??
              "응답을 생성할 수 없습니다.",
          sender: 'ai',
          from: _selectedRoom!.id,
          owner: '',
        );

        _messages.add(aiMessage);
        notifyListeners();
      } else {
        throw Exception('메시지 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('메시지 전송 중 오류 발생: $e');

      // 오류 메시지 추가
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 2,
        message: "죄송합니다. 응답을 생성하는 데 문제가 발생했습니다. 다시 시도해 주세요.",
        sender: 'ai',
        from: _selectedRoom!.id,
        owner: '',
      );

      _messages.add(errorMessage);
      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// AI 모델에 따른 API 엔드포인트 반환
  String _getModelEndpoint(String model) {
    switch (model) {
      case 'gpt4o':
        return '/api/ai/gpt4o';
      case 'gpt41':
        return '/api/ai/gpt41';
      case 'gpt4o-mini':
      default:
        return '/api/ai/gpt4o_m';
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
