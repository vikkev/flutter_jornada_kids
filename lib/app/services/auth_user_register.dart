import 'package:dio/dio.dart';
import 'api_config.dart';

class AuthUserRegisterService {
  final Dio _dio = Dio();

  Future<Response> registerResponsible({
    required String tipoResponsavel,
    required String nomeCompleto,
    required String nomeUsuario,
    required String email,
    required String telefone,
    required String senha,
    required String tipoUsuario,
  }) async {
    try {
      final data = {
        "tipo": tipoResponsavel,
        "usuario": {
          "nomeCompleto": nomeCompleto,
          "nomeUsuario": nomeUsuario,
          "email": email,
          "telefone": telefone,
          "senha": senha,
          "tipo": tipoUsuario
        }
      };
      
      final url = '${ApiConfig.api}/responsaveis';
      
      final response = await _dio.post(
        url, 
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      return response;
    } on DioException catch (e) {
      throw Exception('Erro ao registrar responsável: ${e.message}');
    }
  }

  /// Valida o código do responsável
  /// 
  /// Retorna os dados do responsável se o código for válido
  /// Lança uma exceção se o código for inválido ou se houver erro na requisição
  Future<Map<String, dynamic>> validateResponsibleCode(String codigo) async {
    try {
      if (codigo.length != 6) {
        throw Exception('O código deve ter 6 dígitos');
      }

      final url = '${ApiConfig.api}/responsaveis/codigo/$codigo';
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Código inválido ou não encontrado');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Código não encontrado');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Código inválido');
      } else {
        throw Exception('Erro ao validar código: ${e.message}');
      }
    }
  }

  /// Extrai informações específicas do responsável validado
  ResponsibleInfo? extractResponsibleInfo(Map<String, dynamic> data) {
    try {
      final usuario = data['usuario'] as Map<String, dynamic>?;
      
      if (usuario != null) {
        return ResponsibleInfo(
          id: data['id']?.toString() ?? '',
          codigo: data['codigo']?.toString() ?? '',
          tipo: data['tipo']?.toString() ?? '',
          nomeCompleto: usuario['nomeCompleto']?.toString() ?? '',
          nomeUsuario: usuario['nomeUsuario']?.toString() ?? '',
          email: usuario['email']?.toString() ?? '',
          telefone: usuario['telefone']?.toString() ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cadastro de criança
  Future<Response> registerChild({
    required String nomeCompleto,
    required String nomeUsuario,
    required String email,
    required String telefone,
    required String senha,
    required DateTime dataNascimento,
    required String idResponsavel,
    required String tipoUsuario, // 'C' para criança
  }) async {
    try {
      final data = {
        "usuario": {
          "nomeCompleto": nomeCompleto,
          "nomeUsuario": nomeUsuario,
          "email": email,
          "telefone": telefone,
          "senha": senha,
          "tipo": tipoUsuario
        },
        "dataNascimento": dataNascimento.toIso8601String(),
        "idResponsavel": idResponsavel,
      };
      final url = '${ApiConfig.api}/criancas';
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Erro ao registrar criança: [${e.message}');
    }
  }
}

/// Classe para armazenar informações do responsável
class ResponsibleInfo {
  final String id;
  final String codigo;
  final String tipo;
  final String nomeCompleto;
  final String nomeUsuario;
  final String email;
  final String telefone;

  ResponsibleInfo({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.nomeCompleto,
    required this.nomeUsuario,
    required this.email,
    required this.telefone,
  });

  @override
  String toString() {
    return 'ResponsibleInfo(id: $id, nomeCompleto: $nomeCompleto, tipo: $tipo)';
  }
}