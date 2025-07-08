import 'package:flutter/material.dart';
import 'package:dimiplan/models/chat_models.dart';
import 'package:color_shade/color_shade.dart';

class ChatRoomItem extends StatelessWidget {
  const ChatRoomItem({
    super.key,
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  final ChatRoom room;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      onTap: onTap,
    );
  }
}
