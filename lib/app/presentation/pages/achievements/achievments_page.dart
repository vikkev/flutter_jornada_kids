import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/recompensa.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/services/achievements_service.dart';

class AchievementsPage extends StatefulWidget {
  final TipoUsuario userType;
  final int pontosDisponiveis;
  final int idResponsavel;
  final int? idCrianca;

  const AchievementsPage({
    super.key,
    this.userType = TipoUsuario.crianca,
    this.pontosDisponiveis = 100,
    required this.idResponsavel,
    this.idCrianca,
  });

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final _achievementsService = AchievementsService();
  List<RecompensaResponse> recompensas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarRecompensas();
  }

  Future<void> _carregarRecompensas() async {
    setState(() => isLoading = true);
    try {
      final listaRecompensas = await _achievementsService.fetchRecompensas(
        responsavelId: widget.idResponsavel,
        criancaId: widget.idCrianca,
      );
      setState(() {
        recompensas = listaRecompensas;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar recompensas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _adicionarRecompensa() async {
    final result = await showDialog<Map<String, dynamic>>(
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
                  decoration: const InputDecoration(
                    labelText: 'Descrição/Observação',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pontosController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estrelas necessárias',
                  ),
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
                if (tituloController.text.isEmpty ||
                    pontosController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos obrigatórios!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final pontuacao = int.tryParse(pontosController.text) ?? 0;
                if (pontuacao <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'A pontuação necessária deve ser maior que zero!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop({
                  'titulo': tituloController.text,
                  'observacao': obsController.text,
                  'pontuacaoNecessaria': pontuacao,
                });
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        await _achievementsService.createRecompensa(
          responsavelId: widget.idResponsavel,
          titulo: result['titulo'],
          observacao: result['observacao'],
          pontuacaoNecessaria: result['pontuacaoNecessaria'],
        );
        _carregarRecompensas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recompensa criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar recompensa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _excluirRecompensa(RecompensaResponse recompensa) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Recompensa'),
            content: Text(
              'Tem certeza que deseja excluir a recompensa "${recompensa.titulo}"?',
            ),
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

    if (confirma == true) {
      try {
        await _achievementsService.deleteRecompensa(
          widget.idResponsavel,
          recompensa.id,
        );
        _carregarRecompensas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recompensa excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir recompensa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _resgatarRecompensa(RecompensaResponse recompensa) {
    if (widget.pontosDisponiveis >= recompensa.pontuacaoNecessaria) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Resgatar recompensa'),
              content: Text(
                'Deseja resgatar "${recompensa.titulo}" por ${recompensa.pontuacaoNecessaria} estrelas?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Recompensa "${recompensa.titulo}" resgatada!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // TODO: Implementar lógica de resgate na API
                  },
                  child: const Text('Resgatar'),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estrelas insuficientes!'),
          backgroundColor: Colors.red,
        ),
      );
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (widget.userType == TipoUsuario.responsavel)
                    ElevatedButton.icon(
                      onPressed: _adicionarRecompensa,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Adicionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : recompensas.isEmpty
                      ? const Center(
                        child: Text('Nenhuma recompensa disponível'),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
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
                                    const Icon(
                                      Icons.emoji_events,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recompensa.titulo,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            recompensa.observacao,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.gray400,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${recompensa.pontuacaoNecessaria} estrelas',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.userType == TipoUsuario.crianca)
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                _resgatarRecompensa(recompensa),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: const Text('Resgatar'),
                                      ),
                                    if (widget.userType ==
                                        TipoUsuario.responsavel)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // IconButton(
                                          //   icon: const Icon(
                                          //     Icons.edit,
                                          //     color: AppColors.primary,
                                          //   ),
                                          //   tooltip: 'Editar',
                                          //   onPressed:
                                          //       () {}, // TODO: Implementar edição
                                          // ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            tooltip: 'Excluir',
                                            onPressed:
                                                () => _excluirRecompensa(
                                                  recompensa,
                                                ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: (index * 120).ms)
                              .slideY(begin: 0.08);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
