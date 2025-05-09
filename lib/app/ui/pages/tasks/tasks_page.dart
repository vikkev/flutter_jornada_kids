import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

// enum UserType {
//   responsible,
//   child,
// }

class TasksPage extends StatelessWidget {
  final UserType userType;
  
  const TasksPage({
    super.key,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,  // Impede a exibição do botão de voltar
        title: const Text(
          'Tarefas',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtros - apenas visíveis para responsáveis
          if (userType == UserType.responsible)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filtro de criança
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Selecione a criança/adolescente',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Filtro de data
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Selecione a data',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Linha divisória
                  Divider(color: Colors.grey.shade300),
                ],
              ),
            ),
          
          // Lista de tarefas - visível para ambos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 5, // Número de tarefas de exemplo
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  title: 'Escovar os dentes',
                  description: 'Todas as manhãs e de noite com cuidado',
                  points: 323232,
                  status: 'pendente',
                  deadline: '02/20/2025 14:50',
                  showDetails: userType == UserType.responsible,
                  isCompleted: index == 2, // Apenas para exemplo: terceira tarefa completada
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final int points;
  final String status;
  final String deadline;
  final bool showDetails;
  final bool isCompleted;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.points,
    required this.status,
    required this.deadline,
    required this.showDetails,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da tarefa
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox para crianças
                if (!showDetails)
                  Padding(
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
                          : null,
                    ),
                  ),
                
                // Título e descrição
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          decoration: isCompleted && !showDetails
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          decoration: isCompleted && !showDetails
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Pontos com estrela
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatPoints(points),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Status e prazo - apenas para responsáveis
            if (showDetails) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: status.toLowerCase() == 'pendente'
                              ? Colors.orange
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Prazo: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        deadline,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Botão de detalhes - apenas para responsáveis
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Detalhes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            
            // Para crianças, mostrar apenas uma barra de progresso de tempo
            if (!showDetails && !isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Prazo: $deadline',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Barra de progresso de tempo - só um exemplo visual
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.7, // Exemplo: 70% do tempo já passou
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.orange,
                  minHeight: 6,
                ),
              ),
            ],
            
            // Para tarefas completas (para crianças), mostrar mensagem motivacional
            if (!showDetails && isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.celebration, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Concluído em 20/02/2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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

// Como usar:
// 
// Para versão dos responsáveis:
// TasksPage(userType: UserType.responsible)
//
// Para versão das crianças:
// TasksPage(userType: UserType.child)
