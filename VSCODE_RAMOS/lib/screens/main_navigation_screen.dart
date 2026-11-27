import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'meals/meal_manager_screen.dart';
import 'grocery_timer/grocery_timer_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String userId;
  final AuthService authService;
  final FirestoreService firestoreService;

  const MainNavigationScreen({
    super.key,
    required this.userId,
    required this.authService,
    required this.firestoreService,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: widget.firestoreService.getUserProfileStream(widget.userId),
      builder: (context, userSnapshot) {
        final userProfile = userSnapshot.data;

        final screens = [
          DashboardScreen(
            userId: widget.userId,
            userProfile: userProfile,
            firestoreService: widget.firestoreService,
            onNavigateToMeals: () => _navigateToTab(1),
            onNavigateToGrocery: () => _navigateToTab(2),
          ),
          MealManagerScreen(
            userId: widget.userId,
            firestoreService: widget.firestoreService,
          ),
          GroceryTimerScreen(
            userId: widget.userId,
            firestoreService: widget.firestoreService,
          ),
          ProfileScreen(
            userProfile: userProfile,
            authService: widget.authService,
            firestoreService: widget.firestoreService,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _navigateToTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  activeIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  activeIcon: Icon(Icons.restaurant_menu_rounded, color: AppColors.primary),
                  label: 'Meals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
                  label: 'Grocery & Timer',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

