import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class MainScreen extends StatelessWidget {

  const MainScreen({
    required this.child, super.key,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Registro de actividad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'My Toys',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppConstants.routeHome)) {
      return 0;
    }
    if (location.startsWith(AppConstants.routeActivityLog)) {
      return 1;
    }
    if (location.startsWith(AppConstants.routeMyToys)) {
      return 2;
    }
    if (location.startsWith(AppConstants.routeProfile)) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppConstants.routeHome);
        break;
      case 1:
        context.go(AppConstants.routeActivityLog);
        break;
      case 2:
        context.go(AppConstants.routeMyToys);
        break;
      case 3:
        context.go(AppConstants.routeProfile);
        break;
    }
  }
}
