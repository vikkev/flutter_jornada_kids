enum TipoUsuario { crianca, responsavel }

enum TipoResponsavel { avo, pai, mae, tio, tia }

enum PrioridadeTarefa { alta, media, baixa }

enum SituacaoTarefa {
  P("Pendente"),
  E("Expirada"),
  C("Concluída"),
  A("Avaliada");

  final String label;
  const SituacaoTarefa(this.label);
}

enum SituacaoRecompensa { disponivel, esgotada, bloqueada, oculta }

extension PrioridadeTarefaExtension on PrioridadeTarefa {
  String get code {
    switch (this) {
      case PrioridadeTarefa.alta:
        return 'A';
      case PrioridadeTarefa.media:
        return 'M';
      case PrioridadeTarefa.baixa:
        return 'B';
    }
  }

  String get label {
    switch (this) {
      case PrioridadeTarefa.alta:
        return 'Alta';
      case PrioridadeTarefa.media:
        return 'Média';
      case PrioridadeTarefa.baixa:
        return 'Baixa';
    }
  }

  static PrioridadeTarefa fromCode(String code) {
    switch (code) {
      case 'A':
        return PrioridadeTarefa.alta;
      case 'M':
        return PrioridadeTarefa.media;
      case 'B':
        return PrioridadeTarefa.baixa;
      default:
        return PrioridadeTarefa.media;
    }
  }
}

extension SituacaoTarefaExtension on SituacaoTarefa {
  String get code {
    switch (this) {
      case SituacaoTarefa.P:
        return 'P';
      case SituacaoTarefa.E:
        return 'E';
      case SituacaoTarefa.C:
        return 'C';
      case SituacaoTarefa.A:
        return 'A';
    }
  }

  static SituacaoTarefa fromCode(String code) {
    switch (code) {
      case 'P':
        return SituacaoTarefa.P;
      case 'E':
        return SituacaoTarefa.E;
      case 'C':
        return SituacaoTarefa.C;
      case 'A':
        return SituacaoTarefa.A;
      default:
        return SituacaoTarefa.P;
    }
  }
}
