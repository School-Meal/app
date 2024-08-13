// import 'package:flutter/material.dart';
// import 'package:school_meal/screen/meal/meal_screen.dart';
// import 'package:school_meal/screen/post/post_screen.dart';
// import 'package:school_meal/screen/profile/edit_profile.dart';

// class MainNavigator extends StatefulWidget {
//   const MainNavigator({super.key});

//   @override
//   State<MainNavigator> createState() => _MainNavigatorState();
// }

// class _MainNavigatorState extends State<MainNavigator> {
//   int _selectedIndex = 0;

// final List<Widget> _navIndex = [
//   PostScreen(),
//   MealScreen(),
//   ProfileScreen(),
// ];

// void _onNavTapped(int index) {
//   setState(() {
//     _selectedIndex = index;
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _navIndex.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         fixedColor: Colors.blue,
//         unselectedItemColor: Colors.blueGrey,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.home_filled),
//           //   label: '홈',
//           //   backgroundColor: Colors.white,
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.post_add),
//             label: '게시물',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.food_bank),
//             label: '음식',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: '내 정보',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onNavTapped,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:school_meal/screen/meal/meal_screen.dart';
import 'package:school_meal/screen/post/post_screen.dart';
import 'package:school_meal/screen/profile/profile_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _navIndex = [
    PostScreen(),
    MealScreen(),
    ProfileScreen(),
  ];

  // 게시물, 급식표, 프로필

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navIndex.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: '게시물',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: '음식',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
