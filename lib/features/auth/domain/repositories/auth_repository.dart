import '../usecases/register_usecase.dart';

abstract class AuthRepository {
  Future<void> register(RegisterParams params);
}
