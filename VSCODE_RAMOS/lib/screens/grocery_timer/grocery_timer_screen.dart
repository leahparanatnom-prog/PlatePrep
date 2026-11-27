import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firestore_service.dart';
import 'grocery_section.dart';
import 'cooking_timer_section.dart';

class GroceryTimerScreen extends StatefulWidget {
  final String userId;
  final FirestoreService firestoreService;

  const GroceryTimerScreen({
    super.key,
    required this.userId,
    required this.firestoreService,
  });

  @override
  State<GroceryTimerScreen> createState() => _GroceryTimerScreenState();
}

class _GroceryTimerScreenState extends State<GroceryTimerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Grocery & Cooking Timer',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMedium,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              tabs: const [
                Tab(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Grocery List'),
                    ],
                  ),
                ),
                Tab(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Prep Timer'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Section A: Auto-Generated Grocery List
          GrocerySection(
            userId: widget.userId,
            firestoreService: widget.firestoreService,
          ),

          // Section B: Interactive Cooking Prep Timer
          const CookingTimerSection(),
        ],
      ),
    );
  }
}

