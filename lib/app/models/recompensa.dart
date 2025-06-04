import 'enums.dart';

class Recompensa {
  int id;
  int responsavelId;
  String titulo;
  String observacao;
  int pontuacaoNecessaria;
  String? url;
  SituacaoRecompensa situacao;
  DateTime criadoEm;
  DateTime atualizadoEm;

  Recompensa({
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

  Recompensa copyWith({
    int? id,
    int? responsavelId,
    String? titulo,
    String? observacao,
    int? pontuacaoNecessaria,
    String? url,
    SituacaoRecompensa? situacao,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Recompensa(
      id: id ?? this.id,
      responsavelId: responsavelId ?? this.responsavelId,
      titulo: titulo ?? this.titulo,
      observacao: observacao ?? this.observacao,
      pontuacaoNecessaria: pontuacaoNecessaria ?? this.pontuacaoNecessaria,
      url: url ?? this.url,
      situacao: situacao ?? this.situacao,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}

class CriancaRecompensa {
  int id;
  int criancaId;
  int recompensaId;
  int recompensaAntId;
  DateTime dataHora;
  int ponto;

  CriancaRecompensa({
    required this.id,
    required this.criancaId,
    required this.recompensaId,
    required this.recompensaAntId,
    required this.dataHora,
    required this.ponto,
  });
}
