import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/theme/app_theme.dart';
import 'package:dimiplan/providers/theme_provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/views/home.dart';
import 'package:dimiplan/views/planner.dart';
import 'package:dimiplan/views/ai_screen.dart';
import 'package:dimiplan/views/account.dart';
import 'package:dimiplan/widgets/loading_indicator.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = false;

  // 애니메이션 컨트롤러
  late final AnimationController _animationController;

  // 페이지 컨트롤러
  final PageController _pageController = PageController();

  // 탭 목록
  final List<_NavTab> _tabs = [
    _NavTab(
      icon: Icons.home_rounded,
      label: '홈',
      screen: (onTabChange) => Homepage(onTabChange: onTabChange),
    ),
    _NavTab(
      icon: Icons.list_alt_rounded,
      label: '플래너',
      screen: (_) => const PlannerPage(),
    ),
    _NavTab(
      icon: Icons.chat_rounded,
      label: 'AI 챗봇',
      screen: (_) => const AIScreen(),
    ),
    _NavTab(
      icon: Icons.account_circle_rounded,
      label: '계정관리',
      screen: (_) => const Account(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationDuration,
    );

    // 인증 상태 확인
    _checkSession();

    // 마지막으로 선택한 탭 가져오기
    _loadLastTab();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 세션 확인
  Future<void> _checkSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 인증 프로바이더에서 세션 확인
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuth();

      // 플래너 탭이 선택되어 있을 경우, 플래너 데이터 로드
      if (_currentIndex == 1) {
        await _loadPlanners();
      }
    } catch (e) {
      print('Error during session check: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 플래너 데이터 로드
  Future<void> _loadPlanners() async {
    // 플래너 로직은 PlannerPage에서 처리
  }

  // 마지막으로 선택한 탭 로드
  Future<void> _loadLastTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTab = prefs.getInt('last_tab');
      if (lastTab != null) {
        _setCurrentIndex(lastTab);
      }
    } catch (e) {
      print('Error loading last tab: $e');
    }
  }

  // 현재 탭 저장
  Future<void> _saveLastTab(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_tab', index);
    } catch (e) {
      print('Error saving last tab: $e');
    }
  }

  // 탭 변경
  void _setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppTheme.animationDuration,
      curve: Curves.easeInOut,
    );
    _saveLastTab(index);

    // 플래너 탭이 선택된 경우, 세션 및 플래너 확인
    if (index == 1) {
      _checkSession();
    }
  }

  // 다른 탭에서 플래너 탭으로 이동 처리
  void _handleTabChange(int index) {
    if (index >= 0 && index < _tabs.length) {
      _setCurrentIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    // 로딩 중일 때는 로딩 인디케이터 표시
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: AppLoadingIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBody: true, // 바텀 바 아래 영역까지 콘텐츠 확장
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        title: SvgPicture.asset(
          'assets/icons/logo_rectangular.svg',
          height: 50,
          fit: BoxFit.contain,
        ),
        actions: [
          // 다크모드 토글 버튼
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: themeProvider.isDarkMode ? '라이트 모드로 전환' : '다크 모드로 전환',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _setCurrentIndex,
        physics: const NeverScrollableScrollPhysics(), // 스와이프로 페이지 변경 비활성화
        children: _tabs.map(
          (tab) => tab.screen(_handleTabChange)
        ).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.shade100,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: theme.colorScheme.surface,
          selectedIndex: _currentIndex,
          onDestinationSelected: _setCurrentIndex,
          animationDuration: AppTheme.animationDuration,
          destinations: _tabs.map((tab) => NavigationDestination(
            icon: Icon(tab.icon),
            label: tab.label,
          )).toList(),
        ),
      ),
      floatingActionButton: _currentIndex == 1 && isAuthenticated
          ? FloatingActionButton(
              backgroundColor: theme.colorScheme.primaryContainer,
              elevation: 8.0,
              child: const Icon(Icons.add, size: 32),
              onPressed: () {
                // AddTaskScreen으로 이동
                Navigator.pushNamed(context, '/add_task');
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// 네비게이션 탭 데이터 클래스
class _NavTab {
  final IconData icon;
  final String label;
  final Widget Function(Function(int) onTabChange) screen;

  _NavTab({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
