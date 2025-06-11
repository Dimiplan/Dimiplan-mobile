import 'package:dimiplan/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/widgets/common_widgets.dart';

class Homepage extends StatefulWidget {
  final Function(int)? onTabChange;

  const Homepage({super.key, this.onTabChange});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppHeader(
                          title: '디미플랜',
                          subtitle: authProvider.isAuthenticated
                              ? '${authProvider.user?.name ?? '사용자'}님, 환영합니다!'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        const TypewriterText(
                          texts: [
                            '당신의 계획을 관리하세요',
                            'AI 챗봇으로 학습을 도와드립니다',
                            '더 나은 학교생활을 위한 솔루션',
                          ],
                        ),
                        const SizedBox(height: 40),
                        AnimatedButtonGroup(
                          controller: _animationController,
                          buttons: [
                            AnimatedButtonData(
                              text: '플래너로 이동',
                              icon: Icons.list_alt_rounded,
                              onPressed: () => widget.onTabChange?.call(1),
                            ),
                            AnimatedButtonData(
                              text: 'AI 챗봇 시작하기',
                              icon: Icons.chat_rounded,
                              variant: ButtonVariant.secondary,
                              onPressed: () => widget.onTabChange?.call(2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        StatusInfoCard(
                          controller: _animationController,
                          message: authProvider.isAuthenticated
                              ? '현재 ${authProvider.taskCount}개의 일정이 있습니다'
                              : '플래너와 AI 챗봇을 사용하려면 로그인하세요',
                          actionText: authProvider.isAuthenticated ? null : '로그인하기',
                          onActionPressed: authProvider.isAuthenticated ? null : () => widget.onTabChange?.call(3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}