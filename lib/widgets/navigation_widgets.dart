import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/utils/dialog_utils.dart';

class AppTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabNames;
  final bool isScrollable;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabNames,
    this.isScrollable = false,
  });

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
  final String title;
  final List<Widget> children;
  final Widget? headerAction;
  final double width;

  const SideNavigation({
    super.key,
    required this.title,
    required this.children,
    this.headerAction,
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.shade50,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1.0,
                ),
              ),
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
            child: children.isEmpty
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
  final List<OptionItem> options;

  const OptionsBottomSheet({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        return ListTile(
          leading: Icon(
            option.icon,
            color: option.isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
          title: Text(
            option.title,
            style: option.isDestructive
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
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const OptionItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

class FloatingActionGroup extends StatelessWidget {
  final List<FloatingActionItem> actions;
  final Color? backgroundColor;

  const FloatingActionGroup({
    super.key,
    required this.actions,
    this.backgroundColor,
  });

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
        children: actions.map((action) {
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
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const FloatingActionItem({
    required this.title,
    required this.icon,
    required this.onPressed,
  });
}