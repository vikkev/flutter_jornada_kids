import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/presentation/pages/achievements/achievments_page.dart';
import 'package:flutter_jornadakids/app/presentation/pages/settings/settings_page.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart' as constants;
import 'package:flutter_jornadakids/app/presentation/widgets/app_navbar.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/create_task_widget.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/ranking_widget.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/score_widget.dart';
import 'package:flutter_jornadakids/app/presentation/pages/tasks/tasks_page.dart';
import 'package:flutter_jornadakids/app/services/responsible_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_jornadakids/app/services/api_config.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final Usuario usuario;

  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late StreamController<int> _pontosController;
  Timer? _pontosTimer;
  int pontosAtuais = 0;

  @override
  void initState() {
    super.initState();
    _pontosController = StreamController<int>.broadcast();
    pontosAtuais = widget.usuario.pontos ?? 0;
    if (widget.usuario.tipoUsuario == TipoUsuario.crianca) {
      _iniciarAtualizacaoPontos();
    }
  }

  void _iniciarAtualizacaoPontos() {
    // Atualiza imediatamente
    _atualizarPontos();
    
    // Configura o timer para atualizar a cada 5 segundos
    _pontosTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _atualizarPontos();
    });
  }

  Future<void> _atualizarPontos() async {
    if (widget.usuario.tipoUsuario != TipoUsuario.crianca) return;
    
    try {
      final dio = Dio();
      final url = '${ApiConfig.api}/criancas/${widget.usuario.idExterno ?? widget.usuario.id}';
      final response = await dio.get(url);
      
      if (response.statusCode == 200 && response.data != null) {
        final novoPonto = response.data['ponto'] ?? 0;
        if (novoPonto != pontosAtuais) {
          pontosAtuais = novoPonto;
          widget.usuario.pontos = novoPonto;
          _pontosController.add(novoPonto);
        }
      }
    } catch (e) {
      // Ignora erros para não interromper a experiência do usuário
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pontosController.close();
    _pontosTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
          // Home
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Header com saudação
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ).animate().fadeIn(duration: 500.ms),
                              const SizedBox(height: 4),
                              Text(
                                    _getFirstAndLastName(
                                      widget.usuario.nomeCompleto,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: constants.AppColors.darkText,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slideX(begin: -0.2),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Widget de criar tarefa ou pontuação
                      if (widget.usuario.tipoUsuario == TipoUsuario.responsavel)
                        CreateTaskWidget(
                              responsavelId:
                                  widget.usuario.idExterno ?? widget.usuario.id,
                              usuarioResponsavel: widget.usuario,
                            )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0)
                      else
                        StreamBuilder<int>(
                          stream: _pontosController.stream,
                          initialData: widget.usuario.pontos ?? 0,
                          builder: (context, snapshot) {
                            return ScoreWidget(
                              usuario: Usuario(
                                id: widget.usuario.id,
                                nomeCompleto: widget.usuario.nomeCompleto,
                                nomeUsuario: widget.usuario.nomeUsuario,
                                email: widget.usuario.email,
                                telefone: widget.usuario.telefone,
                                senha: widget.usuario.senha,
                                tipoUsuario: widget.usuario.tipoUsuario,
                                criadoEm: widget.usuario.criadoEm,
                                atualizadoEm: widget.usuario.atualizadoEm,
                                pontos: snapshot.data,
                              ),
                            ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.3, end: 0);
                          },
                        ),
                      const SizedBox(height: 20),
                      // Lista de crianças (apenas para responsável)
                      if (widget.usuario.tipoUsuario == TipoUsuario.responsavel)
                        FutureBuilder<List<ChildInfo>>(
                          future: ResponsibleService().fetchChildren(
                            widget.usuario.idExterno ?? widget.usuario.id,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text(
                                'Erro ao carregar crianças: ${snapshot.error}',
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('Nenhuma criança cadastrada');
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Crianças/Adolescentes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: constants.AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final child = snapshot.data![index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: constants.AppColors.primary
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color:
                                                  constants.AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  child.nome,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${child.ponto} pontos',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: constants.AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Nível ${child.nivel}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    constants.AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                      // Ranking
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: RankingWidget(usuario: widget.usuario)
                            .animate()
                            .fadeIn(delay: 900.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Tarefas
          TasksPage(
            userType: widget.usuario.tipoUsuario,
            usuario: widget.usuario,
            idParaRequests: widget.usuario.idExterno ?? widget.usuario.id,
          ),
          // Recompensas
          AchievementsPage(
            userType: widget.usuario.tipoUsuario,
            pontosDisponiveis: pontosAtuais,
            idResponsavel: widget.usuario.tipoUsuario == TipoUsuario.crianca
                ? widget.usuario.idResponsavel ?? 0
                : widget.usuario.idExterno ?? widget.usuario.id,
            idCrianca:
                widget.usuario.tipoUsuario == TipoUsuario.crianca
                    ? widget.usuario.idExterno ?? widget.usuario.id
                    : null,
          ),
          // Configurações
          SettingsPage(usuario: widget.usuario),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: _currentIndex,
        onPageChanged: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia,';
    } else if (hour < 18) {
      return 'Boa tarde,';
    } else {
      return 'Boa noite,';
    }
  }

  String _getFirstAndLastName(String nomeCompleto) {
    final parts = nomeCompleto.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0];
    return parts.first + ' ' + parts.last;
  }
}
