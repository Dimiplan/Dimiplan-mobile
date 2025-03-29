import 'package:dimiplanner/home.dart';
import 'package:dimiplanner/planner.dart';
import 'package:dimiplanner/account.dart';
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
        backgroundColor: Theme.of(context).primaryColorLight,
        title: SvgPicture.asset(
          'assets/icons/logo_rectangular.svg',
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
        child: NavigationBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            surfaceTintColor: Theme.of(context).primaryColor,
            selectedIndex: currentIndex,
            onDestinationSelected: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            destinations: const <Widget>[
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
            ]),
      ),
      body: screens[currentIndex],
    );
  }
}
