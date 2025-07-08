import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/providers/ai_provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/utils/snackbar_util.dart';
import 'package:dimiplan/utils/dialog_utils.dart';
import 'package:dimiplan/utils/validation_utils.dart';
import 'package:dimiplan/widgets/loading_indicator.dart';
import 'package:dimiplan/views/ai_screen_parts/ai_login_prompt.dart';
import 'package:dimiplan/views/ai_screen_parts/empty_chat_rooms_list.dart';
import 'package:dimiplan/views/ai_screen_parts/empty_chat_screen.dart';
import 'package:dimiplan/views/ai_screen_parts/chat_message_list.dart';
import 'package:dimiplan/views/ai_screen_parts/chat_room_item.dart';
import 'package:dimiplan/views/ai_screen_parts/message_input_area.dart';
import 'package:dimiplan/views/ai_screen_parts/model_selection_modal.dart';
import 'package:dimiplan/models/chat_models.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key, this.onTabChange});
  final void Function(int)? onTabChange;

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isComposing = false;
  String _selectedModel = 'gpt4o-mini';
  bool _isMobileChatListVisible = false; // 모바일 뷰에서 채팅 목록 표시 여부

  @override
  void initState() {
    super.initState();

    // AI 채팅방 로드 - 한 번만 수행하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // mounted 체크 추가
        final aiProvider = Provider.of<AIProvider>(context, listen: false);
        aiProvider.loadChatRooms();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(covariant AIScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 탭이 변경된 경우에만 데이터 새로고침
    if (oldWidget.onTabChange != widget.onTabChange) {
      _scrollToBottom();

      // 필요한 경우에만 새로고침 수행
      if (mounted) {
        // mounted 체크 추가
        final aiProvider = Provider.of<AIProvider>(context, listen: false);
        if (!aiProvider.isLoading) {
          aiProvider.loadChatRooms(); // 전체 refreshAll 대신 필요한 데이터만 로드
        }
      }
    }
  }

  // 스크롤을 맨 아래로 이동
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 메시지 전송
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();
    _inputFocusNode.requestFocus();

    // 컨텍스트 미리 캡처
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      if (mounted) showSnackBar(context, '로그인이 필요합니다.');
      return;
    }

    try {
      await aiProvider.sendMessage(message: messageText, model: _selectedModel);
      if (mounted) _scrollToBottom();
    } catch (e) {
      if (mounted) showSnackBar(context, '메시지 전송 중 오류가 발생했습니다: $e');
    }
  }

  // 새 채팅방 생성
  Future<void> _createNewChatRoom() async {
    final result = await DialogUtils.showInputDialog(
      context: context,
      title: '새 채팅방 만들기',
      hintText: '채팅방 이름을 입력하세요',
      validator: (value) => ValidationUtils.validateRequired(value, '채팅방 이름'),
    );

    if (result != null && mounted) {
      final aiProvider = Provider.of<AIProvider>(context, listen: false);

      try {
        await aiProvider.createChatRoom(result);
        if (mounted) showSnackBar(context, '새 채팅방이 생성되었습니다.');
      } catch (e) {
        if (mounted) showSnackBar(context, '채팅방 생성 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 채팅방 선택
  void _selectChatRoom(ChatRoom room) {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.selectChatRoom(room);
    aiProvider.refreshAll();
    _scrollToBottom();

    // 모바일 뷰에서 채팅 목록을 닫고 채팅 화면으로 전환
    if (_isMobileChatListVisible) {
      setState(() {
        _isMobileChatListVisible = false;
      });
    }
  }

  // AI 모델 선택 모달
  Future<void> _showModelSelectionModal() async {
    await ModelSelectionModal.show(
      context: context,
      selectedModel: _selectedModel,
      onModelSelected: (model) {
        setState(() {
          _selectedModel = model;
        });
      },
    );
  }

  

  // 모델 표시 이름 반환
  String _getModelDisplayName() {
    switch (_selectedModel) {
      case 'gpt4o-mini':
        return 'GPT-4o mini';
      case 'gpt4o':
        return 'GPT-4o';
      case 'gpt41':
        return 'GPT-4.1';
      default:
        return 'AI 모델';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiProvider = Provider.of<AIProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      body:
          isAuthenticated
              ? _buildMobileChatUI(theme, aiProvider)
              : AiLoginPrompt(onTabChange: widget.onTabChange),
    );
  }

  // 모바일 채팅 UI
  Widget _buildMobileChatUI(ThemeData theme, AIProvider aiProvider) {
    final selectedRoom = aiProvider.selectedChatRoom;
    final messages = aiProvider.messages;
    final chatRooms = aiProvider.chatRooms;
    final isLoading = aiProvider.isLoading;

    // 채팅방이 선택되지 않았거나 채팅 목록 화면이 표시 중이면 채팅 목록 표시
    if (selectedRoom == null || _isMobileChatListVisible) {
      return Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.shade50,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text('채팅방 목록', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createNewChatRoom,
                  tooltip: '새 채팅방 만들기',
                ),
              ],
            ),
          ),

          // 채팅방 목록
          Expanded(
            child:
                isLoading
                    ? const Center(child: AppLoadingIndicator())
                    : chatRooms.isEmpty
                    ? EmptyChatRoomsList(onCreateNewChatRoom: _createNewChatRoom)
                    : ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final room = chatRooms[index];
                        return ChatRoomItem(room: room, isSelected: selectedRoom?.id == room.id, onTap: () => _selectChatRoom(room));
                      },
                    ),
          ),
        ],
      );
    }

    // 선택된 채팅방이 있고 채팅 화면이 표시 중이면 채팅 UI 표시
    return SafeArea(
      bottom: false, // 하단 SafeArea는 비활성화 (메시지 입력 영역에서 별도 처리)
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.shade50,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 뒤로 가기 버튼 (채팅 목록으로)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isMobileChatListVisible = true;
                    });
                  },
                ),
                // 채팅방 이름
                Expanded(
                  child: Text(
                    selectedRoom.name,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 모델 선택 버튼
                TextButton.icon(
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(_getModelDisplayName()),
                  onPressed: _showModelSelectionModal,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // 메시지 목록
          Expanded(
            child:
                messages.isEmpty
                    ? EmptyChatScreen(
                        onSuggestionSelected: (suggestion) {
                          _messageController.text = suggestion;
                          setState(() {
                            _isComposing = true;
                          });
                          _inputFocusNode.requestFocus();
                        },
                      )
                    : ChatMessageList(
                        messages: messages,
                        isLoading: isLoading,
                        scrollController: _scrollController,
                      ),
          ),

          // 메시지 입력 영역
          MessageInputArea(
            messageController: _messageController,
            inputFocusNode: _inputFocusNode,
            isComposing: _isComposing,
            isLoading: isLoading,
            onSendMessage: _sendMessage,
            onChanged: (value) {
              setState(() {
                _isComposing = value.trim().isNotEmpty;
              });
            },
          ),
        ],
      ),
    );
  }
}