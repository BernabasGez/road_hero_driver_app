import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Events ───────────────────────────────────────────
sealed class AuthEvent {}

class CheckSession extends AuthEvent {}

class RegisterSubmitted extends AuthEvent {
  final String phone;
  final String name;
  final String password;
  final Map<String, dynamic>? vehicle;
  RegisterSubmitted({required this.phone, required this.name, required this.password, this.vehicle});
}

class VerifyOtpSubmitted extends AuthEvent {
  final String phone;
  final String otp;
  VerifyOtpSubmitted({required this.phone, required this.otp});
}

class LoginSubmitted extends AuthEvent {
  final String phone;
  final String password;
  LoginSubmitted({required this.phone, required this.password});
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordSubmitted extends AuthEvent {
  final String phone;
  ForgotPasswordSubmitted({required this.phone});
}

class ResetPasswordSubmitted extends AuthEvent {
  final String phone;
  final String otp;
  final String newPassword;
  ResetPasswordSubmitted({required this.phone, required this.otp, required this.newPassword});
}

// ─── States ───────────────────────────────────────────
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {}
class Unauthenticated extends AuthState {}

class RegistrationSuccess extends AuthState {
  final String phone;
  RegistrationSuccess(this.phone);
}

class OtpVerified extends AuthState {}

class ForgotPasswordSent extends AuthState {
  final String phone;
  ForgotPasswordSent(this.phone);
}

class PasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ─── Bloc ─────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<CheckSession>(_onCheckSession);
    on<RegisterSubmitted>(_onRegister);
    on<VerifyOtpSubmitted>(_onVerifyOtp);
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
    on<ForgotPasswordSubmitted>(_onForgotPassword);
    on<ResetPasswordSubmitted>(_onResetPassword);
  }

  Future<void> _onCheckSession(CheckSession event, Emitter<AuthState> emit) async {
    final hasSession = await repository.hasSession();
    emit(hasSession ? Authenticated() : Unauthenticated());
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.register(
        phone: event.phone,
        name: event.name,
        password: event.password,
        vehicle: event.vehicle,
      );
      emit(RegistrationSuccess(event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.verifyOtp(phone: event.phone, otp: event.otp);
      emit(OtpVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.login(phone: event.phone, password: event.password);
      emit(Authenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await repository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onForgotPassword(ForgotPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.forgotPassword(phone: event.phone);
      emit(ForgotPasswordSent(event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(ResetPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.resetPassword(
        phone: event.phone,
        otp: event.otp,
        newPassword: event.newPassword,
      );
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
