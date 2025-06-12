import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/widgets/button.dart';

class UnauthenticatedState extends StatelessWidget {

  const UnauthenticatedState({
    required this.title, required this.subtitle, required this.actionText, required this.onAction, super.key,
    this.icon = Icons.lock_outline,
  });
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: actionText,
              icon: Icons.login,
              size: ButtonSize.large,
              rounded: true,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {

  const EmptyState({
    required this.title, required this.subtitle, required this.actionText, required this.onAction, required this.icon, super.key,
    this.secondaryActionText,
    this.onSecondaryAction,
  });
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onAction;
  final IconData icon;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: actionText,
              icon: Icons.add,
              size: ButtonSize.large,
              rounded: true,
              onPressed: onAction,
            ),
            if (secondaryActionText != null && onSecondaryAction != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(secondaryActionText!),
                onPressed: onSecondaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {

  const LoadingState({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {

  const ErrorState({
    required this.title, required this.message, required this.actionText, required this.onAction, super.key,
  });
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: actionText,
              icon: Icons.refresh,
              variant: ButtonVariant.secondary,
              size: ButtonSize.large,
              rounded: true,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}