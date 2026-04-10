import 'package:dio/dio.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/utils/local_storage.dart';

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

  Future<Map<String, dynamic>> diagnoseIssue(String description) async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.post(
        'ai/diagnose',
        data: {"issue_description": description},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // This returns {ai_response, requires_mechanic, recommended_service_type}
      return response.data['data'];
    } on DioException catch (e) {
      print("AI API ERROR: ${e.response?.data}");
      throw Exception(
        "The AI is taking too long. Please try again with better signal.",
      );
    }
  }
}
