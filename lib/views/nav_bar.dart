import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/views/home.dart';
import 'package:dimiplan/views/planner.dart';
import 'package:dimiplan/views/account.dart';
import 'package:dimiplan/views/add_task.dart'; // 추가
import 'package:dimiplan/internal/database.dart'; // 데이터베이스 서비스 추가
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int currentIndex = 0;
  final screens = [const Homepage(), const Planner(), const Account()];
  bool mark = false;

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
    }
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
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.light
                ? Theme.of(context).primaryColor.shade100
                : null,
        title: SvgPicture.asset(
          'assets/icons/logo_rectangular.svg',
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
      body: screens[currentIndex],
      // 플래너 화면(인덱스 1)일 때와 세션이 null이 아닐 때만 FloatingActionButton 표시
      floatingActionButton:
          (currentIndex == 1 && !mark)
              ? FloatingActionButton(
                backgroundColor:
                    MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Theme.of(context).primaryColor.shade50
                        : null,
                elevation: 8.0,
                child: Icon(Icons.add, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AddTaskScreen(
                            updateTaskList: () {
                              if (screens[1] is Planner) {
                                setState(() {
                                  // 플래너 화면 갱신 트리거
                                  screens[1] = const Planner();
                                });
                              }
                            },
                          ),
                    ),
                  );
                },
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.light
                ? Theme.of(context).primaryColor.shade50
                : null,
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
            if (value == 1) {
              checkSession();
            }
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: '플래너',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_rounded),
            label: '계정관리',
          ),
        ],
      ),
    );
  }
}
