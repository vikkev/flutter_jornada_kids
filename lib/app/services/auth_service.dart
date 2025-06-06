import 'package:dio/dio.dart';
import 'api_config.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Autenticação real via API
  Future<AuthResult> login(
    String username,
    String password,
    TipoUsuario tipoUsuario,
  ) async {
    final Dio _dio = Dio();
    try {
      final url = '${ApiConfig.api}/usuarios/autenticar';
      final response = await _dio.post(
        url,
        data: {'nomeUsuario': username, 'senha': password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus:
              (status) =>
                  true, // Aceita qualquer status code para tratar manualmente
        ),
      );

      // Tratamento específico para diferentes status codes
      if (response.statusCode == 404) {
        return AuthResult(
          success: false,
          message: 'Usuário não encontrado. Verifique suas credenciais.',
        );
      }

      if (response.statusCode == 401) {
        return AuthResult(
          success: false,
          message: 'Senha incorreta. Tente novamente.',
        );
      }

      if (response.statusCode != 200 || response.data == null) {
        return AuthResult(
          success: false,
          message: 'Erro ao fazer login. Tente novamente mais tarde.',
        );
      }

      final data = response.data;
      final usuarioData = data['usuario'];
      // Mapeia o tipo vindo da API para o enum
      TipoUsuario tipoApi;
      if ((usuarioData['tipo'] ?? '').toLowerCase().contains('respons')) {
        tipoApi = TipoUsuario.responsavel;
      } else if ((usuarioData['tipo'] ?? '').toLowerCase().contains('crian')) {
        tipoApi = TipoUsuario.crianca;
      } else {
        return AuthResult(
          success: false,
          message: 'Tipo de usuário desconhecido.',
        );
      }
      if (tipoApi != tipoUsuario) {
        return AuthResult(
          success: false,
          message:
              'Tipo de usuário incorreto. Verifique se está no login correto.',
        );
      }
      final user = Usuario(
        id: usuarioData['id'] ?? 0,
        idExterno: data['id'] ?? usuarioData['id'],
        nomeCompleto: usuarioData['nomeCompleto'] ?? '',
        nomeUsuario: usuarioData['nomeUsuario'] ?? '',
        email: usuarioData['email'] ?? '',
        telefone: usuarioData['telefone'] ?? '',
        senha: password,
        tipoUsuario: tipoApi,
        criadoEm:
            DateTime.tryParse(usuarioData['criadoEm'] ?? '') ?? DateTime.now(),
        atualizadoEm:
            DateTime.tryParse(usuarioData['atualizadoEm'] ?? '') ??
            DateTime.now(),
      );
      return AuthResult(
        success: true,
        user: user,
        message: 'Login realizado com sucesso!',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return AuthResult(
          success: false,
          message: 'Erro de conexão. Verifique sua internet e tente novamente.',
        );
      }
      return AuthResult(
        success: false,
        message: 'Erro ao fazer login. Tente novamente mais tarde.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Erro inesperado. Tente novamente mais tarde.',
      );
    }
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

  AuthResult({required this.success, required this.message, this.user});
}
