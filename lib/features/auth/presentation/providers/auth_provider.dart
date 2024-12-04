// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/key_value_storage_service_impl.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageService: keyValueStorageService
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({ 
    required this.authRepository,
    required this.keyValueStorageService
  }): super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> _setLoggedUser(User user) async {
    await keyValueStorageService.setKeyValue('token', user.token);

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: ''
    );
  }

  Future<void> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } on WrongCredentials {
      logout('Credenciales no son correctas');
    } on ConnectionTimeout {
      logout('Timeout');
    } on CustomError catch (e) {
      logout('Custom error: ${e.message}, error code: ${e.errorCode}');
    } catch (e) {
      logout('Error no controlado');
    }
  }

  Future<void> registerUser(String email, String password, String fullname) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final response = await authRepository.register(email, password, fullname);
      
      print('=====REGISTRO COMPLETADO=====');
      print('Token: ${response.token}');
    } on WrongCredentials {
      logout('Credenciales incorrectas');
    } on ConnectionTimeout {
      logout('Timeout');
    } on CustomError catch (e) {
      logout('${e.message}, ${e.errorCode}');
    } catch (e) {
      logout('Unknowing error');
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if(token == null) return logout();

    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorageService.removeKey('token');

    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: errorMessage
    );
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState({
    this.authStatus = AuthStatus.checking, 
    this.user, 
    this.errorMessage = ''
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage
  );

}