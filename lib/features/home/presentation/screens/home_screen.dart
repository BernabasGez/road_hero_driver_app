import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_hero/features/home/presentation/bloc/cart_cubit.dart';
import 'package:road_hero/core/widgets/app_button.dart'; // REQUIRED IMPORT
import 'package:road_hero/core/theme/app_colors.dart';
import 'home_tab.dart';
import 'explore_screen.dart';
import 'activity_tab.dart';
import 'profile_tab.dart';
import 'ai_diagnostic_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            onExploreTap: () => setState(() => _currentIndex = 1),
            onAiTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiDiagnosticScreen()),
            ),
          ),
          const ExploreScreen(),
          const ActivityTab(),
          const ProfileTab(),
        ],
      ),
      floatingActionButton: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showCartSummary(context, state),
            backgroundColor: AppColors.actionOrange,
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              "Cart: ${state.totalCartPrice.toStringAsFixed(0)} ETB",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _showCartSummary(BuildContext context, CartState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Your Order",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...state.items.map(
              (item) => ListTile(
                title: Text(item.name),
                trailing: Text(
                  "${item.quantity} x ${item.price.toStringAsFixed(0)} ETB",
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${state.totalCartPrice.toStringAsFixed(0)} ETB",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              label: "Clear Cart",
              variant: AppButtonVariant.secondary,
              onPressed: () {
                context.read<CartCubit>().clearCart();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
