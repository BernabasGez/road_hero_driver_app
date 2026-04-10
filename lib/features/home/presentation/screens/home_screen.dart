import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/home_remote_source.dart';
import '../../../auth/data/models/user_model.dart';
import 'virtual_mechanic_screen.dart'; // THIS WAS THE MISSING IMPORT

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await sl<HomeRemoteSource>().getProfile();
      if (mounted) {
        setState(() {
          user = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Error: $errorMessage", textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      drawer: const Drawer(),
      body: Stack(
        children: [
          // 1. MAP BACKGROUND
          Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: Icon(Icons.map, size: 100, color: Colors.grey),
            ),
          ),

          // 2. TOP LOCATION BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Bole, Addis Ababa",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. BOTTOM SHEET CONTENT
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good morning, ${user?.fullName.split(' ')[0] ?? 'User'}!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // AI ASSISTANT BANNER
                  _buildAIBanner(),

                  const SizedBox(height: 24),

                  // SERVICE GRID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _serviceItem(Icons.local_shipping, "Towing"),
                      _serviceItem(Icons.build, "Repair"),
                      _serviceItem(Icons.tire_repair, "Tire"),
                      _serviceItem(Icons.local_gas_station, "Fuel"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildAIBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VirtualMechanicScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hear a strange noise? Ask AI.",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Instant diagnosis.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _serviceItem(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.withOpacity(0.05),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
