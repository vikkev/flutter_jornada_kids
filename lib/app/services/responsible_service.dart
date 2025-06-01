import 'package:dio/dio.dart';
import 'api_config.dart';

class ResponsibleService {
  final Dio _dio = Dio();

  Future<List<ChildInfo>> fetchChildren(int responsavelId) async {
    final url = '${ApiConfig.api}/responsaveis/$responsavelId/criancas';
    final response = await _dio.get(url);
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List).map((item) => ChildInfo.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar crianças');
    }
  }

  Future<ResponsibleInfo> fetchResponsible(int responsavelId) async {
    final url = '${ApiConfig.api}/responsaveis/$responsavelId';
    final response = await _dio.get(url);
    if (response.statusCode == 200 && response.data != null) {
      return ResponsibleInfo.fromJson(response.data);
    } else {
      throw Exception('Erro ao buscar responsável');
    }
  }
}

class ChildInfo {
  final int id;
  final int idade;
  final int nivel;
  final String nome;

  ChildInfo({required this.id, required this.idade, required this.nivel, required this.nome});

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      id: json['id'] ?? 0,
      idade: json['idade'] ?? 0,
      nivel: json['nivel'] ?? 0,
      nome: json['usuario']?['nomeCompleto'] ?? '',
    );
  }
}

class ResponsibleInfo {
  final int id;
  final String codigo;
  final String tipo;
  final ResponsibleUser usuario;

  ResponsibleInfo({required this.id, required this.codigo, required this.tipo, required this.usuario});

  factory ResponsibleInfo.fromJson(Map<String, dynamic> json) {
    return ResponsibleInfo(
      id: json['id'] ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      usuario: ResponsibleUser.fromJson(json['usuario'] ?? {}),
    );
  }
}

class ResponsibleUser {
  final int id;
  final String nomeCompleto;
  final String nomeUsuario;
  final String email;
  final String telefone;
  final String tipo;
  final String criadoEm;
  final String atualizadoEm;

  ResponsibleUser({
    required this.id,
    required this.nomeCompleto,
    required this.nomeUsuario,
    required this.email,
    required this.telefone,
    required this.tipo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory ResponsibleUser.fromJson(Map<String, dynamic> json) {
    return ResponsibleUser(
      id: json['id'] ?? 0,
      nomeCompleto: json['nomeCompleto'] ?? '',
      nomeUsuario: json['nomeUsuario'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      tipo: json['tipo'] ?? '',
      criadoEm: json['criadoEm'] ?? '',
      atualizadoEm: json['atualizadoEm'] ?? '',
    );
  }
} 