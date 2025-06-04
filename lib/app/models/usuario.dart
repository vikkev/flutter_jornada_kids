import 'dart:typed_data';
import 'enums.dart';

class Usuario {
  int id; // id do usuario (interno)
  int? idExterno; // id externo (raiz do objeto, usado para requests)
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
    this.idExterno,
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

  factory Usuario.fromJson(Map<String, dynamic> json, {int? idExterno}) {
    return Usuario(
      id: json['usuario']?['id'] ?? json['id'] ?? 0,
      idExterno: idExterno ?? json['id'],
      nomeCompleto: json['usuario']?['nomeCompleto'] ?? json['nomeCompleto'] ?? '',
      nomeUsuario: json['usuario']?['nomeUsuario'] ?? json['nomeUsuario'] ?? '',
      email: json['usuario']?['email'] ?? json['email'] ?? '',
      telefone: json['usuario']?['telefone'] ?? json['telefone'] ?? '',
      senha: '', // nunca vem da API
      tipoUsuario: (json['usuario']?['tipo'] ?? json['tipo'] ?? '').toString().toLowerCase().contains('respons')
          ? TipoUsuario.responsavel
          : TipoUsuario.crianca,
      criadoEm: DateTime.tryParse(json['usuario']?['criadoEm'] ?? json['criadoEm'] ?? '') ?? DateTime.now(),
      atualizadoEm: DateTime.tryParse(json['usuario']?['atualizadoEm'] ?? json['atualizadoEm'] ?? '') ?? DateTime.now(),
    );
  }
}
