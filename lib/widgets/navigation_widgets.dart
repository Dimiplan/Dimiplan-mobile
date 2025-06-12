import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/utils/dialog_utils.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.controller,
    required this.tabNames,
    super.key,
    this.isScrollable = false,
  });
  final TabController controller;
  final List<String> tabNames;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
      child: TabBar(
        controller: controller,
        tabs: tabNames.map((name) => Tab(text: name)).toList(),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3.0,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.shade700,
        labelStyle: theme.textTheme.titleSmall,
        isScrollable: isScrollable,
      ),
    );
  }
}

class SideNavigation extends StatelessWidget {
  const SideNavigation({
    required this.title,
    required this.children,
    super.key,
    this.headerAction,
    this.width = 250,
  });
  final String title;
  final List<Widget> children;
  final Widget? headerAction;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.shade50,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (headerAction != null) headerAction!,
              ],
            ),
          ),
          Expanded(
            child:
                children.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              '항목이 없습니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class OptionsBottomSheet extends StatelessWidget {
  const OptionsBottomSheet({required this.options, super.key});
  final List<OptionItem> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          options.map((option) {
            return ListTile(
              leading: Icon(
                option.icon,
                color:
                    option.isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
              ),
              title: Text(
                option.title,
                style:
                    option.isDestructive
                        ? TextStyle(color: Theme.of(context).colorScheme.error)
                        : null,
              ),
              onTap: () {
                Navigator.pop(context);
                option.onTap();
              },
            );
          }).toList(),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required List<OptionItem> options,
  }) {
    return DialogUtils.showBottomSheet(
      context: context,
      child: OptionsBottomSheet(options: options),
    );
  }
}

class OptionItem {
  const OptionItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
}

class FloatingActionGroup extends StatelessWidget {
  const FloatingActionGroup({
    required this.actions,
    super.key,
    this.backgroundColor,
  });
  final List<FloatingActionItem> actions;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (actions.length == 1) {
      final action = actions.first;
      return FloatingActionButton(
        onPressed: action.onPressed,
        backgroundColor: backgroundColor,
        child: Icon(action.icon),
      );
    }

    return FloatingActionButton(
      onPressed: () => _showActionMenu(context),
      backgroundColor: backgroundColor,
      child: const Icon(Icons.add),
    );
  }

  void _showActionMenu(BuildContext context) {
    DialogUtils.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            actions.map((action) {
              return ListTile(
                leading: Icon(action.icon),
                title: Text(action.title),
                onTap: () {
                  Navigator.pop(context);
                  action.onPressed();
                },
              );
            }).toList(),
      ),
    );
  }
}

class FloatingActionItem {
  const FloatingActionItem({
    required this.title,
    required this.icon,
    required this.onPressed,
  });
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
}
