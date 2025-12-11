import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<UpdateUserEvent>(_onUpdateUser);
  }
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    print('DEBUG: AuthBloc._onLogin - Login event received');
    emit(AuthLoading());
    try {
      print('DEBUG: AuthBloc._onLogin - Calling authRepository.login');
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      final user = result['user'] as User;
      // Ensure token is saved before emitting authenticated state
      // The login method already saves the token, but we add a delay
      // to ensure SharedPreferences write is complete
      await Future.delayed(const Duration(milliseconds: 200));
      print('DEBUG: AuthBloc._onLogin - Login successful, emitting AuthAuthenticated');
      emit(AuthAuthenticated(user: user));
      print('DEBUG: AuthBloc._onLogin - AuthAuthenticated state emitted');
    } catch (e) {
      print('DEBUG: AuthBloc._onLogin - Error: $e');
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        employeeId: event.employeeId,
      );
      emit(AuthUnauthenticated()); // Redirect to login after register
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.forgotPassword(event.email);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
  
  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    final isAuthenticated = await authRepository.isAuthenticated();
    if (isAuthenticated) {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        // Preserve current state if user data is the same (especially profilePhotoUrl)
        // to prevent unnecessary URL changes from backend response
        final currentState = state;
        if (currentState is AuthAuthenticated) {
          // Only update if user ID is different or if URL actually changed
          // Remove any cache buster from backend URL to match stored state
          final backendPhotoUrl = user.profilePhotoUrl;
          final currentPhotoUrl = currentState.user.profilePhotoUrl;
          
          // If backend URL exists and current URL has cache buster, preserve the base URL
          if (backendPhotoUrl != null && 
              currentPhotoUrl != null && 
              backendPhotoUrl != currentPhotoUrl) {
            // Check if current URL is just the backend URL with cache buster
            final baseUrl = backendPhotoUrl.split('?').first;
            if (currentPhotoUrl.startsWith(baseUrl)) {
              // Keep current URL (with cache buster) to prevent image reload
              final preservedUser = user.copyWith(profilePhotoUrl: currentPhotoUrl);
              emit(AuthAuthenticated(user: preservedUser));
              return;
            }
          }
          
          // If user ID is same and profile photo URL from backend matches current (without cache buster),
          // keep current state to avoid unnecessary rebuilds
          if (currentState.user.id == user.id && 
              _arePhotoUrlsEquivalent(backendPhotoUrl, currentPhotoUrl)) {
            // Don't emit new state if URLs are equivalent (ignoring cache buster)
            return;
          }
        }
        
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  /// Check if two photo URLs are equivalent (ignoring cache buster parameters)
  bool _arePhotoUrlsEquivalent(String? url1, String? url2) {
    if (url1 == null && url2 == null) return true;
    if (url1 == null || url2 == null) return false;
    
    // Remove query parameters (cache buster) for comparison
    final base1 = url1.split('?').first;
    final base2 = url2.split('?').first;
    
    return base1 == base2;
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      // Force emit new state even if user looks same
      emit(AuthLoading()); // Emit loading briefly to force rebuild
      await Future.delayed(const Duration(milliseconds: 50));
      emit(AuthAuthenticated(user: event.user));
    }
  }
}

