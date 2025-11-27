import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class AplicativoResponse {
  final int id;
  final int idResponsavel;
  final int idCrianca;
  final String plataforma;
  final String identificador;
  final String nome;
  final bool bloqueado;
  final int tempoUsado;
  final int tempoLimite;

  AplicativoResponse({
    required this.id,
    required this.idResponsavel,
    required this.idCrianca,
    required this.plataforma,
    required this.identificador,
    required this.nome,
    required this.bloqueado,
    required this.tempoUsado,
    required this.tempoLimite,
  });

  factory AplicativoResponse.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool _parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is String) {
        final lower = v.toLowerCase();
        if (lower == 'true' || lower == '1') return true;
      }
      if (v is num) return v != 0;
      return false;
    }

    int _readInt(Map<String, dynamic> map, List<String> keys) {
      for (final k in keys) {
        if (map.containsKey(k)) return _parseInt(map[k]);
      }
      return 0;
    }

    int responsavelId = _readInt(json, ['idResponsavel', 'responsavelId']);
    if (responsavelId == 0 && json['responsavel'] is Map) {
      responsavelId = _parseInt((json['responsavel'] as Map)['id']);
    }

    int criancaId = _readInt(json, ['idCrianca', 'criancaId']);
    if (criancaId == 0 && json['crianca'] is Map) {
      criancaId = _parseInt((json['crianca'] as Map)['id']);
    }

    return AplicativoResponse(
      id: _parseInt(json['id']),
      idResponsavel: responsavelId,
      idCrianca: criancaId,
      plataforma: json['plataforma']?.toString() ?? '',
      identificador: json['identificador']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      bloqueado: _parseBool(json['bloqueado']),
      tempoUsado: _parseInt(json['tempoUsado']),
      tempoLimite: _parseInt(json['tempoLimite']),
    );
  }
}

class ApplicationsService {
  final Dio _dio = Dio();

  Future<List<AplicativoResponse>> fetchAplicativos({
    String? plataforma,
    bool? bloqueado,
  }) async {
    final url = '${ApiConfig.api}/aplicativos';

    // A API já retorna todos; não é necessário enviar filtros de plataforma/bloqueio.
    final response = await _dio.get(url);
    debugPrint(
      '[Aplicativos] GET $url status=${response.statusCode} data=${response.data}',
    );
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => AplicativoResponse.fromJson(item))
          .toList();
    } else {
      final detail = response.data?.toString() ?? 'resposta inválida';
      throw Exception('Erro ao buscar aplicativos: $detail');
    }
  }

  Future<AplicativoResponse> createAplicativo({
    required int idResponsavel,
    required int idCrianca,
    required String plataforma,
    required String identificador,
    required String nome,
    bool bloqueado = false,
    int tempoUsado = 0,
  }) async {
    final url = '${ApiConfig.api}/aplicativos';
    final data = {
      'idResponsavel': idResponsavel,
      'idCrianca': idCrianca,
      'plataforma': plataforma,
      'identificador': identificador,
      'nome': nome,
      'bloqueado': bloqueado,
      'tempoUsado': tempoUsado,
    };

    final response = await _dio.post(
      url,
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    debugPrint(
      '[Aplicativos] POST $url status=${response.statusCode} data=$data resp=${response.data}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return AplicativoResponse.fromJson(response.data);
      } else {
        return AplicativoResponse(
          id: 0,
          idResponsavel: idResponsavel,
          idCrianca: idCrianca,
          plataforma: plataforma,
          identificador: identificador,
          nome: nome,
          bloqueado: bloqueado,
          tempoUsado: tempoUsado,
          tempoLimite: 0,
        );
      }
    } else {
      throw Exception('Erro ao criar aplicativo');
    }
  }

  Future<void> atualizarTempoUsado({
    required int id,
    required int tempoUsado,
  }) async {
    final url = '${ApiConfig.api}/aplicativos/$id';
    final data = {
      'tempoUsado': tempoUsado,
    };

    final response = await _dio.put(
      url,
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    debugPrint(
      '[Aplicativos] PUT $url status=${response.statusCode} data=$data resp=${response.data}',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao atualizar tempo usado do aplicativo');
    }
  }

  Future<void> atualizarBloqueio({
    required int id,
    required bool bloqueado,
    required int tempoLimite,
  }) async {
    final url = '${ApiConfig.api}/aplicativos/$id/bloquear';
    final data = {
      'bloqueado': bloqueado,
      'tempoLimite': tempoLimite,
    };

    final response = await _dio.put(
      url,
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    debugPrint(
      '[Aplicativos] PUT $url status=${response.statusCode} data=$data resp=${response.data}',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao atualizar bloqueio do aplicativo');
    }
  }
}
