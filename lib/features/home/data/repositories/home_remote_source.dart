import 'package:dio/dio.dart';
import 'package:road_hero/core/utils/local_storage.dart';
import 'package:road_hero/features/auth/data/models/user_model.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';

class HomeRemoteSource {
  final Dio dio;
  HomeRemoteSource(this.dio);

  // 1. Fetch User Profile
  Future<UserModel> getProfile() async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'users/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserModel.fromJson(response.data['data']);
  }

  // 2. Fetch Garages with Local-Friendly Coordinates
  Future<List<ProviderModel>> getNearbyProviders() async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.get(
        'providers/nearby',
        queryParameters: {'lat': 9.0192, 'lng': 38.7525, 'radius_km': 100},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final dynamic rawResults = response.data['data']['results'];
      if (rawResults is List)
        return rawResults.map((json) => ProviderModel.fromJson(json)).toList();
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. AI DIAGNOSIS (Powers the Virtual Mechanic Screen)
  Future<Map<String, dynamic>> diagnoseIssue(String description) async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.post(
        'ai/diagnose',
        data: {"issue_description": description},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception("AI is taking too long. Check your signal.");
    }
  }

  // 4. CREATE REQUEST (The checkmark screen)
  Future<int> createRequest({
    required int providerId,
    required int vehicleId,
    required String issueDescription,
    required double lat,
    required double lng,
  }) async {
    final token = await LocalStorage.getToken();
    final response = await dio.post(
      'requests/',
      data: {
        "provider_id": providerId,
        "service_type_id": 1,
        "vehicle_id": vehicleId,
        "pickup_lat": lat,
        "pickup_lng": lng,
        "destination_lat": lat + 0.001,
        "destination_lng": lng + 0.001,
        "issue_description": issueDescription,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data']['id'] ?? 0;
  }

  // 5. LIVE TRACKING POLLING (For the Tracking Screen)
  Future<Map<String, dynamic>> getLiveTracking(int requestId) async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.get(
        'requests/$requestId/tracking',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'];
    } catch (e) {
      // Return a default status if the tracking endpoint hasn't updated yet
      return {
        "status": "PENDING",
        "eta_minutes": 0,
        "technician_name": "Finding Mechanic...",
      };
    }
  }

  // 6. ACTIVITY LIST
  Future<List<dynamic>> getMyRequests() async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'requests/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] ?? [];
  }
}
