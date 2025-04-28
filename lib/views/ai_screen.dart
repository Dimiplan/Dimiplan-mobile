import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/internal/ai.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatRoom> _rooms = [];
  ChatRoom? _selectedRoom;
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rooms = await _aiService.getChatRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;

        if (rooms.isNotEmpty) {
          _selectedRoom = rooms.first;
          _loadMessages();
        }
      });
    } catch (e) {
      print('Error loading chat rooms: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_selectedRoom == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _aiService.getChatMessages(_selectedRoom!.id);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Scroll to bottom after messages load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedRoom == null) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Optimistically add the user's message
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          message: message,
          sender: 'user',
          from: _selectedRoom!.id,
          owner: '', // Will be filled by server
        ),
      );
      _isSending = true;
    });

    // Scroll to bottom after adding the message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final response = await _aiService.sendMessage(message, _selectedRoom!.id);

      if (response != null) {
        // Add AI response
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch + 1, // Temporary ID
          message:
              response['response']['choices'][0]['text'] ??
              "I don't know how to respond to that.",
          sender: 'ai',
          from: _selectedRoom!.id,
          owner: '', // Will be filled by server
        );

        setState(() {
          _messages.add(aiMessage);
          _isSending = false;
        });

        // Scroll to bottom after AI response
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get AI response')),
        );
        setState(() {
          _isSending = false;
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _createNewRoom() async {
    final TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 채팅방 만들기'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "채팅방 이름을 입력하세요"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                Navigator.pop(context);
                final success = await _aiService.createChatRoom(
                  controller.text.trim(),
                );

                if (success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('채팅방이 생성되었습니다')));
                  _loadChatRooms();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('채팅방 생성에 실패했습니다')),
                  );
                }
              },
              child: const Text('생성'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              '채팅방이 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewRoom,
              icon: const Icon(Icons.add),
              label: const Text('새 채팅방 만들기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Room selector
        Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<ChatRoom>(
                  isExpanded: true,
                  value: _selectedRoom,
                  hint: const Text('채팅방 선택'),
                  onChanged: (ChatRoom? value) {
                    if (value != null && value != _selectedRoom) {
                      setState(() {
                        _selectedRoom = value;
                      });
                      _loadMessages();
                    }
                  },
                  items:
                      _rooms.map<DropdownMenuItem<ChatRoom>>((ChatRoom room) {
                        return DropdownMenuItem<ChatRoom>(
                          value: room,
                          child: Text(room.name),
                        );
                      }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _createNewRoom,
                tooltip: '새 채팅방',
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child:
              _messages.isEmpty
                  ? Center(
                    child: Text(
                      '메시지가 없습니다. 첫 메시지를 보내보세요!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  )
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
        ),

        // Input field
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface.shade200,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8.0),
              _isSending
                  ? const CircularProgressIndicator()
                  : IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _sendMessage,
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final bubbleColor =
        isUser
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.surface.shade300;
    final textColor = isUser ? Colors.white : Colors.black;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16.0),
      topRight: const Radius.circular(16.0),
      bottomLeft:
          isUser ? const Radius.circular(16.0) : const Radius.circular(4.0),
      bottomRight:
          isUser ? const Radius.circular(4.0) : const Radius.circular(16.0),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(message.message, style: TextStyle(color: textColor)),
      ),
    );
  }
}
