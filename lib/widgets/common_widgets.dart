import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/widgets/button.dart';

class AppBackground extends StatelessWidget {
  final String? assetPath;
  final double opacity;

  const AppBackground({
    super.key,
    this.assetPath = 'assets/images/background.svg',
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          assetPath!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final double iconSize;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.calendar_today_rounded,
    this.iconSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (icon != null)
          Icon(
            icon,
            size: iconSize,
            color: theme.primaryColor,
          ),
        if (icon != null) const SizedBox(height: 24),
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          Text(
            subtitle!,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}

class TypewriterText extends StatelessWidget {
  final List<String> texts;
  final Duration speed;
  final bool repeat;

  const TypewriterText({
    super.key,
    required this.texts,
    this.speed = const Duration(milliseconds: 100),
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 50,
      child: DefaultTextStyle(
        style: theme.textTheme.bodyLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        child: AnimatedTextKit(
          animatedTexts: texts
              .map((text) => TypewriterAnimatedText(text, speed: speed))
              .toList(),
          repeatForever: repeat,
          isRepeatingAnimation: repeat,
          displayFullTextOnTap: true,
        ),
      ),
    );
  }
}

class AnimatedButtonGroup extends StatelessWidget {
  final AnimationController controller;
  final List<AnimatedButtonData> buttons;

  const AnimatedButtonGroup({
    super.key,
    required this.controller,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        
        return Column(
          children: [
            if (index > 0) const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: controller.value,
              duration: Duration(milliseconds: 500 + (index * 100)),
              curve: Curves.easeIn,
              child: AppButton(
                text: button.text,
                icon: button.icon,
                variant: button.variant,
                size: button.size,
                rounded: button.rounded,
                onPressed: button.onPressed!,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class AnimatedButtonData {
  final String text;
  final IconData icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool rounded;
  final VoidCallback? onPressed;

  const AnimatedButtonData({
    required this.text,
    required this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.rounded = true,
    this.onPressed,
  });
}

class StatusInfoCard extends StatelessWidget {
  final AnimationController controller;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? actionColor;

  const StatusInfoCard({
    super.key,
    required this.controller,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedOpacity(
          opacity: controller.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (actionText != null && onActionPressed != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextButton.icon(
              icon: const Icon(Icons.login),
              label: Text(actionText!),
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                foregroundColor: actionColor ?? theme.primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}