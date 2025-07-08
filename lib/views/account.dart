import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/providers/theme_provider.dart';
import 'package:dimiplan/utils/snackbar_util.dart';
import 'package:dimiplan/utils/dialog_utils.dart';
import 'package:dimiplan/views/account_parts/account_loading_state.dart';
import 'package:dimiplan/views/account_parts/account_authenticated_state.dart';
import 'package:dimiplan/views/account_parts/account_unauthenticated_state.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 페이드인 애니메이션
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // 슬라이드 애니메이션
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 애니메이션 시작
    _animationController.forward();

    // 인증 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.checkAuth();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // 로딩 중일 때
        if (authProvider.isLoading) {
          return const AccountLoadingState();
        }

        // 로그인 상태일 때
        if (authProvider.isAuthenticated) {
          return AccountAuthenticatedState(
            authProvider: authProvider,
            fadeAnimation: _fadeAnimation,
            slideAnimation: _slideAnimation,
            onLogout: _handleLogout,
            onToggleTheme: _toggleTheme,
            onShowAppInfo: _showAppInfo,
          );
        }

        // 로그인 필요 상태
        return AccountUnauthenticatedState(
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
          onLogin: () => _handleLogin(authProvider),
        );
      },
    );
  }

  

  // 로그인 처리
  Future<void> _handleLogin(AuthProvider authProvider) async {
    try {
      await authProvider.login();
    } catch (e) {
      if (mounted) {
        showSnackBar(context, '로그인 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 로그아웃 처리
  Future<void> _handleLogout(AuthProvider authProvider) async {
    // 확인 다이얼로그
    final confirm = await DialogUtils.showConfirmDialog(
      context: context,
      title: '로그아웃',
      content: '정말 로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
    );

    if (confirm == true) {
      try {
        await authProvider.logout();
        if (mounted) {
          showSnackBar(context, '로그아웃되었습니다.');
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context, '로그아웃 중 오류가 발생했습니다: $e');
        }
      }
    }
  }

  // 앱 정보 다이얼로그
  void _showAppInfo(BuildContext context) {
    DialogUtils.showBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('앱 정보', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('디미플랜 (Dimiplan)'),
            const SizedBox(height: 8),
            const Text('버전: 1.1.0'),
            const SizedBox(height: 8),
            const Text('개발: 디미고 학생 개발팀'),
            const SizedBox(height: 8),
            const Text('라이센스 : AGPL'),
            const SizedBox(height: 8),
            const Text('디미플랜은 학생들을 위한 플래너 및 AI 챗봇 앱입니다.'),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 테마 변경
  void _toggleTheme(BuildContext context) {
    // 테마 변경 로직 (ThemeProvider 사용)
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }
}
