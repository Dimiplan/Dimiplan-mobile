import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/providers/ai_provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/widgets/button.dart';
import 'package:dimiplan/models/chat_models.dart';
import 'package:dimiplan/utils/snackbar_util.dart';
import 'package:dimiplan/utils/dialog_utils.dart';
import 'package:dimiplan/utils/validation_utils.dart';
import 'package:dimiplan/widgets/loading_indicator.dart';

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
    final result = await DialogUtils.showBottomSheet<String>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Text(
                'AI 모델 선택',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            _buildModelOption('gpt4o-mini', 'GPT-4o mini', '빠른 응답 속도, 기본 기능'),
            _buildModelOption('gpt4o', 'GPT-4o', '고급 이해력과 풍부한 답변'),
            _buildModelOption('gpt41', 'GPT-4.1', '최신 지식과 고급 기능'),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedModel = result;
      });
    }
  }

  // 모델 옵션 UI
  Widget _buildModelOption(String id, String name, String description) {
    final theme = Theme.of(context);
    final isSelected = _selectedModel == id;

    return InkWell(
      onTap: () => Navigator.pop(context, id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer.shade300
                  : Colors.transparent,
          border: Border(
            left: BorderSide(
              color:
                  isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 4.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: id,
              groupValue: _selectedModel,
              onChanged: (_) => Navigator.pop(context, id),
              activeColor: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
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
              : _buildLoginPrompt(theme),
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
                    ? _buildEmptyChatRoomsList(theme)
                    : ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final room = chatRooms[index];
                        return _buildChatRoomItem(room, theme, selectedRoom);
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
                    ? _buildEmptyChat(theme)
                    : _buildChatMessages(messages, theme, isLoading),
          ),

          // 메시지 입력 영역
          _buildMessageInputArea(theme, isLoading),
        ],
      ),
    );
  }

  // 메시지 입력 영역
  Widget _buildMessageInputArea(ThemeData theme, bool isLoading) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.shade100,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: theme.colorScheme.outline.shade500),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _inputFocusNode,
                  decoration: const InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    isDense: true,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: theme.textTheme.bodyLarge,
                  onChanged: (value) {
                    setState(() {
                      _isComposing = value.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (value) {
                    if (_isComposing) {
                      _sendMessage();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 12.0),

            // 전송 버튼
            IconButton(
              onPressed: _isComposing ? _sendMessage : null,
              icon:
                  isLoading
                      ? const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                      : Icon(
                        Icons.send,
                        color:
                            _isComposing
                                ? theme.colorScheme.primary
                                : theme.disabledColor,
                      ),
              tooltip: '메시지 전송',
            ),
          ],
        ),
      ),
    );
  }

  // 로그인 필요 화면
  Widget _buildLoginPrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              'AI 챗봇 사용을 위해\n로그인이 필요합니다',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '로그인하고 AI 챗봇과 대화하여 학습에 도움을 받으세요.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: '로그인하기',
              icon: Icons.login,
              size: ButtonSize.large,
              rounded: true,
              onPressed: () {
                widget.onTabChange!(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 채팅방 아이템
  Widget _buildChatRoomItem(
    ChatRoom room,
    ThemeData theme,
    ChatRoom? selectedRoom,
  ) {
    final isSelected = selectedRoom?.id == room.id;

    return ListTile(
      leading: Icon(
        Icons.chat_bubble_outline,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        room.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      onTap: () => _selectChatRoom(room),
    );
  }

  // 빈 채팅방 목록
  Widget _buildEmptyChatRoomsList(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 채팅방이 없습니다',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '새 채팅 버튼을 눌러 대화를 시작하세요',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: '새 채팅 시작',
              icon: Icons.add,
              onPressed: _createNewChatRoom,
            ),
          ],
        ),
      ),
    );
  }

  // 빈 채팅 화면
  Widget _buildEmptyChat(ThemeData theme) {
    final AIProvider aiProvider = Provider.of<AIProvider>(
      context,
      listen: false,
    );
    aiProvider.refreshAll();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              size: 64,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              'AI 챗봇과 대화를 시작해보세요',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: Text(
                '질문하거나, 학습 도움을 요청하거나, 아이디어를 공유해보세요.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            _buildSuggestionChips(theme),
          ],
        ),
      ),
    );
  }

  // 제안 질문 칩
  Widget _buildSuggestionChips(ThemeData theme) {
    final suggestions = [
      '수학 문제 풀이를 도와줘',
      '프로그래밍 개념을 설명해줘',
      '영어 에세이 작성 팁',
      '스트레스 관리 방법',
      '공부 집중력 높이는 방법',
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children:
          suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(color: theme.colorScheme.primary.shade500),
              onPressed: () {
                _messageController.text = suggestion;
                setState(() {
                  _isComposing = true;
                });
                _inputFocusNode.requestFocus();
              },
            );
          }).toList(),
    );
  }

  // 채팅 메시지 목록
  Widget _buildChatMessages(
    List<ChatMessage> messages,
    ThemeData theme,
    bool isLoading,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // 로딩 중인 AI 메시지
          return _buildLoadingMessage(theme);
        }

        final message = messages[index];
        return _buildChatBubble(message, theme);
      },
    );
  }

  // 로딩 중인 메시지
  Widget _buildLoadingMessage(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(4.0),
            ),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  '생각 중...',
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              repeatForever: true,
            ),
          ),
        ),
      ),
    );
  }

  // 채팅 버블
  Widget _buildChatBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.sender == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16.0),
              topRight: const Radius.circular(16.0),
              bottomRight:
                  isUser
                      ? const Radius.circular(4.0)
                      : const Radius.circular(16.0),
              bottomLeft:
                  isUser
                      ? const Radius.circular(16.0)
                      : const Radius.circular(4.0),
            ),
            side:
                isUser
                    ? BorderSide.none
                    : BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                isUser
                    ? Text(
                      message.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    )
                    : _buildMarkdownBody(message.message, theme),
          ),
        ),
      ),
    );
  }

  // 마크다운 형식 AI 메시지 표시
  Widget _buildMarkdownBody(String message, ThemeData theme) {
    return GptMarkdown(message, style: theme.textTheme.bodyMedium);
  }
}
