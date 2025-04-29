import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/theme/app_theme.dart';
import 'package:dimiplan/providers/theme_provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/providers/planner_provider.dart';
import 'package:dimiplan/providers/ai_provider.dart';
import 'package:dimiplan/views/home.dart';
import 'package:dimiplan/views/planner.dart';
import 'package:dimiplan/views/ai_screen.dart';
import 'package:dimiplan/views/account.dart';
import 'package:dimiplan/widgets/loading_indicator.dart';

class Nav extends StatefulWidget {
  final int? initialTab;

  const Nav({Key? key, this.initialTab}) : super(key: key);

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = false;

  // 애니메이션 컨트롤러
  late final AnimationController _animationController;

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

    // 초기 탭 설정 (다른 화면에서 네비게이션으로 전달된 경우)
    if (widget.initialTab != null &&
        widget.initialTab! >= 0 &&
        widget.initialTab! < _tabs.length) {
      _currentIndex = widget.initialTab!;
    }

    // 인증 상태 확인 - Widget 마운트 후 비동기 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });

    // 초기 탭이 전달되지 않은 경우, 마지막으로 선택한 탭 가져오기
    if (widget.initialTab == null) {
      _loadLastTab();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 라우트 인자로 탭 인덱스를 받은 경우 처리
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is int && arguments >= 0 && arguments < _tabs.length) {
      // setState를 사용하여 현재 인덱스 업데이트 (빌드 사이클 외부에서 처리됨)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setCurrentIndex(arguments);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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

      // 현재 선택된 탭에 따라 데이터 로드
      _refreshCurrentTabData();
    } catch (e) {
      print('Error during session check: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 현재 선택된 탭의 데이터 로드
  Future<void> _refreshCurrentTabData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 인증 상태가 아니면 데이터 로드하지 않음
    if (!authProvider.isAuthenticated) return;

    try {
      // 플래너 탭 선택 시 플래너 데이터 로드
      if (_currentIndex == 1) {
        final plannerProvider = Provider.of<PlannerProvider>(
          context,
          listen: false,
        );
        await plannerProvider.loadPlanners();
      }
      // AI 챗봇 탭 선택 시 채팅방 데이터 로드
      else if (_currentIndex == 2) {
        final aiProvider = Provider.of<AIProvider>(context, listen: false);
        await aiProvider.loadChatRooms();
      }
    } catch (e) {
      print('Error refreshing tab data: $e');
    }
  }

  // 마지막으로 선택한 탭 로드
  Future<void> _loadLastTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTab = prefs.getInt('last_tab');
      if (lastTab != null) {
        // 빌드 사이클 외부에서 setState 호출
        setState(() {
          _currentIndex = lastTab;
        });

        // 데이터 로드는 빌드 완료 후 실행
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshCurrentTabData();
        });
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
    if (_currentIndex == index) {
      // 같은 탭을 다시 선택한 경우 데이터 새로고침
      // 빌드 사이클 외부에서 실행하기 위해 스케줄링
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshCurrentTabData();
      });
      return;
    }

    setState(() {
      _currentIndex = index;
    });
    _saveLastTab(index);

    // 빌드 사이클 외부에서 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentTabData();
    });
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
      return const Scaffold(body: Center(child: AppLoadingIndicator()));
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
            builder:
                (context, themeProvider, _) => IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  tooltip:
                      themeProvider.isDarkMode ? '라이트 모드로 전환' : '다크 모드로 전환',
                ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // PageView 대신 현재 선택된 인덱스에 해당하는 화면만 표시
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.screen(_handleTabChange)).toList(),
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
          destinations:
              _tabs
                  .map(
                    (tab) => NavigationDestination(
                      icon: Icon(tab.icon),
                      label: tab.label,
                    ),
                  )
                  .toList(),
        ),
      ),
      floatingActionButton:
          _currentIndex == 1 && isAuthenticated
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

  _NavTab({required this.icon, required this.label, required this.screen});
}
