import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/ui/pages/tasks/task_details/task_details_page.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

// Model para Task
class Task {
  final int id;
  final String title;
  final String description;
  final int points;
  final TaskStatus status;
  final DateTime deadline;
  final String assignedTo;
  final DateTime? completedAt;
  final String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.status,
    required this.deadline,
    required this.assignedTo,
    this.completedAt,
    required this.category,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? points,
    TaskStatus? status,
    DateTime? deadline,
    String? assignedTo,
    DateTime? completedAt,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      assignedTo: assignedTo ?? this.assignedTo,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
    );
  }
}

enum TaskStatus { pendente, concluido, vencido }

// Mock API Service
class MockTaskService {
  static final List<Task> _mockTasks = [
    Task(
      id: 1,
      title: 'Escovar os dentes',
      description: 'Todas as manhãs e de noite com cuidado',
      points: 25,
      status: TaskStatus.pendente,
      deadline: DateTime.now().add(Duration(days: 1)),
      assignedTo: 'João Silva',
      category: 'higiene',
    ),
    Task(
      id: 2,
      title: 'Arrumar a cama',
      description: 'Deixar o quarto sempre organizado',
      points: 15,
      status: TaskStatus.concluido,
      deadline: DateTime.now().subtract(Duration(days: 1)),
      assignedTo: 'Maria Santos',
      completedAt: DateTime.now().subtract(Duration(hours: 2)),
      category: 'casa',
    ),
    Task(
      id: 3,
      title: 'Fazer o dever de casa',
      description: 'Completar todas as atividades escolares',
      points: 50,
      status: TaskStatus.pendente,
      deadline: DateTime.now().add(Duration(hours: 6)),
      assignedTo: 'Pedro Oliveira',
      category: 'estudos',
    ),
    Task(
      id: 4,
      title: 'Organizar os brinquedos',
      description: 'Guardar tudo no lugar certo',
      points: 30,
      status: TaskStatus.vencido,
      deadline: DateTime.now().subtract(Duration(days: 2)),
      assignedTo: 'Ana Costa',
      category: 'casa',
    ),
    Task(
      id: 5,
      title: 'Ajudar na cozinha',
      description: 'Auxiliar no preparo das refeições',
      points: 40,
      status: TaskStatus.concluido,
      deadline: DateTime.now().subtract(Duration(hours: 12)),
      assignedTo: 'João Silva',
      completedAt: DateTime.now().subtract(Duration(hours: 5)),
      category: 'casa',
    ),
    Task(
      id: 6,
      title: 'Ler um livro',
      description: 'Ler pelo menos 30 páginas',
      points: 35,
      status: TaskStatus.pendente,
      deadline: DateTime.now().add(Duration(days: 3)),
      assignedTo: 'Maria Santos',
      category: 'estudos',
    ),
  ];

  // Simula delay de API
  static Future<List<Task>> getTasks({
    String? childName,
    DateTime? date,
    TaskStatus? status,
    String? category,
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simula latência

    List<Task> filteredTasks = List.from(_mockTasks);

    // Filtro por criança
    if (childName != null && childName.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) => task.assignedTo == childName)
          .toList();
    }

    // Filtro por data
    if (date != null) {
      filteredTasks = filteredTasks.where((task) {
        return task.deadline.day == date.day &&
               task.deadline.month == date.month &&
               task.deadline.year == date.year;
      }).toList();
    }

    // Filtro por status
    if (status != null) {
      filteredTasks = filteredTasks
          .where((task) => task.status == status)
          .toList();
    }

    // Filtro por categoria
    if (category != null && category.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) => task.category == category)
          .toList();
    }

    return filteredTasks;
  }

  static Future<bool> updateTaskStatus(int taskId, TaskStatus newStatus) async {
    await Future.delayed(Duration(milliseconds: 300));

    final taskIndex = _mockTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _mockTasks[taskIndex] = _mockTasks[taskIndex].copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.concluido ? DateTime.now() : null,
      );
      return true;
    }
    return false;
  }
}

class TasksPage extends StatefulWidget {
  final UserType userType;

  const TasksPage({super.key, required this.userType});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String? selectedChild;
  DateTime? selectedDate;
  TaskStatus? selectedStatus;
  String? selectedCategory;
  
  List<Task> tasks = [];
  bool isLoading = true;

  // Lista de crianças
  final List<String> children = [
    'João Silva',
    'Maria Santos',
    'Pedro Oliveira',
    'Ana Costa',
  ];

