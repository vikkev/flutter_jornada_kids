import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/presentation/pages/tasks/task_details/task_details_page.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/models/tarefa.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/services/api_config.dart';
import 'package:flutter_jornadakids/app/services/responsible_service.dart';
import 'package:flutter_jornadakids/app/services/task_service.dart';
import 'package:dio/dio.dart'; // Adicione para o post concluir tarefa

class TasksPage extends StatefulWidget {
  final TipoUsuario userType;
  final Usuario usuario;
  final int idParaRequests; // <-- adicione

  const TasksPage({super.key, required this.userType, required this.usuario, required this.idParaRequests});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String? selectedChild;
  DateTime? selectedDate;
  String? selectedCategory;
  List<Tarefa> tasks = [];
  List<ChildInfo> children = [];
  bool isLoading = true;
  bool isLoadingChildren = true;
  bool _showInitialAnimation = true;

  @override
  void initState() {
    super.initState();
    if (widget.userType == TipoUsuario.responsavel) {
      _loadChildren();
    } else {
      _loadTasks();
    }
  }

  Future<void> _loadChildren() async {
    setState(() {
      isLoadingChildren = true;
    });
    try {
      final fetchedChildren = await ResponsibleService().fetchChildren(widget.idParaRequests);
      setState(() {
        children = fetchedChildren;
        isLoadingChildren = false;
      });
      _loadTasks();
    } catch (e) {
      setState(() {
        isLoadingChildren = false;
      });
      // Tratar erro se necessário
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final taskService = TaskService();
      List<TaskResponse> responses = [];
      if (widget.userType == TipoUsuario.responsavel) {
        int? criancaId;
        if (selectedChild != null && selectedChild!.isNotEmpty) {
          final child = children.firstWhere((c) => c.nome == selectedChild, orElse: () => children.first);
          criancaId = child.id;
        }
        responses = await taskService.fetchTarefasDoResponsavel(
          responsavelId: widget.idParaRequests,
          criancaId: criancaId,
          status: null,
        );
      } else {
        // Para criança/adolescente, buscar tarefas dela corretamente
        responses = await taskService.fetchTarefasDaCrianca(widget.idParaRequests);
      }
      setState(() {
        tasks = responses
            .map((t) => _taskResponseToTarefa(t))
            .where((t) {
              if (widget.userType == TipoUsuario.crianca) {
                // Só mostra tarefas da criança logada (id da tarefa/criança igual ao id do usuário logado)
                return t.responsavelId == widget.usuario.id || t.responsavelId == widget.usuario.idExterno;
              }
              if (selectedDate != null) {
                return t.dataLimite.day == selectedDate!.day &&
                       t.dataLimite.month == selectedDate!.month &&
                       t.dataLimite.year == selectedDate!.year;
              }
              return true;
            })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Tratar erro se necessário
    }
  }

  Tarefa _taskResponseToTarefa(TaskResponse response) {
    int responsavelId = 0;
    String nomeResponsavelOuCrianca = '';
    if (widget.userType == TipoUsuario.crianca) {
      // Estrutura: responsavel é objeto
      responsavelId = response.responsavel?['id'] ?? 0;
      nomeResponsavelOuCrianca = response.responsavel?['usuario']?['nomeCompleto'] ?? '';
    } else {
      // Estrutura: crianca é objeto
      responsavelId = response.crianca?['id'] ?? 0;
      nomeResponsavelOuCrianca = response.crianca?['usuario']?['nomeCompleto'] ?? '';
    }
    return Tarefa(
      id: response.id,
      responsavelId: responsavelId,
      titulo: response.titulo,
      descricao: response.descricao ?? '',
      ponto: response.pontuacaoTotal,
      prioridade: PrioridadeTarefaExtension.fromCode(
        response.prioridade.length == 1
          ? response.prioridade
          : _prioridadeLabelToCode(response.prioridade)
      ),
      foto: null,
      situacao: SituacaoTarefaExtension.fromCode(
        response.situacao.length == 1
          ? response.situacao
          : _situacaoLabelToCode(response.situacao)
      ),
      dataLimite: DateTime.tryParse(response.dataHoraLimite) ?? DateTime.now(),
      criadoEm: DateTime.tryParse(response.criadoEm ?? '') ?? DateTime.now(),
      atualizadoEm: DateTime.tryParse(response.atualizadoEm ?? '') ?? DateTime.now(),
    );
  }

  String _prioridadeLabelToCode(String label) {
    switch (label.toLowerCase()) {
      case 'alta':
        return 'A';
      case 'média':
      case 'media':
        return 'M';
      case 'baixa':
        return 'B';
      default:
        return 'M';
    }
  }

  String _situacaoLabelToCode(String label) {
    switch (label.toLowerCase()) {
      case 'pendente':
        return 'P';
      case 'expirada':
        return 'E';
      case 'concluída':
      case 'concluida':
        return 'C';
      case 'avaliada':
        return 'A';
      default:
        return 'P';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      if (!mounted) return;
      setState(() {
        selectedDate = picked;
      });
      _loadTasks();
    }
  }

  void _clearFilters() {
    if (!mounted) return;
    setState(() {
      selectedChild = null;
      selectedDate = null;
      selectedCategory = null;
    });
    _loadTasks();
  }


  String _getStatusText(SituacaoTarefa status) {
    switch (status) {
      case SituacaoTarefa.P:
        return 'Pendente';
      case SituacaoTarefa.C:
        return 'Concluída';
      case SituacaoTarefa.E:
        return 'Vencida';
      case SituacaoTarefa.A:
        return 'Aguardando';
    }
  }

  Color _getStatusColor(SituacaoTarefa status) {
    switch (status) {
      case SituacaoTarefa.P:
        return Colors.orange;
      case SituacaoTarefa.C:
        return Colors.green;
      case SituacaoTarefa.E:
        return Colors.red;
      case SituacaoTarefa.A:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'Tarefas',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            if (_hasActiveFilters())
              IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: _clearFilters,
                tooltip: 'Limpar filtros',
              ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, curve: Curves.easeOut),
      ),
      body: Column(
        children: [
          if (widget.userType == TipoUsuario.responsavel) _buildFilters(),
          Expanded(
            child: isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : tasks.isEmpty
                ? _buildEmptyState()
                : _buildTasksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    if (isLoadingChildren) {
      return const Center(child: CircularProgressIndicator());
    }
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown de crianças
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedChild,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  hintText: 'Selecione a criança/adolescente',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                dropdownColor: Colors.white,
                items: children.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.nome,
                    child: Text(c.nome, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedChild = newValue;
                  });
                  _loadTasks();
                },
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.4, curve: Curves.easeOutBack),

            const SizedBox(height: 12),

            // Divider
            Divider(color: Colors.grey.shade300)
                .animate()
                .fadeIn(duration: 400.ms, delay: 800.ms)
                .scale(begin: const Offset(0, 1)),
          ],
        ),
      );
    }

    Widget _buildEmptyState() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
    }

    Widget _buildTasksList() {
      // Só mostra animação na primeira renderização
      final showAnimation = _showInitialAnimation;
      _showInitialAnimation = false;
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            tarefa: tasks[index],
            responsavel: _childInfoToUsuario(children.firstWhere((c) => c.id == tasks[index].responsavelId, orElse: () => ChildInfo(id: 0, idade: 0, nivel: 0, nome: '', ponto: 0))),
            showDetails: widget.userType == TipoUsuario.responsavel,
            animationDelay: showAnimation ? index * 150 : 0,
            onStatusChanged: (taskId, newStatus) async {
              setState(() {
                final idx = tasks.indexWhere((t) => t.id == taskId);
                if (idx != -1) {
                  tasks[idx] = tasks[idx].copyWith(situacao: newStatus);
                }
              });
            },
          ),
        ),
      );
    }

    bool _hasActiveFilters() {
      return selectedChild != null ||
            selectedDate != null ||
            selectedCategory != null;
    }

    Usuario _childInfoToUsuario(ChildInfo child) {
      return Usuario(
        id: child.id,
        nomeCompleto: child.nome,
        nomeUsuario: child.nome,
        email: '',
        telefone: '',
        senha: '',
        tipoUsuario: TipoUsuario.crianca,
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );
    }
  }

  class TaskCard extends StatefulWidget {
  final Tarefa tarefa;
  final Usuario responsavel;
  final bool showDetails;
  final int animationDelay;
  final Function(int taskId, SituacaoTarefa newStatus)? onStatusChanged;

  const TaskCard({
    super.key,
    required this.tarefa,
    required this.responsavel,
    required this.showDetails,
    this.animationDelay = 0,
    this.onStatusChanged,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _checkboxController;

  @override
  void initState() {
    super.initState();
    _checkboxController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _checkboxController.dispose();
    super.dispose();
  }

  void _toggleCompleted() async {
    if (widget.tarefa.situacao == SituacaoTarefa.C) return;

    final shouldComplete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Tem certeza que deseja marcar esta tarefa como concluída?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gray200),
            child: const Text('Sim, confirmar'),
          ),
        ],
      ),
    );

    if (shouldComplete == true) {
      // Se for criança, faz o post para concluir tarefa
      final isCrianca = widget.responsavel.tipoUsuario == TipoUsuario.crianca;
      if (isCrianca) {
        try {
          final dio = Dio();
          final url = '${ApiConfig.api}/tarefas/${widget.tarefa.id}/concluir';
          await dio.post(url);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao concluir tarefa: $e'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }
      _checkboxController.forward();
      widget.onStatusChanged?.call(widget.tarefa.id, SituacaoTarefa.C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.tarefa.situacao == SituacaoTarefa.C;
    return GestureDetector(
      onTap: widget.showDetails
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskDetailsPage(
                    tarefa: widget.tarefa,
                    responsavel: widget.responsavel,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: widget.tarefa.situacao == SituacaoTarefa.E
              ? Border.all(color: Colors.red, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.showDetails)
                    GestureDetector(
                      onTap: isCompleted ? null : _toggleCompleted,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0, top: 2.0),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? AppColors.primary : Colors.white,
                            border: Border.all(
                              color: isCompleted ? AppColors.primary : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  .animate(controller: _checkboxController)
                                  .scale(begin: const Offset(0, 0))
                                  .fadeIn()
                              : null,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 200).ms).scale(begin: const Offset(0.5, 0.5))
                  else
                    const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tarefa.titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            decoration: isCompleted && !widget.showDetails ? TextDecoration.lineThrough : null,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: (widget.animationDelay + 100).ms).slideX(begin: 0.3),
                        const SizedBox(height: 4),
                        Text(
                          widget.tarefa.descricao,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            decoration: isCompleted && !widget.showDetails ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).animate().fadeIn(duration: 500.ms, delay: (widget.animationDelay + 200).ms).slideX(begin: 0.3),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Status: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                Text(
                                  _getStatusText(widget.tarefa.situacao),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(widget.tarefa.situacao),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text('Prazo: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                Text(
                                  _formatDate(widget.tarefa.dataLimite),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_formatPoints(widget.tarefa.ponto)} pontos',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 400).ms).slideX(begin: 0.5),
                    ],
                  ),
                ],
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsPage(
                            tarefa: widget.tarefa,
                            responsavel: widget.responsavel,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Detalhes',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: (widget.animationDelay + 700).ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut).shimmer(duration: 1500.ms, delay: (widget.animationDelay + 1200).ms),
              ],
              if (!widget.showDetails && !isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (widget.animationDelay + 500).ms)
                        .scale(begin: const Offset(0, 0)),
                    const SizedBox(width: 4),
                    Text(
                      'Prazo: ${_formatDate(widget.tarefa.dataLimite)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 600).ms).slideX(begin: 0.3),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(),
                    backgroundColor: Colors.grey.shade300,
                    color: _getProgressColor(),
                    minHeight: 6,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: (widget.animationDelay + 700).ms).slideX(begin: -1.0, curve: Curves.easeOutCubic),
              ],
              if (!widget.showDetails && isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.celebration, size: 16, color: Colors.green)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (widget.animationDelay + 500).ms)
                        .scale(begin: const Offset(0, 0), curve: Curves.elasticOut),
                    const SizedBox(width: 4),
                    Text(
                      'Concluído',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 600).ms).slideX(begin: 0.3),
                  ],
                ),
              ],
              if (!widget.showDetails && widget.tarefa.situacao == SituacaoTarefa.E) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: Colors.red)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (widget.animationDelay + 500).ms)
                        .scale(begin: const Offset(0, 0), curve: Curves.elasticOut),
                    const SizedBox(width: 4),
                    Text(
                      'Tarefa vencida',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 600).ms).slideX(begin: 0.3),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _getProgressValue() {
    // Progresso: (agora - criadoEm) / (dataLimite - criadoEm)
    final now = DateTime.now();
    final criado = widget.tarefa.criadoEm;
    final deadline = widget.tarefa.dataLimite;
    if (now.isAfter(deadline)) {
      return 1.0;
    }
    final total = deadline.difference(criado).inSeconds;
    final done = now.difference(criado).inSeconds;
    if (total <= 0) return 1.0;
    return (done / total).clamp(0.0, 1.0);
  }
  
  Color _getProgressColor() {
    // Verde se < 70%, amarelo se >=70% e < 100%, vermelho se >=100%
    final progress = _getProgressValue();
    if (progress >= 1.0) {
      return Colors.red;
    } else if (progress >= 0.7) {
      return Colors.orange;
    } else {
      return AppColors.primary;
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}