import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../models/provider_model.dart';
import '../models/vehicle_model.dart';
import '../models/service_request_model.dart';
import '../../../auth/data/models/user_model.dart';

class HomeRemoteSource {
  final Dio dio;
  HomeRemoteSource(this.dio);

  // ─── Profile ────────────────────────────────────
  Future<UserModel> getProfile() async {
    try {
      final r = await dio.get('users/me');
      final data = r.data['data'] ?? r.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> body) async {
    try {
      final r = await dio.put('users/me', data: body);
      final data = r.data['data'] ?? r.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Settings ───────────────────────────────────
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final r = await dio.get('users/me/settings');
      return Map<String, dynamic>.from(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> updateSettings(Map<String, dynamic> body) async {
    try {
      await dio.patch('users/me/settings', data: body);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Providers ──────────────────────────────────
  Future<List<ProviderModel>> getNearbyProviders({
    required double lat,
    required double lng,
    double? radiusKm,
    bool? isOnline,
    int? serviceTypeId,
    double? minRating,
    String? sortBy,
  }) async {
    try {
      final params = <String, dynamic>{'lat': lat, 'lng': lng};
      if (radiusKm != null) params['radius_km'] = radiusKm;
      if (isOnline != null) params['is_online'] = isOnline;
      if (serviceTypeId != null) params['service_type_id'] = serviceTypeId;

      final r = await dio.get('providers/nearby', queryParameters: params);

      // FIX: Access 'results' inside 'data'
      final dynamic responseData = r.data['data'];
      if (responseData != null && responseData['results'] is List) {
        final List list = responseData['results'];
        return list.map((e) => ProviderModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<ProviderModel> getProviderDetail(int id) async {
    try {
      final r = await dio.get('providers/$id');
      final data = r.data['data'] ?? r.data;
      return ProviderModel.fromJson(data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<List<Map<String, dynamic>>> getProviderSpareParts(
    int providerId, {
    String? search,
    String? category,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null) params['search'] = search;
      if (category != null) params['category'] = category;

      // 1. Ensure the URL matches your Postman structure (no trailing slash)
      final r = await dio.get(
        'providers/$providerId/spare-parts',
        queryParameters: params,
      );

      // 2. Debug print to see the exact structure if it still fails
      print("DEBUG SPARE PARTS DATA: ${r.data}");

      // 3. Robust parsing logic (checks for 'results' key)
      final dynamic responseBody = r.data;
      List<dynamic> items = [];

      if (responseBody['data'] != null) {
        if (responseBody['data'] is List) {
          items = responseBody['data'];
        } else if (responseBody['data']['results'] is List) {
          items = responseBody['data']['results'];
        }
      } else if (responseBody is List) {
        items = responseBody;
      }

      return items.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Vehicles ───────────────────────────────────
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final r = await dio.get('vehicles/');
      final list = r.data['data'] ?? r.data;
      if (list is List) {
        return list.map((e) => VehicleModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<VehicleModel> addVehicle(Map<String, dynamic> body) async {
    try {
      final r = await dio.post('vehicles/', data: body);
      return VehicleModel.fromJson(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<VehicleModel> updateVehicle(int id, Map<String, dynamic> body) async {
    try {
      final r = await dio.put('vehicles/$id', data: body);
      return VehicleModel.fromJson(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> deleteVehicle(int id) async {
    try {
      await dio.delete('vehicles/$id');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Meta ───────────────────────────────────────
  Future<List<Map<String, dynamic>>> getVehicleMakes() async {
    try {
      final r = await dio.get('meta/vehicle-makes');
      final data = r.data['data'] ?? r.data;
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<List<Map<String, dynamic>>> getVehicleModels(int makeId) async {
    try {
      final r = await dio.get('meta/vehicle-makes/$makeId/models');
      final data = r.data['data'] ?? r.data;
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<List<Map<String, dynamic>>> getServiceTypes() async {
    try {
      final r = await dio.get('meta/service-types');
      final data = r.data['data'] ?? r.data;
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Service Requests ──────────────────────────
  Future<ServiceRequestModel> createRequest({
    required int providerId,
    required int serviceTypeId,
    required int vehicleId,
    required String description,
    required double lat,
    required double lng,
    String? address,
    bool isScheduled = false,
    String? scheduledTime,
    File? photo,
  }) async {
    try {
      // The backend expects "location" as a stringified JSON object in the form-data
      final locationData =
          '{"lat": $lat, "lng": $lng, "address": "${address ?? "Current Location"}"}';

      final formData = FormData.fromMap({
        'provider_id': providerId,
        'service_type_id': serviceTypeId,
        'vehicle_id': vehicleId,
        'description': description,
        'is_scheduled': isScheduled, // True/False
        'location': locationData, // JSON string matches curl example
        if (isScheduled && scheduledTime != null)
          'scheduled_time': scheduledTime,
        if (photo != null)
          'photo': await MultipartFile.fromFile(
            photo.path,
            filename: 'incident_photo.jpg',
          ),
      });

      final r = await dio.post('requests/', data: formData);
      return ServiceRequestModel.fromJson(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<List<ServiceRequestModel>> getRequests({String? statusGroup}) async {
    try {
      final params = <String, dynamic>{};
      if (statusGroup != null) params['status_group'] = statusGroup;

      final r = await dio.get('requests/', queryParameters: params);
      final list = r.data['data'] ?? r.data;
      if (list is List) {
        return list.map((e) => ServiceRequestModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<ServiceRequestModel> getRequestDetail(int id) async {
    try {
      final r = await dio.get('requests/$id');
      return ServiceRequestModel.fromJson(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<Map<String, dynamic>> getRequestTracking(int id) async {
    try {
      final r = await dio.get('requests/$id/tracking');
      return Map<String, dynamic>.from(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> cancelRequest(int id, {String? reason}) async {
    try {
      // CHANGE dio.post to dio.patch
      await dio.patch(
        'requests/$id/cancel',
        data: {if (reason != null) 'reason': reason},
      );
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<ServiceRequestModel> rebookRequest(
    int id, {
    required int newProviderId,
  }) async {
    try {
      final r = await dio.post(
        'requests/$id/rebook',
        data: {'new_provider_id': newProviderId},
      );
      return ServiceRequestModel.fromJson(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> submitReview({
    required int requestId,
    required int rating,
    required List<String> tags,
    String? comment,
  }) async {
    try {
      // Removed the / at the end of reviews to fix the 404 error
      await dio.post(
        'requests/$requestId/reviews',
        data: {'rating': rating, 'tags': tags, 'comment': comment ?? ""},
      );
    } on DioException catch (e) {
      // Log details if it fails so we can see the server response
      print("SERVER ERROR: ${e.response?.data}");
      String msg = "Failed to submit review";
      if (e.response?.data is Map) {
        msg = e.response?.data['message'] ?? msg;
      }
      throw Exception(msg);
    }
  }

  // ─── AI ─────────────────────────────────────────
  Future<Map<String, dynamic>> diagnose({
    required String symptoms,
    int? vehicleId,
  }) async {
    try {
      final r = await dio.post(
        'ai/diagnose',
        data: {
          'symptoms': symptoms,
          if (vehicleId != null) 'vehicle_id': vehicleId,
        },
      );
      return Map<String, dynamic>.from(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Favorites ──────────────────────────────────
  Future<List<ProviderModel>> getFavorites() async {
    try {
      final r = await dio.get('favorites/');
      final list = r.data['data'] ?? r.data;
      if (list is List) {
        return list.map((e) => ProviderModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> addFavorite(int providerId) async {
    try {
      await dio.post('favorites/', data: {'provider_id': providerId});
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> removeFavorite(int providerId) async {
    try {
      await dio.delete('favorites/$providerId');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Notifications ─────────────────────────────
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final r = await dio.get('notifications/');
      final list = r.data['data'] ?? r.data;
      if (list is List) return list.cast<Map<String, dynamic>>();
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await dio.patch('notifications/$id/read');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await dio.patch('notifications/read-all');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Upload ─────────────────────────────────────
  Future<String> uploadFile(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final r = await dio.post(
        'utils/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = r.data['data'] ?? r.data;
      return data['url'] ?? data['file_url'] ?? '';
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Payment ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final r = await dio.get('users/me/payment-methods');
      final data = r.data['data'] ?? r.data;
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<Map<String, dynamic>> initiateTelebirr(String phone) async {
    try {
      final r = await dio.post(
        'users/me/payment-methods/telebirr/initiate',
        data: {'phone_number': phone},
      );
      return Map<String, dynamic>.from(r.data['data'] ?? r.data);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> verifyTelebirr(String otp) async {
    try {
      await dio.post(
        'users/me/payment-methods/telebirr/verify',
        data: {'otp': otp},
      );
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<String> initiateChapaPayment(int requestId, double amount) async {
    try {
      final r = await dio.post(
        'requests/$requestId/pay/chapa',
        data: {'amount': amount, 'return_url': 'roadhero://payment-complete'},
      );
      final data = r.data['data'];
      return data['checkout_url']; // Redirect user to this URL
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> confirmManualPayment(int requestId, double amount) async {
    try {
      await dio.post(
        'requests/$requestId/pay/manual',
        data: {'amount': amount},
      );
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Helpers ────────────────────────────────────
  ServerException _err(DioException e) {
    String msg = 'Request failed. Please try again.';
    if (e.response?.data is Map) {
      msg = e.response?.data['message'] ?? msg;
    }
    if (e.error is ServerException) return e.error as ServerException;
    AppLogger.error('API Error', e);
    return ServerException(msg, statusCode: e.response?.statusCode);
  }

  Future<List<Map<String, dynamic>>> getProviderReviews(int providerId) async {
    try {
      final r = await dio.get('providers/$providerId/reviews');
      final dynamic responseBody = r.data;
      List<dynamic> items = [];

      if (responseBody['data'] != null) {
        items = responseBody['data'] is List
            ? responseBody['data']
            : responseBody['data']['results'] ?? [];
      }
      return items.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> submitGarageReview({
    required int providerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await dio.post(
        'providers/$providerId/reviews/',
        data: {'rating': rating, 'comment': comment ?? ""},
      );
      // Verbose logging for debugging
      print("✅ REVIEW SUCCESS: ${response.data}");
    } on DioException catch (e) {
      // 🚨 THIS PRINTS THE EXACT BACKEND ERROR TO YOUR TERMINAL
      print("❌ SERVER ERROR DATA: ${e.response?.data}");
      print("❌ STATUS CODE: ${e.response?.statusCode}");

      String errorMsg = "Submission failed";
      if (e.response?.data is Map) {
        // Many backends put errors in 'detail' or 'error' keys
        errorMsg =
            e.response?.data['message'] ??
            e.response?.data['detail'] ??
            e.response?.data['error'] ??
            errorMsg;
      }
      throw Exception(errorMsg);
    }
  }
}