  final List<String> categories = [
    'higiene',
    'casa',
    'estudos',
    'lazer',
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedTasks = await MockTaskService.getTasks(
        childName: selectedChild,
        date: selectedDate,
        status: selectedStatus,
        category: selectedCategory,
      );

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar tarefas: $e')),
      );
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
      setState(() {
        selectedDate = picked;
      });
      _loadTasks();
    }
  }

  void _clearFilters() {
    setState(() {
      selectedChild = null;
      selectedDate = null;
      selectedStatus = null;
      selectedCategory = null;
    });
    _loadTasks();
  }

  String get formattedDate {
    if (selectedDate == null) return 'Selecione a data';
    final day = selectedDate!.day.toString().padLeft(2, '0');
    final month = selectedDate!.month.toString().padLeft(2, '0');
    final year = selectedDate!.year;
    return '$day/$month/$year';
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendente:
        return 'Pendente';
      case TaskStatus.concluido:
        return 'Concluído';
      case TaskStatus.vencido:
        return 'Vencido';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendente:
        return Colors.orange;
      case TaskStatus.concluido:
        return AppColors.primary;
      case TaskStatus.vencido:
        return Colors.red;
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
          if (widget.userType == UserType.responsible) _buildFilters(),
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
              items: children.map((String child) {
                return DropdownMenuItem<String>(
                  value: child,
                  child: Text(child, style: const TextStyle(fontSize: 14)),
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

          // Row com data e categoria
          Row(
            children: [
              // Seletor de data
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              color: selectedDate == null ? Colors.grey : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Filtro de categoria
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                      hintText: 'Categoria',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                    dropdownColor: Colors.white,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category.toUpperCase(), style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                      _loadTasks();
                    },
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: 0.4, curve: Curves.easeOutBack),

          const SizedBox(height: 12),

          // Filtro de status
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<TaskStatus>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                      hintText: 'Status da tarefa',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                    dropdownColor: Colors.white,
                    items: TaskStatus.values.map((TaskStatus status) {
                      return DropdownMenuItem<TaskStatus>(
                        value: status,
                        child: Text(_getStatusText(status), style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (TaskStatus? newValue) {
                      setState(() {
                        selectedStatus = newValue;
                      });
                      _loadTasks();
                    },
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(begin: -0.4, curve: Curves.easeOutBack),

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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TaskCard(
          task: tasks[index],
          showDetails: widget.userType == UserType.responsible,
          animationDelay: index * 150,
          onStatusChanged: (taskId, newStatus) async {
            final success = await MockTaskService.updateTaskStatus(taskId, newStatus);
            if (success) {
              _loadTasks(); // Recarrega a lista
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tarefa ${newStatus == TaskStatus.concluido ? 'concluída' : 'atualizada'}!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedChild != null ||
           selectedDate != null ||
           selectedStatus != null ||
           selectedCategory != null;
  }
}

class TaskCard extends StatefulWidget {
  final Task task;
  final bool showDetails;
  final int animationDelay;
  final Function(int taskId, TaskStatus newStatus)? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
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
    if (widget.task.status == TaskStatus.concluido) return;

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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sim, confirmar'),
          ),
        ],
      ),
    );

    if (shouldComplete == true) {
      _checkboxController.forward();
      widget.onStatusChanged?.call(widget.task.id, TaskStatus.concluido);
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

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendente:
        return Colors.orange;
      case TaskStatus.concluido:
        return AppColors.primary;
      case TaskStatus.vencido:
        return Colors.red;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendente:
        return 'Pendente';
      case TaskStatus.concluido:
        return 'Concluído';
      case TaskStatus.vencido:
        return 'Vencido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.concluido;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: widget.task.status == TaskStatus.vencido 
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
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          decoration: isCompleted && !widget.showDetails ? TextDecoration.lineThrough : null,
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: (widget.animationDelay + 100).ms).slideX(begin: 0.3),

                      const SizedBox(height: 4),

                      Text(
                        widget.task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          decoration: isCompleted && !widget.showDetails ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).animate().fadeIn(duration: 500.ms, delay: (widget.animationDelay + 200).ms).slideX(begin: 0.3),
                    ],
                  ),
                ),

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (widget.animationDelay + 300).ms)
                        .scale(begin: const Offset(0, 0), curve: Curves.elasticOut),
                    const SizedBox(width: 4),
                    Text(
                      _formatPoints(widget.task.points),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Status: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(
                        _getStatusText(widget.task.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(widget.task.status),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 500).ms).slideX(begin: -0.3),

                  Row(
                    children: [
                      Text('Prazo: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(
                        _formatDate(widget.task.deadline),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkText),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 600).ms).slideX(begin: 0.3),
                ],
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsPage(
                          title: widget.task.title,
                          description: widget.task.description,
                          points: widget.task.points,
                          status: _getStatusText(widget.task.status),
                          deadline: _formatDate(widget.task.deadline),
                          assignedTo: widget.task.assignedTo,
                          proofPhotos: const [],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Detalhes',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
                    'Prazo: ${_formatDate(widget.task.deadline)}',
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
                    'Concluído em ${widget.task.completedAt != null ? _formatDate(widget.task.completedAt!) : 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: (widget.animationDelay + 600).ms).slideX(begin: 0.3),
                ],
              ),
            ],

            if (!widget.showDetails && widget.task.status == TaskStatus.vencido) ...[
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
    ).animate().fadeIn(duration: 600.ms, delay: widget.animationDelay.ms).slideY(begin: 0.3, curve: Curves.easeOutBack).scale(begin: const Offset(0.9, 0.9));
  }

  double _getProgressValue() {
    final now = DateTime.now();
    final deadline = widget.task.deadline;
    
    if (now.isAfter(deadline)) {
      return 1.0; // Vencido
    }
    
    // Simula progresso baseado no tempo restante
    final totalTime = deadline.difference(DateTime.now().subtract(Duration(days: 7))).inMilliseconds;
    final remainingTime = deadline.difference(now).inMilliseconds;
    
    return 1.0 - (remainingTime / totalTime).clamp(0.0, 1.0);
  }
  
  Color _getProgressColor() {
    final now = DateTime.now();
    final deadline = widget.task.deadline;
    final hoursUntilDeadline = deadline.difference(now).inHours;
    
    if (hoursUntilDeadline < 0) {
      return Colors.red; // Vencido
    } else if (hoursUntilDeadline < 24) {
      return Colors.orange; // Urgente
    } else {
      return AppColors.primary; // Normal
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
}