import 'package:dio/dio.dart';
import 'package:road_hero/core/utils/local_storage.dart';
import 'package:road_hero/features/auth/data/models/user_model.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';

class HomeRemoteSource {
  final Dio dio;
  HomeRemoteSource(this.dio);

  Future<UserModel> getProfile() async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'users/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserModel.fromJson(response.data['data']);
  }

  Future<List<ProviderModel>> getNearbyProviders({
    bool? isOnline,
    int? serviceTypeId,
  }) async {
    final token = await LocalStorage.getToken();
    try {
      final Map<String, dynamic> queryParams = {
        'lat': 9.0192,
        'lng': 38.7525,
        'radius_km': 100,
      };
      if (isOnline != null) queryParams['is_online'] = isOnline;
      if (serviceTypeId != null) queryParams['service_type_id'] = serviceTypeId;

      final response = await dio.get(
        'providers/nearby',
        queryParameters: queryParams,
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

  // UPDATED: Now accepts vehicleId and uses destination coordinates
  Future<int> createRequest({
    required int providerId,
    required int vehicleId, // New required field
    required String issueDescription,
    required double lat,
    required double lng,
  }) async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.post(
        'requests/',
        data: {
          "provider_id": providerId,
          "service_type_id": 1,
          "vehicle_id": vehicleId, // Using the real ID now
          "pickup_lat": lat,
          "pickup_lng": lng,
          "destination_lat": lat + 0.001, // Required by some backends
          "destination_lng": lng + 0.001,
          "issue_description": issueDescription,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data']['id'];
    } on DioException catch (e) {
      print("CREATE REQUEST ERROR: ${e.response?.data}");
      throw Exception(
        e.response?.data['message'] ?? "Request failed. Try again.",
      );
    }
  }

  Future<List<dynamic>> getMyRequests() async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'requests/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> diagnoseIssue(String description) async {
    final token = await LocalStorage.getToken();
    final response = await dio.post(
      'ai/diagnose',
      data: {"issue_description": description},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'];
  }
}
