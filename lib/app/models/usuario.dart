import 'dart:typed_data';
import 'enums.dart';

class Usuario {
  int id;
  String nomeCompleto;
  String nomeUsuario;
  String email;
  String telefone;
  String senha;
  Uint8List? avatar;
  TipoUsuario tipoUsuario;
  DateTime criadoEm;
  DateTime atualizadoEm;

  Usuario({
    required this.id,
    required this.nomeCompleto,
    required this.nomeUsuario,
    required this.email,
    required this.telefone,
    required this.senha,
    this.avatar,
    required this.tipoUsuario,
    required this.criadoEm,
    required this.atualizadoEm,
  });
}
