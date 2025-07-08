import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/utils/dialog_utils.dart';

class ModelSelectionModal extends StatelessWidget {
  const ModelSelectionModal({
    super.key,
    required this.selectedModel,
    required this.onModelSelected,
  });

  final String selectedModel;
  final Function(String) onModelSelected;

  static Future<void> show({
    required BuildContext context,
    required String selectedModel,
    required Function(String) onModelSelected,
  }) async {
    final result = await DialogUtils.showBottomSheet<String>(
      context: context,
      child: ModelSelectionModal(
        selectedModel: selectedModel,
        onModelSelected: onModelSelected,
      ),
    );

    if (result != null) {
      onModelSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
          _buildModelOption(
            context,
            'gpt4o-mini',
            'GPT-4o mini',
            '빠른 응답 속도, 기본 기능',
            theme,
          ),
          _buildModelOption(
            context,
            'gpt4o',
            'GPT-4o',
            '고급 이해력과 풍부한 답변',
            theme,
          ),
          _buildModelOption(context, 'gpt41', 'GPT-4.1', '최신 지식과 고급 기능', theme),
        ],
      ),
    );
  }

  Widget _buildModelOption(
    BuildContext context,
    String id,
    String name,
    String description,
    ThemeData theme,
  ) {
    final isSelected = selectedModel == id;

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
              groupValue: selectedModel,
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
}
