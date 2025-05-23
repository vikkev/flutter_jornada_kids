import 'enums.dart';

class Responsavel {
  int id;
  int idUsuario;
  int codigo;
  TipoResponsavel tipo;

  Responsavel({
    required this.id,
    required this.idUsuario,
    required this.codigo,
    required this.tipo,
  });
}

class ResponsavelCrianca {
  int id;
  int responsavelId;
  int criancaId;

  ResponsavelCrianca({
    required this.id,
    required this.responsavelId,
    required this.criancaId,
  });
}
