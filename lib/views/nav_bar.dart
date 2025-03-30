import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/views/home.dart';
import 'package:dimiplan/views/planner.dart';
import 'package:dimiplan/views/account.dart';
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
  bool mark=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor.shade100,
        title: SvgPicture.asset(
          'assets/icons/logo_rectangular.svg',
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).primaryColor.shade50,
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: '플래너',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_rounded),
            label: '계정관리',
          )
        ]
      ),
      body: screens[currentIndex],
    );
  }
}
