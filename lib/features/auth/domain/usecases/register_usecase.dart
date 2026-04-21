import '../repositories/auth_repository.dart'; // This is the missing import

class RegisterParams {
  final String phoneNumber;
  final String fullName;
  final String password;

  RegisterParams({
    required this.phoneNumber,
    required this.fullName,
    required this.password,
  });
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<void> call(RegisterParams params) {
    return repository.register(
      phone: params.phoneNumber,
      name: params.fullName,
      password: params.password,
    );
  }
}
