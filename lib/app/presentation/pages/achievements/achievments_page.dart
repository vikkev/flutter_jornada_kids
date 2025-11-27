import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/services/achievements_service.dart';
import 'package:flutter_jornadakids/app/presentation/pages/app_blocker/app_blocker_page.dart';

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

class _AchievementsPageState extends State<AchievementsPage>
    with TickerProviderStateMixin {
  final _achievementsService = AchievementsService();
  List<RecompensaResponse> recompensas = [];
  bool isLoading = true;
  late AnimationController _shimmerController;
  late AnimationController _headerController;
  // Lista de IDs de recompensas resgatadas localmente
  Set<int> recompensasResgatadas = {};

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _carregarRecompensas();
    _headerController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _carregarRecompensas() async {
    if (!mounted) return; // <- Adicionado para evitar setState após dispose
    setState(() => isLoading = true);
    try {
      final listaRecompensas = await _achievementsService.fetchRecompensas(
        responsavelId: widget.idResponsavel,
        criancaId: widget.idCrianca,
      );
      if (!mounted) return; // <- Adicionado para evitar setState após dispose
      setState(() {
        recompensas = listaRecompensas;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // <- Adicionado para evitar setState após dispose
      setState(() => isLoading = false);
      _showCustomSnackBar('Erro ao carregar recompensas: $e', isError: true);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _adicionarRecompensa() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final tituloController = TextEditingController();
        final obsController = TextEditingController();
        final pontosController = TextEditingController();
        final quantidadeController = TextEditingController();
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Nova Recompensa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(tituloController, 'Título', Icons.title),
                const SizedBox(height: 16),
                _buildTextField(obsController, 'Descrição', Icons.description),
                const SizedBox(height: 16),
                _buildTextField(pontosController, 'Pontos necessários', Icons.emoji_events, isNumber: true),
                const SizedBox(height: 16),
                _buildTextField(quantidadeController, 'Quantidade de resgate', Icons.confirmation_num, isNumber: true),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.gray200),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _validarESalvarRecompensa(
                          context,
                          tituloController,
                          obsController,
                          pontosController,
                          quantidadeController,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Salvar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          quantidade: result['quantidade'],
        );
        _carregarRecompensas();
        if (mounted) {
          _showCustomSnackBar('Recompensa criada com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          _showCustomSnackBar('Erro ao criar recompensa: $e', isError: true);
        }
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.lightGray,
      ),
    );
  }

  void _validarESalvarRecompensa(
    BuildContext context,
    TextEditingController tituloController,
    TextEditingController obsController,
    TextEditingController pontosController,
    TextEditingController quantidadeController,
  ) {
    if (tituloController.text.isEmpty || pontosController.text.isEmpty || quantidadeController.text.isEmpty) {
      _showCustomSnackBar('Preencha todos os campos obrigatórios!', isError: true);
      return;
    }

    final pontuacao = int.tryParse(pontosController.text) ?? 0;
    final quantidade = int.tryParse(quantidadeController.text) ?? 0;
    if (pontuacao <= 0) {
      _showCustomSnackBar('A pontuação necessária deve ser maior que zero!', isError: true);
      return;
    }
    if (quantidade <= 0) {
      _showCustomSnackBar('A quantidade deve ser maior que zero!', isError: true);
      return;
    }

    Navigator.of(context).pop({
      'titulo': tituloController.text,
      'observacao': obsController.text,
      'pontuacaoNecessaria': pontuacao,
      'quantidade': quantidade,
    });
  }

  void _excluirRecompensa(RecompensaResponse recompensa) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Excluir Recompensa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tem certeza que deseja excluir a recompensa "${recompensa.titulo}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          _showCustomSnackBar('Recompensa excluída com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          _showCustomSnackBar('Erro ao excluir recompensa: $e', isError: true);
        }
      }
    }
  }

  void _resgatarRecompensa(RecompensaResponse recompensa) async {
    if (widget.pontosDisponiveis >= recompensa.pontuacaoNecessaria) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.amber.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade400],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Resgatar Recompensa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deseja resgatar "${recompensa.titulo}" por ${recompensa.pontuacaoNecessaria} pontos?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          try {
                            await _achievementsService.resgatarRecompensa(
                              recompensaId: recompensa.id,
                              idCrianca: widget.idCrianca!,
                            );
                            await _carregarRecompensas();
                            _showCustomSnackBar('Recompensa "${recompensa.titulo}" resgatada com sucesso!');
                          } catch (e) {
                            _showCustomSnackBar('Erro ao resgatar recompensa: $e', isError: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Resgatar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      _showCustomSnackBar('Estrelas insuficientes!', isError: true);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
           AppColors.secondary,
            AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recompensas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.userType == TipoUsuario.crianca)
                        Text(
                          '${widget.pontosDisponiveis} pontos disponíveis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (widget.userType == TipoUsuario.responsavel)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _adicionarRecompensa,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Adicionar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3);
  }

  Widget _buildMinecraftCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppBlockerPage(
              userType: widget.userType,
              idResponsavel: widget.idResponsavel,
              idCrianca: widget.idCrianca,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Minecraft background image
                    Positioned.fill(
                      child: Image.asset(
                        'images/minecraft-background.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Dark overlay for better text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Positioned.fill(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.games,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.userType == TipoUsuario.responsavel
                                        ? 'Adicionar Jogos'
                                        : 'Desbloquear Jogos',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.userType == TipoUsuario.responsavel
                                        ? 'Adicione novos jogos para as crianças'
                                        : 'Desbloqueie jogos com suas estrelas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                      shadows: const [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: 0.2)
          .shimmer(
            delay: 200.ms,
            duration: 1000.ms,
            color: Colors.white.withOpacity(0.3),
          ),
    );
  }

  Widget _buildRecompensaCard(RecompensaResponse recompensa, int index) {
    final canRedeem = widget.pontosDisponiveis >= recompensa.pontuacaoNecessaria;
    final isResgatada = recompensasResgatadas.contains(recompensa.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isResgatada ? AppColors.gray200 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: !isResgatada && canRedeem && widget.userType == TipoUsuario.crianca
                  ? Border.all(color: Colors.amber.shade200, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isResgatada
                        ? LinearGradient(colors: [AppColors.gray300, AppColors.gray400])
                        : LinearGradient(
                            colors: canRedeem && widget.userType == TipoUsuario.crianca
                                ? [Colors.amber.shade400, Colors.orange.shade400]
                                : [AppColors.primary, AppColors.secondary],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isResgatada ? 'Resgatado' : recompensa.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Disponível: ${recompensa.quantidade}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recompensa.observacao,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray400,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade100, Colors.amber.shade50],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recompensa.pontuacaoNecessaria} pontos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.userType == TipoUsuario.crianca)
                  Container(
                    decoration: BoxDecoration(
                      gradient: isResgatada
                          ? LinearGradient(colors: [AppColors.gray300, AppColors.gray400])
                          : canRedeem
                              ? LinearGradient(
                                  colors: [Colors.amber.shade400, Colors.orange.shade400],
                                )
                              : LinearGradient(
                                  colors: [AppColors.gray200, AppColors.gray400],
                                ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      onPressed: (!isResgatada && canRedeem) ? () => _resgatarRecompensa(recompensa) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        isResgatada
                            ? 'Resgatado'
                            : (canRedeem ? 'Resgatar' : 'Bloqueado'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (widget.userType == TipoUsuario.responsavel)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade600,
                        size: 18,
                      ),
                    ),
                    tooltip: 'Excluir',
                    onPressed: () => _excluirRecompensa(recompensa),
                  ),
              ],
            ),
          ),
          if (!isResgatada && canRedeem && widget.userType == TipoUsuario.crianca)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Disponível!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (index * 100).ms)
        .slideX(begin: 0.2)
        .shimmer(
          delay: (index * 200).ms,
          duration: 1000.ms,
          color: canRedeem ? Colors.amber.withOpacity(0.3) : Colors.transparent,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: recompensas.isEmpty ? 2 : recompensas.length + 1, // +1 for Minecraft card, +1 for empty state
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Minecraft card always at the top
                          return _buildMinecraftCard();
                        } else if (recompensas.isEmpty) {
                          // Empty state when no rewards
                          return Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.gray100,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.emoji_events_outlined,
                                    size: 48,
                                    color: AppColors.gray300,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma recompensa disponível',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.gray400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.userType == TipoUsuario.responsavel
                                      ? 'Adicione recompensas para motivar as crianças/adolescentes!'
                                      : 'Aguarde novas recompensas serem adicionadas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8));
                        } else {
                          // Regular reward cards
                          final recompensa = recompensas[index - 1];
                          return _buildRecompensaCard(recompensa, index - 1);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
