import 'package:dio/dio.dart';
import 'package:road_hero/core/utils/local_storage.dart';
import 'package:road_hero/features/home/data/models/vehicle_model.dart';

class ProfileRemoteSource {
  final Dio dio;
  ProfileRemoteSource(this.dio);

  Future<void> updateProfile(String name) async {
    final token = await LocalStorage.getToken();
    await dio.put(
      'users/me',
      data: {"full_name": name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<VehicleModel>> getVehicles() async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.get(
        'vehicles/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // CRITICAL DEBUG: Look at your VS Code Terminal for this line!
      print("DEBUG: VEHICLE SERVER RESPONSE -> ${response.data}");

      final dynamic body = response.data;
      List<dynamic> listData = [];

      // Logic to find the list regardless of how deep it is hidden
      if (body is List) {
        listData = body;
      } else if (body is Map) {
        // Look inside 'data', then 'results' (Common in your backend)
        var possibleList = body['data'];
        if (possibleList is List) {
          listData = possibleList;
        } else if (possibleList is Map && possibleList['results'] is List) {
          listData = possibleList['results'];
        } else if (body['results'] is List) {
          listData = body['results'];
        }
      }

      print("DEBUG: FOUND ${listData.length} VEHICLES");
      return listData.map((json) => VehicleModel.fromJson(json)).toList();
    } catch (e) {
      print("VEHICLE FETCH ERROR: $e");
      return [];
    }
  }

  Future<List<dynamic>> getVehicleMakes() async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'meta/vehicle-makes',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] ?? [];
  }

  Future<void> addVehicle({
    required int makeId,
    required String plate,
    required int year,
  }) async {
    final token = await LocalStorage.getToken();
    try {
      await dio.post(
        'vehicles/',
        data: {
          "make_id": makeId,
          "model_id": 1,
          "year": year,
          "plate_number": plate,
          "color": "White",
          "is_primary": true,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception("Failed to add vehicle");
    }
  }
}
