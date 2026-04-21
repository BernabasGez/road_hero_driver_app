import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/vehicle_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/home_cubit.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final user = state.user;
        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  MediaQuery.of(context).padding.top + 16,
                  AppDimensions.screenPadding,
                  AppDimensions.lg,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Driver',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phoneNumber ?? '',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
            // Menu items
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Column(
                  children: [
                    _MenuSection(
                      title: 'Account',
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          label: 'Edit Profile',
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => _EditProfileScreen(user: user),
                          )),
                        ),
                        _MenuItem(
                          icon: Icons.directions_car_outlined,
                          label: 'My Vehicles',
                          subtitle: '${state.vehicles.length} vehicles',
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => _VehiclesScreen(),
                          )),
                        ),
                        _MenuItem(
                          icon: Icons.favorite_border,
                          label: 'Favorite Garages',
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => _FavoritesScreen(),
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _MenuSection(
                      title: 'Settings',
                      items: [
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => _NotificationsScreen(),
                          )),
                        ),
                        _MenuItem(
                          icon: Icons.language_outlined,
                          label: 'Language',
                          subtitle: user?.language ?? 'English',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _MenuSection(
                      title: '',
                      items: [
                        _MenuItem(
                          icon: Icons.logout,
                          label: 'Sign Out',
                          color: AppColors.error,
                          onTap: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xxl),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppDimensions.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              final item = e.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: item.color ?? AppColors.primary, size: 22),
                    title: Text(item.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: item.color,
                          fontWeight: FontWeight.w500,
                        )),
                    subtitle: item.subtitle != null
                        ? Text(item.subtitle!, style: AppTextStyles.caption)
                        : null,
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.subtitle, this.color, this.onTap});
}

// ─── Sub-screens ─────────────────────────────────────
class _EditProfileScreen extends StatefulWidget {
  final UserModel? user;
  const _EditProfileScreen({this.user});

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.fullName ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await sl<HomeRemoteSource>().updateProfile({
        'full_name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
      });
      if (mounted) {
        context.read<HomeCubit>().refreshProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          children: [
            AppTextField(controller: _nameCtrl, label: 'Full Name'),
            const SizedBox(height: AppDimensions.md),
            AppTextField(controller: _emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: AppDimensions.lg),
            AppButton(label: 'Save', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _VehiclesScreen extends StatefulWidget {
  @override
  State<_VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<_VehiclesScreen> {
  List<VehicleModel> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await sl<HomeRemoteSource>().getVehicles();
      setState(() {
        _vehicles = v;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    try {
      await sl<HomeRemoteSource>().deleteVehicle(id);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => _AddVehicleScreen(onAdded: _load),
            )),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? Center(
                  child: AppButton(
                    label: 'Add Your First Vehicle',
                    width: 220,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => _AddVehicleScreen(onAdded: _load),
                    )),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  itemCount: _vehicles.length,
                  itemBuilder: (_, i) {
                    final v = _vehicles[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(AppDimensions.cardPadding),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_car_outlined, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.displayName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                Text(v.plateNumber, style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete vehicle?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                                  ],
                                ),
                              );
                              if (confirm == true) _delete(v.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddVehicleScreen extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddVehicleScreen({required this.onAdded});

  @override
  State<_AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<_AddVehicleScreen> {
  List<Map<String, dynamic>> _makes = [];
  List<Map<String, dynamic>> _models = [];
  int? _selectedMakeId;
  int? _selectedModelId;
  final _plateCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMakes();
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMakes() async {
    try {
      _makes = await sl<HomeRemoteSource>().getVehicleMakes();
      setState(() {});
    } catch (_) {}
  }

  Future<void> _loadModels(int makeId) async {
    try {
      _models = await sl<HomeRemoteSource>().getVehicleModels(makeId);
      setState(() {});
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_plateCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await sl<HomeRemoteSource>().addVehicle({
        'plate_number': _plateCtrl.text.trim(),
        if (_selectedMakeId != null) 'make_id': _selectedMakeId,
        if (_selectedModelId != null) 'model_id': _selectedModelId,
        if (_yearCtrl.text.isNotEmpty) 'year': int.tryParse(_yearCtrl.text),
      });
      widget.onAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          children: [
            // Make
            const Text('Make', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButton<int>(
                value: _selectedMakeId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Select make'),
                items: _makes.map((m) => DropdownMenuItem(value: m['id'] as int, child: Text(m['name'] ?? ''))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedMakeId = v;
                    _selectedModelId = null;
                    _models = [];
                  });
                  if (v != null) _loadModels(v);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Model
            const Text('Model', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButton<int>(
                value: _selectedModelId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Select model'),
                items: _models.map((m) => DropdownMenuItem(value: m['id'] as int, child: Text(m['name'] ?? ''))).toList(),
                onChanged: (v) => setState(() => _selectedModelId = v),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _plateCtrl, label: 'Plate Number', hint: 'e.g. 3-AA-12345'),
            const SizedBox(height: 16),
            AppTextField(controller: _yearCtrl, label: 'Year (optional)', hint: 'e.g. 2020', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            AppButton(label: 'Save Vehicle', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _FavoritesScreen extends StatefulWidget {
  @override
  State<_FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<_FavoritesScreen> {
  List _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _favorites = await sl<HomeRemoteSource>().getFavorites();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Garages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('No favorites yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  itemCount: _favorites.length,
                  itemBuilder: (_, i) {
                    final p = _favorites[i];
                    return ListTile(
                      leading: const Icon(Icons.store, color: AppColors.primary),
                      title: Text(p.businessName),
                      subtitle: Text(p.address ?? ''),
                    );
                  },
                ),
    );
  }
}

class _NotificationsScreen extends StatefulWidget {
  @override
  State<_NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<_NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _notifications = await sl<HomeRemoteSource>().getNotifications();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await sl<HomeRemoteSource>().markAllNotificationsRead();
              _load();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = _notifications[i];
                    final isRead = n['is_read'] == true;
                    return ListTile(
                      leading: Icon(
                        Icons.notifications_outlined,
                        color: isRead ? AppColors.textHint : AppColors.primary,
                      ),
                      title: Text(
                        n['title'] ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(n['message'] ?? '', style: AppTextStyles.caption),
                      onTap: () async {
                        if (!isRead && n['id'] != null) {
                          await sl<HomeRemoteSource>().markNotificationRead(n['id']);
                          _load();
                        }
                      },
                    );
                  },
                ),
    );
  }
}
