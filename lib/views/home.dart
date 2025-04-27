import 'package:color_shade/color_shade.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  final Function(int)? onTabChange;
  const Homepage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 100,
            color: Theme.of(context).primaryColor.shade100,
          ),
          SizedBox(height: 20),
          Text(
            '디미플랜',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor.shade100,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '당신의 계획을 관리하세요',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor.shade100,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to planner tab
              if (onTabChange != null) {
                onTabChange!(1);
              } else {
                // Fallback if onTabChange is not provided
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tab navigation not configured')),
                );
              }
            },
            icon: Icon(Icons.list_alt_rounded),
            label: Text('플래너로 이동'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
