import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/success_message_page.dart';
import 'package:flutter_jornadakids/app/models/tarefa.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';

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

  void _approveTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SuccessMessagePage(
          message: 'Tarefa aprovada com sucesso!\nA criança ganhou ${_tarefaAtual.ponto} pontos.',
          buttonText: 'Voltar às tarefas',
          onButtonPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void _rejectTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reprovar tarefa'),
        content: const Text('Tem certeza que deseja reprovar esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SuccessMessagePage(
                    message: 'Tarefa reprovada.\nA criança precisará refazer a atividade.',
                    buttonText: 'Voltar às tarefas',
                    onButtonPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              );
            },
            child: const Text('Reprovar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openEditModal() async {
    final result = await showDialog<Tarefa>(
      context: context,
      builder: (context) {
        final tituloController = TextEditingController(text: _tarefaAtual.titulo);
        final descricaoController = TextEditingController(text: _tarefaAtual.descricao);
        final pontoController = TextEditingController(text: _tarefaAtual.ponto.toString());
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
                  ponto: int.tryParse(pontoController.text) ?? _tarefaAtual.ponto,
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
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removido filtro/dropdown do topo
            const SizedBox(height: 8),

            // Botão Editar
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

            const SizedBox(height: 24),

            // Card principal da tarefa
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _formatPoints(tarefa.ponto),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Status
                    _buildDetailRow('Status', tarefa.situacao.name, 
                        color: tarefa.situacao == SituacaoTarefa.P 
                            ? Colors.orange 
                            : AppColors.primary),

                    const SizedBox(height: 12),

                    // Prazo
                    _buildDetailRow('Prazo', _formatDate(tarefa.dataLimite)),

                    const SizedBox(height: 12),

                    // Tarefa atribuída para
                    _buildDetailRow('Tarefa atribuída para', responsavel.nomeCompleto),

                    const SizedBox(height: 20),

                    // Fotos de comprovação
                    Text(
                      'Fotos de comprovação',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Grid de fotos
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

                    // Ver mais link
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
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideX(begin: -0.5, curve: Curves.elasticOut),

                  const SizedBox(width: 16),

                  Expanded(
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
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