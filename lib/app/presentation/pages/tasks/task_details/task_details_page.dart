import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/success_message_page.dart';
import 'package:flutter_jornadakids/app/models/tarefa.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/services/api_config.dart';

class TaskDetailsPage extends StatefulWidget {
  final Tarefa tarefa;
  final Usuario responsavel;

  const TaskDetailsPage({
    super.key,
    required this.tarefa,
    required this.responsavel,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  bool _showApprovalButtons = false;
  late Tarefa _tarefaAtual = widget.tarefa;

  @override
  void initState() {
    super.initState();
    // Mostra os botões de aprovação após um delay para criar um efeito
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showApprovalButtons = true;
        });
      }
    });
  }

  Future<void> _approveTask() async {
    int estrelas = 1;
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: '1');
        return AlertDialog(
          title: const Text('Avaliar tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quantas estrelas deseja atribuir para esta tarefa? (1 a 5)',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estrelas',
                  border: OutlineInputBorder(),
                ),
                maxLength: 1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                int value = int.tryParse(controller.text) ?? 1;
                if (value < 1) value = 1;
                if (value > 5) value = 5;
                Navigator.of(context).pop(value);
              },
              child: const Text('Avaliar'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      estrelas = result;
      try {
        final dio = Dio();
        final url = '${ApiConfig.api}/tarefas/${_tarefaAtual.id}/avaliar';
        await dio.put(url, data: {"estrela": estrelas});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao avaliar tarefa: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => SuccessMessagePage(
                message:
                    'Tarefa aprovada com sucesso!\nA criança/adolescente ganhou ${_tarefaAtual.ponto} pontos.',
                buttonText: 'Voltar às tarefas',
                onButtonPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
        ),
      );
    }
  }

  Future<void> _rejectTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reprovar tarefa'),
            content: const Text('Tem certeza que deseja reprovar esta tarefa?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Reprovar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) {
      try {
        final dio = Dio();
        final url = '${ApiConfig.api}/tarefas/${_tarefaAtual.id}/avaliar';
        await dio.put(url, data: {"estrela": 0});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao reprovar tarefa: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => SuccessMessagePage(
                message:
                    'Tarefa reprovada.\nA criança/adolescente precisará refazer a atividade.',
                buttonText: 'Voltar às tarefas',
                onButtonPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
        ),
      );
    }
  }

  void _openEditModal() async {
    final result = await showDialog<Tarefa>(
      context: context,
      builder: (context) {
        final tituloController = TextEditingController(
          text: _tarefaAtual.titulo,
        );
        final descricaoController = TextEditingController(
          text: _tarefaAtual.descricao,
        );
        final pontoController = TextEditingController(
          text: _tarefaAtual.ponto.toString(),
        );
        DateTime dataLimite = _tarefaAtual.dataLimite;
        return AlertDialog(
          title: const Text('Editar Tarefa'),
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
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pontoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pontos'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Prazo:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dataLimite,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          dataLimite = picked;
                        }
                      },
                      child: Text(_formatDate(dataLimite)),
                    ),
                  ],
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
                final novaTarefa = _tarefaAtual.copyWith(
                  titulo: tituloController.text,
                  descricao: descricaoController.text,
                  ponto:
                      int.tryParse(pontoController.text) ?? _tarefaAtual.ponto,
                  dataLimite: dataLimite,
                  atualizadoEm: DateTime.now(),
                );
                Navigator.of(context).pop(novaTarefa);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _tarefaAtual = result;
      });
    }
  }

  String _formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }

  // Adicione estas funções para tratar status igual ao TasksPage
  String _getStatusText(SituacaoTarefa status) {
    switch (status) {
      case SituacaoTarefa.P:
        return 'Pendente';
      case SituacaoTarefa.C:
        return 'Concluída';
      case SituacaoTarefa.E:
        return 'Vencida';
      case SituacaoTarefa.A:
        return 'Avaliada';
    }
  }

  Color _getStatusColor(SituacaoTarefa status) {
    switch (status) {
      case SituacaoTarefa.P:
        return Colors.orange;
      case SituacaoTarefa.C:
        return AppColors.primary;
      case SituacaoTarefa.E:
        return Colors.red;
      case SituacaoTarefa.A:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarefa = _tarefaAtual;
    final responsavel = widget.responsavel;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Detalhes tarefa',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removido filtro/dropdown do topo
            const SizedBox(height: 8),

            // Botão Editar
            /*
            Center(
              child: GestureDetector(
                onTap: _openEditModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            */
            const SizedBox(height: 24),

            // Card principal da tarefa
            Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título e pontos
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                tarefa.titulo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatPoints(tarefa.ponto),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'pontos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Status
                        _buildDetailRow(
                          'Status',
                          _getStatusText(
                            tarefa.situacao,
                          ), // Use função para texto
                          color: _getStatusColor(
                            tarefa.situacao,
                          ), // Use função para cor
                        ),

                        const SizedBox(height: 12),

                        // Prazo
                        _buildDetailRow(
                          'Prazo',
                          _formatDate(tarefa.dataLimite),
                        ),

                        const SizedBox(height: 12),

                        // Tarefa atribuída para
                        _buildDetailRow(
                          'Tarefa atribuída para',
                          tarefa.crianca?['usuario']?['nomeCompleto'] ??
                              'Nome não disponível',
                        ),

                        const SizedBox(height: 20),

                        // Fotos de comprovação (comentado)
                        /*
                    Text(
                      'Fotos de comprovação',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ...List.generate(3, (index) => 
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index < 2 ? 8 : 0,
                              ),
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: (600 + index * 100).ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'ver mais',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 1000.ms),
                    */
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),

            const SizedBox(height: 32),

            // Botões de aprovação/reprovação
            if (_showApprovalButtons)
              Row(
                children: [
                  Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton(
                            onPressed: _approveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Aprovar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideX(begin: -0.5, curve: Curves.elasticOut),

                  const SizedBox(width: 16),

                  Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton(
                            onPressed: _rejectTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Reprovar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideX(begin: 0.5, curve: Curves.elasticOut),
                ],
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
