import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.record_voice_over),
            label: 'Voice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'IoT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppConstants.routeHome)) {
      return 0;
    }
    if (location.startsWith(AppConstants.routeVoiceAgent)) {
      return 1;
    }
    if (location.startsWith(AppConstants.routeIoTDashboard)) {
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
        context.go(AppConstants.routeVoiceAgent);
        break;
      case 2:
        context.go(AppConstants.routeIoTDashboard);
        break;
      case 3:
        context.go(AppConstants.routeProfile);
        break;
    }
  }
}
