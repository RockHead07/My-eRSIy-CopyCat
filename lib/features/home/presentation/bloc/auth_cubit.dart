import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class AuthState extends Equatable {
  const AuthState({
    this.isAuthenticated = false,
    this.fullName = 'Tamu',
    this.email,
    this.token,
  });

  final bool isAuthenticated;
  final String fullName;
  final String? email;
  final String? token;

  AuthState copyWith({
    bool? isAuthenticated,
    String? fullName,
    String? email,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, fullName, email, token];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  void login({
    required String fullName,
    String? email,
    String? token,
  }) {
    emit(AuthState(
      isAuthenticated: true,
      fullName: fullName.trim().isEmpty ? 'Tamu' : fullName.trim(),
      email: email,
      token: token,
    ));
  }

  void logout() {
    emit(const AuthState());
  }
}
