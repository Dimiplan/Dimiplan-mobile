import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/widgets/button.dart';
import 'package:dimiplan/views/edit_profile.dart';

class AccountAuthenticatedState extends StatelessWidget {
  const AccountAuthenticatedState({
    super.key,
    required this.authProvider,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onLogout,
    required this.onToggleTheme,
    required this.onShowAppInfo,
  });

  final AuthProvider authProvider;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Function(AuthProvider) onLogout;
  final Function(BuildContext) onToggleTheme;
  final Function(BuildContext) onShowAppInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = authProvider.user!;
    final isDimigoStudent = authProvider.isDimigoStudent;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
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
                          isFullWidth: true,
                          onPressed:
                              () =>
                                  _navigateToEditProfile(context, authProvider),
                        ),

                        const SizedBox(height: 16),

                        // 로그아웃 버튼
                        AppButton(
                          text: '로그아웃',
                          icon: Icons.logout,
                          variant: ButtonVariant.secondary,
                          isFullWidth: true,
                          onPressed: () => onLogout(authProvider),
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
                          onTap: () => onToggleTheme(context),
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
                          onTap: () => onShowAppInfo(context),
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

  // 회원정보 수정 화면으로 이동
  void _navigateToEditProfile(BuildContext context, AuthProvider authProvider) {
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
}
