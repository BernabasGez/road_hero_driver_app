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

  Future<List<ProviderModel>> getNearbyProviders() async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.get(
        'providers/nearby',
        queryParameters: {'lat': 9.019, 'lng': 38.75, 'radius_km': 50},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(
        "RAW API DATA: ${response.data}",
      ); // This helps us see what the server sent

      // FIX: Check if the data is inside a Map or is a direct List
      var rawData = response.data['data'];

      List<dynamic> listToParse = [];

      if (rawData is List) {
        listToParse = rawData;
      } else if (rawData is Map && rawData.containsKey('results')) {
        // Some backends put the list inside a 'results' key
        listToParse = rawData['results'];
      } else {
        // If it is just an empty Map or something else
        return [];
      }

      return listToParse.map((json) => ProviderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print("GARAGE FETCH ERROR: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Connection Error");
    }
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
