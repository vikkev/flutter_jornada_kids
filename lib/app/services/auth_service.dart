import 'dart:async';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';

// Serviço de autenticação mockado
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Mock de usuários reais
  final Map<String, Usuario> _mockUsers = {
    // Responsáveis
    'maria': Usuario(
      id: 1,
      nomeCompleto: 'Maria Silva',
      nomeUsuario: 'maria',
      email: 'maria@example.com',
      telefone: '99999-9999',
      senha: '123',
      tipoUsuario: TipoUsuario.responsavel,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
    'joao': Usuario(
      id: 2,
      nomeCompleto: 'João Santos',
      nomeUsuario: 'joao',
      email: 'joao@example.com',
      telefone: '88888-8888',
      senha: '123',
      tipoUsuario: TipoUsuario.responsavel,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
    // Crianças
    'lucas': Usuario(
      id: 3,
      nomeCompleto: 'Lucas Silva',
      nomeUsuario: 'lucas',
      email: 'lucas@example.com',
      telefone: '',
      senha: '123',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
    'ana': Usuario(
      id: 4,
      nomeCompleto: 'Ana Santos',
      nomeUsuario: 'ana',
      email: 'ana@example.com',
      telefone: '',
      senha: '123',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
  };

  // Simula uma chamada de login
  Future<AuthResult> login(String username, String password, TipoUsuario tipoUsuario) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = _mockUsers[username.toLowerCase()];
    if (user != null && user.senha == password && user.tipoUsuario == tipoUsuario) {
      return AuthResult(success: true, user: user, message: 'Login realizado com sucesso!');
    } else if (user != null && user.tipoUsuario != tipoUsuario) {
      return AuthResult(success: false, message: 'Tipo de usuário incorreto. Verifique se está no login correto.');
    }
    return AuthResult(success: false, message: 'Usuário ou senha incorretos. Tente novamente.');
  }

  // Mock: não implementado
  Usuario? getCurrentUser() {
    return null;
  }
}

class AuthResult {
  final bool success;
  final String message;
  final Usuario? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
} 