import 'package:dio/dio.dart';
import 'api_config.dart';

class AchievementsService {
  final Dio _dio = Dio();

  Future<List<RecompensaResponse>> fetchRecompensas({
    required int? responsavelId,
    int? criancaId,
  }) async {
    try {
      int? idParaBuscar = responsavelId;
      // Se for criança, buscar o id do responsável via API se necessário
      if ((responsavelId == null || responsavelId == 0) && criancaId != null && criancaId > 0) {
        final dio = Dio();
        final url = '${ApiConfig.api}/criancas/$criancaId';
        final response = await dio.get(url);
        if (response.statusCode == 200 && response.data != null) {
          final responsavel = response.data['responsavel'];
          if (responsavel != null && responsavel['id'] != null) {
            idParaBuscar = responsavel['id'];
          }
        }
      }
      if (idParaBuscar == null || idParaBuscar == 0) {
        throw Exception('Responsável não encontrado para buscar recompensas');
      }
      final url = '${ApiConfig.api}/responsaveis/$idParaBuscar/recompensas';
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => RecompensaResponse.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Erro ao buscar recompensas: resposta inválida do servidor',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erro de conexão: verifique sua internet e tente novamente',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Tempo de conexão esgotado: tente novamente mais tarde',
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Responsável não encontrado');
      } else {
        throw Exception('Erro ao buscar recompensas: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao buscar recompensas: $e');
    }
  }

  Future<RecompensaResponse> createRecompensa({
    required int responsavelId,
    required String titulo,
    required String observacao,
    required int pontuacaoNecessaria,
    String? url,
  }) async {
    try {
      if (pontuacaoNecessaria <= 0) {
        throw Exception('A pontuação necessária deve ser maior que zero');
      }

      final data = {
        'idResponsavel': responsavelId,
        'titulo': titulo,
        'observacao': observacao,
        'pontuacaoNecessaria': pontuacaoNecessaria,
        'quantidade': pontuacaoNecessaria,
        'situacao': 'D',
        'url': url,
      };

      final apiUrl = '${ApiConfig.api}/recompensas';
      final response = await _dio.post(
        apiUrl,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return RecompensaResponse.fromJson(response.data);
        } else {
          // Sucesso, mas resposta é String ou null
          return RecompensaResponse(
            id: 0,
            responsavelId: responsavelId,
            titulo: titulo,
            observacao: observacao,
            pontuacaoNecessaria: pontuacaoNecessaria,
            url: url,
            situacao: 'D',
            criadoEm: DateTime.now().toIso8601String(),
            atualizadoEm: DateTime.now().toIso8601String(),
          );
        }
      } else {
        throw Exception(
          'Erro ao criar recompensa: resposta inválida do servidor',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erro de conexão: verifique sua internet e tente novamente',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Tempo de conexão esgotado: tente novamente mais tarde',
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Responsável não encontrado');
      } else if (e.response?.statusCode == 400) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          throw Exception(e.response?.data['message']);
        }
        throw Exception(
          'Dados inválidos: verifique os campos e tente novamente',
        );
      } else {
        throw Exception(
          'Erro ao criar recompensa: ${e.message ?? 'erro desconhecido'}',
        );
      }
    } catch (e) {
      throw Exception('Erro inesperado ao criar recompensa: $e');
    }
  }

  Future<void> deleteRecompensa(int responsavelId, int recompensaId) async {
    try {
      final url =
          '${ApiConfig.api}/recompensas/$recompensaId';
      final response = await _dio.delete(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Erro ao excluir recompensa: resposta inválida do servidor',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erro de conexão: verifique sua internet e tente novamente',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Tempo de conexão esgotado: tente novamente mais tarde',
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Recompensa não encontrada');
      } else {
        throw Exception(
          'Erro ao excluir recompensa: ${e.message ?? 'erro desconhecido'}',
        );
      }
    } catch (e) {
      throw Exception('Erro inesperado ao excluir recompensa: $e');
    }
  }

  Future<RecompensaResponse> updateRecompensa({
    required int responsavelId,
    required int recompensaId,
    required String titulo,
    required String observacao,
    required int pontuacaoNecessaria,
    String? url,
  }) async {
    try {
      if (pontuacaoNecessaria <= 0) {
        throw Exception('A pontuação necessária deve ser maior que zero');
      }

      final data = {
        'titulo': titulo,
        'observacao': observacao,
        'pontuacaoNecessaria': pontuacaoNecessaria,
        'url': url,
      };

      final apiUrl =
          '${ApiConfig.api}/responsaveis/$responsavelId/recompensas/$recompensaId';
      final response = await _dio.put(
        apiUrl,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return RecompensaResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Erro ao atualizar recompensa: resposta inválida do servidor',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erro de conexão: verifique sua internet e tente novamente',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Tempo de conexão esgotado: tente novamente mais tarde',
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Recompensa não encontrada');
      } else if (e.response?.statusCode == 400) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          throw Exception(e.response?.data['message']);
        }
        throw Exception(
          'Dados inválidos: verifique os campos e tente novamente',
        );
      } else {
        throw Exception(
          'Erro ao atualizar recompensa: ${e.message ?? 'erro desconhecido'}',
        );
      }
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar recompensa: $e');
    }
  }
}

class RecompensaResponse {
  final int id;
  final int responsavelId;
  final String titulo;
  final String observacao;
  final int pontuacaoNecessaria;
  final String? url;
  final String situacao;
  final String criadoEm;
  final String atualizadoEm;

  RecompensaResponse({
    required this.id,
    required this.responsavelId,
    required this.titulo,
    required this.observacao,
    required this.pontuacaoNecessaria,
    this.url,
    required this.situacao,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory RecompensaResponse.fromJson(Map<String, dynamic> json) {
    return RecompensaResponse(
      id: json['id'] ?? 0,
      responsavelId: json['responsavelId'] ?? 0,
      titulo: json['titulo'] ?? '',
      observacao: json['observacao'] ?? '',
      pontuacaoNecessaria: json['pontuacaoNecessaria'] ?? 0,
      url: json['url'],
      situacao: json['situacao'] ?? '',
      criadoEm: json['criadoEm'] ?? '',
      atualizadoEm: json['atualizadoEm'] ?? '',
    );
  }
}
