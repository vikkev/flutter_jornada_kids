import 'dart:async';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

// This class simulates an authentication service with mock data
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Mock user data
  final Map<String, MockUser> _mockUsers = {
    // Responsible users
    'maria': MockUser(
      username: 'maria',
      password: '123456',
      name: 'Maria Silva',
      email: 'maria@example.com',
      userType: UserType.responsible,
    ),
    'joao': MockUser(
      username: 'joao',
      password: '123456',
      name: 'João Santos',
      email: 'joao@example.com',
      userType: UserType.responsible,
    ),
    
    // Child users
    'lucas': MockUser(
      username: 'lucas',
      password: '123456',
      name: 'Lucas Silva',
      age: 10,
      userType: UserType.child,
    ),
    'ana': MockUser(
      username: 'ana',
      password: '123456',
      name: 'Ana Santos',
      age: 8,
      userType: UserType.child,
    ),
  };

  // Simulate an API login call
  Future<AuthResult> login(String username, String password, UserType userType) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if user exists and has matching password and type
    if (_mockUsers.containsKey(username.toLowerCase())) {
      final user = _mockUsers[username.toLowerCase()]!;
      
      if (user.password == password && user.userType == userType) {
        // Successful login
        return AuthResult(
          success: true, 
          user: user,
          message: 'Login realizado com sucesso!',
        );
      } else if (user.userType != userType) {
        // Wrong user type
        return AuthResult(
          success: false,
          message: 'Tipo de usuário incorreto. Verifique se está no login correto.',
        );
      }
    }
    
    // Failed login
    return AuthResult(
      success: false,
      message: 'Usuário ou senha incorretos. Tente novamente.',
    );
  }

  // Get the current user (would be used after login)
  MockUser? getCurrentUser() {
    // In a real app, this would retrieve from secure storage
    return null;
  }
}

// Mock user model
class MockUser {
  final String username;
  final String password;
  final String name;
  final String? email;
  final int? age;
  final UserType userType;

  MockUser({
    required this.username,
    required this.password,
    required this.name,
    this.email,
    this.age,
    required this.userType,
  });
}

// Auth result model to simulate API response
class AuthResult {
  final bool success;
  final String message;
  final MockUser? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
} 