import 'package:dio/dio.dart';
import 'api_config.dart';

class TaskService {
  final Dio _dio = Dio();

  Future<TaskResponse> createTask({
    required int idResponsavel,
    required int idCrianca,
    required String titulo,
    required String descricao,
    required int pontuacaoTotal,
    required String prioridade,
    required DateTime dataHoraLimite,
  }) async {
    final url = '${ApiConfig.api}/tarefas';
    final response = await _dio.post(
      url,
      data: {
        'idResponsavel': idResponsavel,
        'idCrianca': idCrianca,
        'titulo': titulo,
        'descricao': descricao,
        'pontuacaoTotal': pontuacaoTotal,
        'prioridade': prioridade,
        'dataHoraLimite': dataHoraLimite.toIso8601String(),
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return TaskResponse.fromJson(response.data);
      } else {
        // Sucesso, mas resposta é String ou null
        return TaskResponse(
          id: 0,
          responsavel: {},
          crianca: {},
          titulo: '',
          pontuacaoTotal: 0,
          pontuacaoConquistada: 0,
          estrela: 0,
          prioridade: '',
          situacao: '',
          dataHoraLimite: '',
          dataHoraConclusao: '',
          criadoEm: '',
          atualizadoEm: '',
        );
      }
    } else {
      throw Exception('Erro ao criar tarefa');
    }
  }

  Future<List<TaskResponse>> fetchAllTasks() async {
    final url = '${ApiConfig.api}/tarefas';
    final response = await _dio.get(url);
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => TaskResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Erro ao buscar todas as tarefas');
    }
  }

  Future<List<TaskResponse>> fetchTarefasDoResponsavel({
    required int responsavelId,
    int? criancaId,
    String? status,
  }) async {
    final url =
        criancaId != null
            ? '${ApiConfig.api}/criancas/$criancaId/tarefas'
            : '${ApiConfig.api}/responsaveis/$responsavelId/tarefas';

    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['situacao'] = status;

    try {
      final response = await _dio.get(url, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => TaskResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Erro ao buscar tarefas');
      }
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: ${e.toString()}');
    }
  }

  Future<List<TaskResponse>> fetchTarefasDaCrianca(int criancaId) async {
    final url = '${ApiConfig.api}/criancas/$criancaId/tarefas';
    final response = await _dio.get(url);
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => TaskResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Erro ao buscar tarefas da criança/adolescente');
    }
  }
}

class TaskResponse {
  final int id;
  final String titulo;
  final int pontuacaoTotal;
  final int? pontuacaoConquistada;
  final int? estrela;
  final String prioridade;
  final String situacao;
  final String dataHoraLimite;
  final String? dataHoraConclusao;
  final String? criadoEm;
  final String? atualizadoEm;
  final Map<String, dynamic>? crianca;
  final Map<String, dynamic>? responsavel;
  final String? descricao;

  TaskResponse({
    required this.id,
    required this.titulo,
    required this.pontuacaoTotal,
    this.pontuacaoConquistada,
    this.estrela,
    required this.prioridade,
    required this.situacao,
    required this.dataHoraLimite,
    this.dataHoraConclusao,
    this.criadoEm,
    this.atualizadoEm,
    this.crianca,
    this.responsavel,
    this.descricao,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      pontuacaoTotal: json['pontuacaoTotal'] ?? 0,
      pontuacaoConquistada: json['pontuacaoConquistada'],
      estrela: json['estrela'],
      prioridade: json['prioridade'] ?? '',
      situacao: json['situacao'] ?? '',
      dataHoraLimite: json['dataHoraLimite'] ?? '',
      dataHoraConclusao: json['dataHoraConclusao'],
      criadoEm: json['criadoEm'],
      atualizadoEm: json['atualizadoEm'],
      crianca: json['crianca'],
      responsavel: json['responsavel'],
      descricao: json['descricao'],
    );
  }
}
