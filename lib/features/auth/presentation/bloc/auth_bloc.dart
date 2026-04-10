import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../data/repositories/auth_remote_source.dart';
import '../../../../core/di/injection_container.dart';

abstract class AuthEvent {}

class SignUpSubmitted extends AuthEvent {
  final String name, phone, password;
  SignUpSubmitted(this.name, this.phone, this.password);
}

class VerifyOtpSubmitted extends AuthEvent {
  final String phone, otp;
  VerifyOtpSubmitted(this.phone, this.otp);
}

class LoginSubmitted extends AuthEvent {
  final String phone, password;
  LoginSubmitted(this.phone, this.password);
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);
}

class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;

  AuthBloc({required this.registerUseCase}) : super(AuthInitial()) {
    on<SignUpSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await registerUseCase(
          RegisterParams(
            fullName: event.name,
            phoneNumber: event.phone,
            password: event.password,
          ),
        );
        emit(AuthSuccess("OTP Sent Successfully!"));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll("Exception: ", "")));
      }
    });

    on<VerifyOtpSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await sl<AuthRemoteSource>().verifyOtp(
          phone: event.phone,
          otp: event.otp,
        );
        emit(AuthSuccess("Verification Successful!"));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll("Exception: ", "")));
      }
    });

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await sl<AuthRemoteSource>().login(
          phone: event.phone,
          password: event.password,
        );
        emit(AuthSuccess("Login Successful!"));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll("Exception: ", "")));
      }
    });
  }
}
