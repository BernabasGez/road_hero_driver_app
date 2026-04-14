import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/core/utils/local_storage.dart';
import 'package:road_hero/features/home/data/repositories/profile_remote_source.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';
import 'package:road_hero/features/auth/data/models/user_model.dart';
import 'package:road_hero/features/home/data/models/vehicle_model.dart';
import 'package:road_hero/features/auth/presentation/screens/auth_entry_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  List<VehicleModel> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final userData = await sl<HomeRemoteSource>().getProfile();
      final vehicleData = await sl<ProfileRemoteSource>().getVehicles();
      if (mounted)
        setState(() {
          user = userData;
          vehicles = vehicleData;
          isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleLogout() async {
    await LocalStorage.clear(); // Wipe the keys
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthEntryScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? "User",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.phoneNumber ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildSection("Vehicles", Icons.directions_car),
            ...vehicles.map(
              (v) => ListTile(
                title: Text("${v.make} ${v.model}"),
                subtitle: Text(v.plateNumber),
              ),
            ),
            const Divider(height: 40),
            _buildSection("Settings", Icons.settings),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text("Support & FAQ"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String t, IconData i) => Row(
    children: [
      Icon(i, size: 18, color: AppColors.primaryBlue),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

// Minimal Support Screen for Figma 16.0
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const Center(child: Text("Support Center Coming Soon")),
    );
  }
}
