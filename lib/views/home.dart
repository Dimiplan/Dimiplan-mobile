import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:color_shade/color_shade.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/widgets/button.dart';

class Homepage extends StatefulWidget {
  final Function(int)? onTabChange;

  const Homepage({Key? key, this.onTabChange}) : super(key: key);

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

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 페이드인 애니메이션
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // 슬라이드 애니메이션
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;
    final userName = authProvider.user?.name ?? '사용자';

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            bottom: 0,
            child: Opacity(
              opacity: 0.6,
              child: SvgPicture.asset(
                'assets/images/background.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 콘텐츠
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
                        // 아이콘
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 100,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 24),

                        // 제목 (애니메이션)
                        Text(
                          '디미플랜',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 환영 메시지
                        if (isAuthenticated)
                          Text(
                            '$userName님, 환영합니다!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // 애니메이션 텍스트
                        SizedBox(
                          height: 50,
                          child: DefaultTextStyle(
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  '당신의 계획을 관리하세요',
                                  speed: const Duration(milliseconds: 100),
                                ),
                                TypewriterAnimatedText(
                                  'AI 챗봇으로 학습을 도와드립니다',
                                  speed: const Duration(milliseconds: 100),
                                ),
                                TypewriterAnimatedText(
                                  '더 나은 학교생활을 위한 솔루션',
                                  speed: const Duration(milliseconds: 100),
                                ),
                              ],
                              repeatForever: true,
                              isRepeatingAnimation: true,
                              displayFullTextOnTap: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 플래너로 이동 버튼
                        AnimatedOpacity(
                          opacity: _animationController.value,
                          duration: const Duration(milliseconds: 500),
                          child: AppButton(
                            text: '플래너로 이동',
                            icon: Icons.list_alt_rounded,
                            variant: ButtonVariant.primary,
                            size: ButtonSize.large,
                            rounded: true,
                            onPressed: () {
                              if (widget.onTabChange != null) {
                                widget.onTabChange!(1);
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // AI 챗봇으로 이동 버튼
                        AnimatedOpacity(
                          opacity: _animationController.value,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          child: AppButton(
                            text: 'AI 챗봇 시작하기',
                            icon: Icons.chat_rounded,
                            variant: ButtonVariant.secondary,
                            size: ButtonSize.large,
                            rounded: true,
                            onPressed: () {
                              if (widget.onTabChange != null) {
                                widget.onTabChange!(2);
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 카운트 정보 또는 팁
                        AnimatedOpacity(
                          opacity: _animationController.value,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              isAuthenticated
                                  ? '현재 ${authProvider.taskCount}개의 일정이 있습니다'
                                  : '플래너와 AI 챗봇을 사용하려면 로그인하세요',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        // 로그인 버튼 (비인증 상태일 때만)
                        if (!isAuthenticated)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TextButton.icon(
                              icon: const Icon(Icons.login),
                              label: const Text('로그인하기'),
                              onPressed: () {
                                if (widget.onTabChange != null) {
                                  widget.onTabChange!(3); // 계정 페이지로 이동
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.primaryColor,
                              ),
                            ),
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
