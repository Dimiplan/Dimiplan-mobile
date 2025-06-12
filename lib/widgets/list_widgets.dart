import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/models/planner_models.dart';
import 'package:dimiplan/models/chat_models.dart';
import 'package:dimiplan/widgets/loading_indicator.dart';
import 'package:dimiplan/utils/dialog_utils.dart';

class TaskListItem extends StatelessWidget {

  const TaskListItem({
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final Task task;
  final Function(Task) onToggleComplete;
  final Function(Task) onEdit;
  final Function(Task) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted == 1;

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              _handleDelete(context);
            },
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '삭제',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        elevation: isCompleted ? 0 : 2,
        color: isCompleted
            ? theme.colorScheme.surface.shade700
            : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(
            color: _getPriorityColor(isCompleted, task.priority, theme),
            width: 2.0,
          ),
        ),
        child: Semantics(
          label: '작업: ${task.contents}',
          hint: isCompleted ? '완료된 작업' : '미완료 작업',
          onTap: () => onEdit(task),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            title: Text(
              task.contents,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted
                    ? theme.colorScheme.onSurface.shade500
                    : theme.colorScheme.onSurface,
              ),
            ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PriorityIndicator(
                priority: task.priority,
                isCompleted: isCompleted,
              ),
              const SizedBox(width: 8),
              Semantics(
                label: isCompleted ? '작업 완료 취소' : '작업 완료 처리',
                hint: '체크박스',
                child: Checkbox(
                  value: isCompleted,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (_) {
                    HapticFeedback.selectionClick();
                    onToggleComplete(task);
                  },
                ),
              ),
            ],
          ),
            onTap: () => onEdit(task),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(bool isCompleted, int priority, ThemeData theme) {
    if (isCompleted) return theme.disabledColor;
    switch (priority) {
      case 0: return Colors.blue.shade500;
      case 1: return Colors.orange.shade500;
      case 2: return Colors.red.shade500;
      default: return theme.disabledColor;
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await DialogUtils.showConfirmDialog(
      context: context,
      title: '작업 삭제',
      content: '정말 "${task.contents}" 작업을 삭제하시겠습니까?',
      confirmText: '삭제',
      confirmColor: Theme.of(context).colorScheme.error,
    );

    if (confirm == true) {
      onDelete(task);
    }
  }
}

class PriorityIndicator extends StatelessWidget {

  const PriorityIndicator({
    required this.priority,
    required this.isCompleted,
    super.key,
  });
  final int priority;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getPriorityColor(theme),
      ),
    );
  }

  Color _getPriorityColor(ThemeData theme) {
    if (isCompleted) return theme.disabledColor;
    switch (priority) {
      case 0: return Colors.blue.shade500;
      case 1: return Colors.orange.shade500;
      case 2: return Colors.red.shade500;
      default: return theme.disabledColor;
    }
  }
}

class ChatRoomListItem extends StatelessWidget {

  const ChatRoomListItem({
    required this.room,
    required this.isSelected,
    required this.onTap,
    super.key,
  });
  final ChatRoom room;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '채팅방: ${room.name}',
      hint: isSelected ? '선택된 채팅방' : '채팅방 선택하기',
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.shade100 : null,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: ListTile(
          title: Text(
            room.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          dense: true,
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
        ),
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {

  const ChatMessageBubble({
    required this.message,
    super.key,
  });
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.sender == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(theme, false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.0),
                border: isUser 
                    ? null 
                    : Border.all(color: theme.dividerColor),
              ),
              child: isUser 
                  ? Text(
                      message.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    )
                  : GptMarkdown(
                      message.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: theme.colorScheme.surface.shade800,
                      ),
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(theme, true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser 
          ? theme.colorScheme.primary 
          : theme.colorScheme.secondary,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {

  const SectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.action,
  });
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.shade700,
                  ),
                ),
            ],
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class ChatInput extends StatelessWidget {

  const ChatInput({
    required this.controller,
    required this.isComposing,
    required this.isLoading,
    required this.onSend,
    required this.onChanged,
    super.key,
    this.hintText = 'AI에게 질문해보세요...',
  });
  final TextEditingController controller;
  final bool isComposing;
  final bool isLoading;
  final VoidCallback onSend;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onChanged: onChanged,
              onSubmitted: isComposing && !isLoading ? (_) => onSend() : null,
              enabled: !isLoading,
            ),
          ),
          const SizedBox(width: 8),
          if (isLoading)
            const SizedBox(
              width: 40,
              height: 40,
              child: AppLoadingIndicator(size: 20),
            )
          else
            IconButton(
              icon: Icon(
                Icons.send,
                color: isComposing 
                    ? theme.colorScheme.primary 
                    : theme.disabledColor,
              ),
              onPressed: isComposing ? () {
                HapticFeedback.lightImpact();
                onSend();
              } : null,
            ),
        ],
      ),
    );
  }
}