import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/providers/theme_provider.dart';
import 'package:dimiplan/widgets/button.dart';
import 'package:dimiplan/views/edit_profile.dart';
import 'package:dimiplan/utils/snackbar_util.dart';

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
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // 로딩 중일 때
        if (authProvider.isLoading) {
          return _buildLoadingState(theme);
        }

        // 로그인 상태일 때
        if (authProvider.isAuthenticated) {
          return _buildAuthenticatedState(authProvider, theme);
        }

        // 로그인 필요 상태
        return _buildUnauthenticatedState(authProvider, theme);
      },
    );
  }

  // 로딩 상태 UI
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 프로필 이미지 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 24),

          // 이름 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 학년/반 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 버튼 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: Container(
              width: 180,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그인 상태 UI
  Widget _buildAuthenticatedState(AuthProvider authProvider, ThemeData theme) {
    final user = authProvider.user!;
    final isDimigoStudent = authProvider.isDimigoStudent;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 프로필 카드
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 프로필 이미지
                        Hero(
                          tag: 'profile_image',
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(user.profileImage),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            onBackgroundImageError: (_, __) {},
                            child:
                                user.profileImage.isEmpty
                                    ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 사용자 이름
                        Text(
                          user.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 학년/반 (디미고 학생인 경우)
                        if (isDimigoStudent &&
                            user.grade != null &&
                            user.classnum != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${user.grade}학년 ${user.classnum}반',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),

                        // 이메일
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            user.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.shade700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 회원정보 수정 버튼
                        AppButton(
                          text: '회원정보 수정',
                          icon: Icons.edit,
                          variant: ButtonVariant.primary,
                          size: ButtonSize.medium,
                          isFullWidth: true,
                          onPressed: () => _navigateToEditProfile(authProvider),
                        ),

                        const SizedBox(height: 16),

                        // 로그아웃 버튼
                        AppButton(
                          text: '로그아웃',
                          icon: Icons.logout,
                          variant: ButtonVariant.secondary,
                          size: ButtonSize.medium,
                          isFullWidth: true,
                          onPressed: () => _handleLogout(authProvider),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 앱 정보 카드
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(
                            theme.brightness == Brightness.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            theme.brightness == Brightness.dark
                                ? '라이트 모드로 전환'
                                : '다크 모드로 전환',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _toggleTheme(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('앱 정보'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _showAppInfo(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 로그인 필요 상태 UI
  Widget _buildUnauthenticatedState(
    AuthProvider authProvider,
    ThemeData theme,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: theme.colorScheme.primary.shade700,
                ),
                const SizedBox(height: 32),

                // 제목
                Text(
                  '로그인이 필요합니다',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 설명
                Text(
                  '디미플랜의 모든 기능을 이용하려면 로그인이 필요합니다.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 로그인 버튼
                AppButton(
                  text: '구글 계정으로 로그인',
                  icon: Icons.login,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  isFullWidth: true,
                  rounded: true,
                  onPressed: () => _handleLogin(authProvider),
                ),

                const SizedBox(height: 16),

                // 설명
                Text(
                  '디미고 구글 계정으로 로그인 시 학년/반이 자동으로 설정됩니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('로그아웃'),
              ),
            ],
          ),
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

  // 회원정보 수정 화면으로 이동
  void _navigateToEditProfile(AuthProvider authProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditProfileScreen(
              user: authProvider.user!,
              updateUserInfo: authProvider.refreshUserInfo,
            ),
      ),
    );
  }

  // 앱 정보 다이얼로그
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('앱 정보'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('디미플랜 (Dimiplan)'),
                SizedBox(height: 8),
                Text('버전: 1.1.0'),
                SizedBox(height: 8),
                Text('개발: 디미고 학생 개발팀'),
                SizedBox(height: 8),
                Text('라이센스 : AGPL'),
                SizedBox(height: 8),
                Text('디미플랜은 학생들을 위한 플래너 및 AI 챗봇 앱입니다.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
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
