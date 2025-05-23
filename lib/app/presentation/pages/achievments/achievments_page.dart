import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/recompensa.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';

class AchievementsPage extends StatefulWidget {
  final TipoUsuario userType;
  final int pontosDisponiveis; // Para criança

  const AchievementsPage({super.key, this.userType = TipoUsuario.crianca, this.pontosDisponiveis = 100});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  // Mock de recompensas
  List<Recompensa> recompensas = [
    Recompensa(
      id: 1,
      responsavelId: 1,
      titulo: 'Passeio no parque',
      observacao: 'Um dia divertido no parque',
      pontoGasto: 50,
      url: null,
      situacao: SituacaoRecompensa.disponivel,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
    Recompensa(
      id: 2,
      responsavelId: 1,
      titulo: 'Sorvete',
      observacao: 'Um sorvete de sua escolha',
      pontoGasto: 30,
      url: null,
      situacao: SituacaoRecompensa.disponivel,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
    Recompensa(
      id: 3,
      responsavelId: 1,
      titulo: 'Brinquedo novo',
      observacao: 'Escolha um brinquedo novo',
      pontoGasto: 120,
      url: null,
      situacao: SituacaoRecompensa.disponivel,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
  ];

  void _adicionarRecompensa() async {
    final result = await showDialog<Recompensa>(
      context: context,
      builder: (context) {
        final tituloController = TextEditingController();
        final obsController = TextEditingController();
        final pontosController = TextEditingController();
        return AlertDialog(
          title: const Text('Nova Recompensa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: obsController,
                  decoration: const InputDecoration(labelText: 'Descrição/Observação'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pontosController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pontos necessários'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty && pontosController.text.isNotEmpty) {
                  Navigator.of(context).pop(
                    Recompensa(
                      id: DateTime.now().millisecondsSinceEpoch,
                      responsavelId: 1,
                      titulo: tituloController.text,
                      observacao: obsController.text,
                      pontoGasto: int.tryParse(pontosController.text) ?? 0,
                      url: null,
                      situacao: SituacaoRecompensa.disponivel,
                      criadoEm: DateTime.now(),
                      atualizadoEm: DateTime.now(),
                    ),
                  );
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        recompensas.add(result);
      });
    }
  }

  void _resgatarRecompensa(Recompensa recompensa) {
    if (widget.pontosDisponiveis >= recompensa.pontoGasto) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resgatar recompensa'),
          content: Text('Deseja resgatar "${recompensa.titulo}" por ${recompensa.pontoGasto} pontos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recompensa "${recompensa.titulo}" resgatada!'), backgroundColor: Colors.green),
                );
                // Aqui você pode descontar os pontos do usuário (mock)
              },
              child: const Text('Resgatar'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pontos insuficientes!'), backgroundColor: Colors.red),
      );
    }
  }

  void _editarRecompensa(Recompensa recompensa) async {
    final result = await showDialog<Recompensa>(
      context: context,
      builder: (context) {
        final tituloController = TextEditingController(text: recompensa.titulo);
        final obsController = TextEditingController(text: recompensa.observacao);
        final pontosController = TextEditingController(text: recompensa.pontoGasto.toString());
        return AlertDialog(
          title: const Text('Editar Recompensa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: obsController,
                  decoration: const InputDecoration(labelText: 'Descrição/Observação'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pontosController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pontos necessários'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty && pontosController.text.isNotEmpty) {
                  Navigator.of(context).pop(
                    recompensa.copyWith(
                      titulo: tituloController.text,
                      observacao: obsController.text,
                      pontoGasto: int.tryParse(pontosController.text) ?? recompensa.pontoGasto,
                      atualizadoEm: DateTime.now(),
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        final idx = recompensas.indexWhere((r) => r.id == recompensa.id);
        if (idx != -1) recompensas[idx] = result;
      });
    }
  }

  void _excluirRecompensa(Recompensa recompensa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir recompensa'),
        content: Text('Tem certeza que deseja excluir "${recompensa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        recompensas.removeWhere((r) => r.id == recompensa.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recompensas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  if (widget.userType == TipoUsuario.responsavel)
                    ElevatedButton.icon(
                      onPressed: _adicionarRecompensa,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Adicionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: recompensas.length,
                itemBuilder: (context, index) {
                  final recompensa = recompensas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, color: AppColors.primary, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recompensa.titulo,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recompensa.observacao,
                                style: const TextStyle(fontSize: 14, color: AppColors.gray400),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${recompensa.pontoGasto} pontos',
                                    style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (widget.userType == TipoUsuario.crianca)
                          ElevatedButton(
                            onPressed: () => _resgatarRecompensa(recompensa),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Resgatar'),
                          ),
                        if (widget.userType == TipoUsuario.responsavel)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primary),
                                tooltip: 'Editar',
                                onPressed: () => _editarRecompensa(recompensa),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Excluir',
                                onPressed: () => _excluirRecompensa(recompensa),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: (index * 120).ms).slideY(begin: 0.08);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
