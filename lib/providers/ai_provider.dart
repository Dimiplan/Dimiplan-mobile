import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dimiplan/providers/http_provider.dart';
import 'package:dimiplan/models/chat_models.dart';
import 'package:dimiplan/constants/api_constants.dart';
import 'package:dimiplan/utils/state_utils.dart';
import 'package:dimiplan/utils/api_utils.dart';

class AIProvider extends ChangeNotifier with LoadingStateMixin {
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  ChatRoom? _selectedRoom;

  // 게터
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  ChatRoom? get selectedChatRoom => _selectedRoom;

  /// 전체 데이터 새로고침 - 불필요한 새로고침 방지
  Future<void> refreshAll() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (isLoading) return;

    // 채팅방 목록 로드
    await loadChatRooms();

    // 선택된 채팅방이 있는 경우에만 메시지 로드
    if (_selectedRoom != null) {
      await loadMessages();
    }
  }

  /// 채팅방 목록 로드
  Future<void> loadChatRooms() async {
    await AsyncOperationHandler.execute(
      operation: () async {
        final data = await ApiUtils.fetchData(ApiConstants.ai.getRoomList);
        if (data != null) {
          final rooms = <ChatRoom>[];
          for (final room in data['roomData']) {
            rooms.add(ChatRoom.fromMap(room));
          }
          _chatRooms = rooms;

          if (_chatRooms.isNotEmpty && _selectedRoom == null) {
            await selectChatRoom(_chatRooms.first);
          } else if (_selectedRoom != null &&
              !_chatRooms.any((r) => r.id == _selectedRoom!.id)) {
            if (_chatRooms.isNotEmpty) {
              await selectChatRoom(_chatRooms.first);
            } else {
              _selectedRoom = null;
              _messages = [];
            }
          }
          safeNotifyListeners();
        } else {
          _chatRooms = [];
        }
      },
      setLoading: setLoading,
      errorContext: '채팅방 목록 로드',
    );
  }

  /// 채팅방 생성
  Future<void> createChatRoom(String name) async {
    await AsyncOperationHandler.execute(
      operation: () async {
        await ApiUtils.postData(ApiConstants.ai.addRoom, data: {'name': name});
        await refreshAll();
      },
      setLoading: setLoading,
      errorContext: '채팅방 생성',
    );
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
    if (_selectedRoom == null) return;

    await AsyncOperationHandler.execute(
      operation: () async {
        final data = await ApiUtils.fetchData(
          ApiConstants.ai.getChatInRoom,
          queryParams: {'from': _selectedRoom!.id.toString()},
        );
        if (data != null) {
          final messages = <ChatMessage>[];
          for (final message in data['chatData']) {
            messages.add(ChatMessage.fromMap(message));
          }
          _messages = messages;
          safeNotifyListeners();
        } else {
          _messages = [];
        }
      },
      setLoading: setLoading,
      errorContext: '채팅 메시지 로드',
    );
  }

  /// 메시지 전송
  Future<void> sendMessage({
    required String message,
    required String model,
  }) async {
    if (_selectedRoom == null) return;

    await AsyncOperationHandler.execute(
      operation: () async {
        // 세션 유효성 검사
        final isSessionValid = await httpClient.isSessionValid();
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
        safeNotifyListeners();

        // API에 따라 AI 모델 엔드포인트 선택
        final url = Uri.https(ApiConstants.backendHost, ApiConstants.ai.auto);

        final response = await httpClient.post(
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
                responseData['message'] ??
                '죄송합니다. 응답을 생성하는 데 문제가 발생했습니다. 다시 시도해 주세요.',
            sender: 'ai',
            from: _selectedRoom!.id,
            owner: '',
          );

          _messages.add(aiMessage);
          safeNotifyListeners();
        } else {
          throw Exception('메시지 전송 실패: ${response.statusCode}');
        }
      },
      setLoading: setLoading,
      errorContext: '메시지 전송',
      onError: (error) {
        // 오류 메시지 추가
        final errorMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch + 2,
          message: '죄송합니다. 응답을 생성하는 데 문제가 발생했습니다. 다시 시도해 주세요.',
          sender: 'ai',
          from: _selectedRoom!.id,
          owner: '',
        );

        _messages.add(errorMessage);
        safeNotifyListeners();
      },
    );
  }
}
