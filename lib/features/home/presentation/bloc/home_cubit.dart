import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/vehicle_model.dart';

// ─── State ────────────────────────────────────────────
class HomeState {
  final UserModel? user;
  final List<VehicleModel> vehicles;
  final List<Map<String, dynamic>> serviceTypes;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.user,
    this.vehicles = const [],
    this.serviceTypes = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    UserModel? user,
    List<VehicleModel>? vehicles,
    List<Map<String, dynamic>>? serviceTypes,
    bool? isLoading,
    String? error,
  }) => HomeState(
        user: user ?? this.user,
        vehicles: vehicles ?? this.vehicles,
        serviceTypes: serviceTypes ?? this.serviceTypes,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Cubit ────────────────────────────────────────────
class HomeCubit extends Cubit<HomeState> {
  final HomeRemoteSource _remote;

  HomeCubit(this._remote) : super(const HomeState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _remote.getProfile(),
        _remote.getVehicles(),
        _remote.getServiceTypes(),
      ]);

      emit(state.copyWith(
        user: results[0] as UserModel,
        vehicles: results[1] as List<VehicleModel>,
        serviceTypes: results[2] as List<Map<String, dynamic>>,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _remote.getProfile();
      emit(state.copyWith(user: user));
    } catch (_) {}
  }

  Future<void> refreshVehicles() async {
    try {
      final vehicles = await _remote.getVehicles();
      emit(state.copyWith(vehicles: vehicles));
    } catch (_) {}
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
