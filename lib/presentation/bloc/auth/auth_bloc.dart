import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  
  SignInEvent({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;
  
  SignUpEvent({
    required this.email,
    required this.password,
    this.displayName,
  });
  
  @override
  List<Object?> get props => [email, password, displayName];
}

class SignOutEvent extends AuthEvent {}

class UpdateUserRoleEvent extends AuthEvent {
  final String uid;
  final UserRole role;
  
  UpdateUserRoleEvent({required this.uid, required this.role});
  
  @override
  List<Object?> get props => [uid, role];
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final UserModel user;
  
  AuthenticatedState(this.user);
  
  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  
  AuthErrorState(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc({required this.authRepository}) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
  }
  
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    
    final currentUser = authRepository.currentUser;
    if (currentUser != null) {
      try {
        final userProfile = await authRepository.getUserProfile(currentUser.id);
        if (userProfile != null) {
          emit(AuthenticatedState(userProfile));
        } else {
          emit(UnauthenticatedState());
        }
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    } else {
      emit(UnauthenticatedState());
    }
  }
  
  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    
    try {
      final user = await authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(AuthErrorState('Sign in failed'));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
  
  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    
    try {
      final user = await authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(AuthErrorState('Sign up failed'));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
  
  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    
    try {
      await authRepository.signOut();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
  
  Future<void> _onUpdateUserRole(
    UpdateUserRoleEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.updateUserRole(event.uid, event.role);
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}
