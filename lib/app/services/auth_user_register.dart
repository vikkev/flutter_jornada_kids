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
    final url = '${ApiConfig.api}/responsaveis/';
    return await _dio.post(url, data: data);
  }
}
