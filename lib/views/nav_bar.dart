import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/internal/model.dart';
import 'package:dimiplan/views/account.dart';
import 'package:dimiplan/views/add_task.dart';
import 'package:dimiplan/views/ai_screen.dart';
import 'package:dimiplan/views/home.dart';
import 'package:dimiplan/views/planner.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int currentIndex = 0;
  late List<Widget> screens;
  bool mark = false;
  List<Planner> planners = [];
  bool isLoadingPlanners = false;

  @override
  void initState() {
    super.initState();
    screens = [
      Homepage(
        onTabChange: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      const PlannerPage(),
      const AIScreen(),
      const Account(),
    ];
    checkSession();
  }

  void checkSession() async {
    var value = await db.getSession();
    if (value == '') {
      setState(() {
        mark = true;
      });
    } else {
      setState(() {
        mark = false;
      });
      if (currentIndex == 1) {
        loadPlanners();
      }
    }
  }

  Future<void> loadPlanners() async {
    if (mark) return;

    setState(() {
      isLoadingPlanners = true;
    });

    try {
      final loadedPlanners = await db.getPlanners();
      setState(() {
        planners = loadedPlanners;
        isLoadingPlanners = false;
      });
    } catch (e) {
      print('Error loading planners: $e');
      setState(() {
        isLoadingPlanners = false;
      });
    }
  }

  void _addNewTask() {
    if (planners.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('플래너가 없습니다. 플래너를 먼저 생성해주세요.'),
          action: SnackBarAction(
            label: '생성하기',
            onPressed: () async {
              final result = await showCreatePlannerDialog(context);

              if (result == true) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('새 플래너가 추가되었습니다')));
              }
            },
          ),
        ),
      );
      return;
    }

    // Launch the add task screen with the first planner selected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTaskScreen(
              updateTaskList: () {
                if (screens[1] is Planner) {
                  setState(() {
                    // Trigger planner refresh
                    screens[1] = const PlannerPage();
                  });
                }
              },
              selectedPlannerId: planners.first.id,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: SvgPicture.asset(
          'assets/icons/logo_rectangular.svg',
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
      body: screens[currentIndex],
      // 플래너 화면(인덱스 1)일 때와 세션이 있을 때만 FloatingActionButton 표시
      floatingActionButton:
          (currentIndex == 1 && !mark)
              ? FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                elevation: 8.0,
                child: Icon(Icons.add, size: 32),
                onPressed: () {
                  if (isLoadingPlanners) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('플래너를 로딩 중입니다. 잠시 기다려주세요.')),
                    );
                    return;
                  }
                  _addNewTask();
                },
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
            if (value == 1) {
              checkSession();
              loadPlanners();
            }
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: '플래너',
          ),
          NavigationDestination(icon: Icon(Icons.chat_rounded), label: 'AI 챗봇'),
          NavigationDestination(
            icon: Icon(Icons.account_circle_rounded),
            label: '계정관리',
          ),
        ],
      ),
    );
  }
}
