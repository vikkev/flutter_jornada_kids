import 'dart:typed_data';
import 'enums.dart';

class Tarefa {
  int id;
  int responsavelId;
  String titulo;
  String descricao;
  int pontoMax;
  int ponto;
  int estrela;
  PrioridadeTarefa prioridade;
  Uint8List? foto;
  SituacaoTarefa situacao;
  DateTime dataLimite;
  DateTime criadoEm;
  DateTime atualizadoEm;

  Tarefa({
    required this.id,
    required this.responsavelId,
    required this.titulo,
    required this.descricao,
    required this.pontoMax,
    required this.ponto,
    required this.estrela,
    required this.prioridade,
    this.foto,
    required this.situacao,
    required this.dataLimite,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  Tarefa copyWith({
    int? id,
    int? responsavelId,
    String? titulo,
    String? descricao,
    int? pontoMax,
    int? ponto,
    int? estrela,
    PrioridadeTarefa? prioridade,
    Uint8List? foto,
    SituacaoTarefa? situacao,
    DateTime? dataLimite,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Tarefa(
      id: id ?? this.id,
      responsavelId: responsavelId ?? this.responsavelId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      pontoMax: pontoMax ?? this.pontoMax,
      ponto: ponto ?? this.ponto,
      estrela: estrela ?? this.estrela,
      prioridade: prioridade ?? this.prioridade,
      foto: foto ?? this.foto,
      situacao: situacao ?? this.situacao,
      dataLimite: dataLimite ?? this.dataLimite,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}

class CriancaTarefa {
  int id;
  int criancaId;
  int idTarefa;
  DateTime dataHoraConclusao;

  CriancaTarefa({
    required this.id,
    required this.criancaId,
    required this.idTarefa,
    required this.dataHoraConclusao,
  });
}
