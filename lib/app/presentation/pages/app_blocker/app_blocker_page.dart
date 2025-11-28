import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/services/applications_service.dart';
import 'package:flutter_jornadakids/app/services/achievements_service.dart';
import 'package:flutter_jornadakids/app/services/api_config.dart';
import 'package:flutter_jornadakids/app/services/responsible_service.dart';

const MethodChannel _appBlockerChannel = MethodChannel('app_blocker_channel');

// =====================
// Verificar e solicitar permissÃƒÆ’Ã‚Â£o
// =====================
Future<bool> checkUsagePermission() async {
  if (Platform.isAndroid) {
    try {
      // Tenta obter dados de uso para verificar se a permissÃƒÆ’Ã‚Â£o foi concedida
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(hours: 1));
      await AppUsage().getAppUsage(startDate, endDate);
      return true; // Se conseguiu obter dados, a permissÃƒÆ’Ã‚Â£o estÃƒÆ’Ã‚Â¡ concedida
    } catch (e) {
      debugPrint('PermissÃƒÆ’Ã‚Â£o de uso nÃƒÆ’Ã‚Â£o concedida: $e');
      return false; // Se deu erro, a permissÃƒÆ’Ã‚Â£o nÃƒÆ’Ã‚Â£o foi concedida
    }
  }
  return true; // Para outras plataformas, assume que estÃƒÆ’Ã‚Â¡ OK
}

Future<void> requestUsagePermission() async {
  if (Platform.isAndroid) {
    // Verifica se a permissÃƒÆ’Ã‚Â£o jÃƒÆ’Ã‚Â¡ foi concedida
    bool hasPermission = await checkUsagePermission();

    if (!hasPermission) {
      // SÃƒÆ’Ã‚Â³ redireciona se a permissÃƒÆ’Ã‚Â£o nÃƒÆ’Ã‚Â£o foi concedida
      final intent = AndroidIntent(
        action: 'android.settings.USAGE_ACCESS_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } else {
      debugPrint('PermissÃƒÆ’Ã‚Â£o de uso jÃƒÆ’Ã‚Â¡ concedida');
    }
  }
}

Future<bool> checkAccessibilityPermission() async {
  if (!Platform.isAndroid) return true;
  try {
    final bool? granted = await _appBlockerChannel.invokeMethod<bool>(
      'isAccessibilityPermissionGranted',
    );
    return granted ?? false;
  } catch (e) {
    debugPrint('Erro ao verificar permissÃƒÆ’Ã‚Â£o de acessibilidade: $e');
    return false;
  }
}

Future<void> requestAccessibilityPermission() async {
  if (!Platform.isAndroid) return;
  try {
    await _appBlockerChannel.invokeMethod('requestAccessibilityPermission');
  } catch (e) {
    debugPrint('Erro ao solicitar permissÃƒÆ’Ã‚Â£o de acessibilidade: $e');
  }
}

// =====================
// Tela de Monitoramento
// =====================
class AppBlockerPage extends StatefulWidget {
  final TipoUsuario userType;
  final int idResponsavel;
  final int? idCrianca;

  const AppBlockerPage({
    super.key,
    required this.userType,
    required this.idResponsavel,
    this.idCrianca,
  });

  @override
  State<AppBlockerPage> createState() => _AppBlockerPageState();
}

class _AppBlockerPageState extends State<AppBlockerPage>
    with WidgetsBindingObserver {
  List<AppUsageInfo> infos = [];
  Map<String, Duration> appLimits = {};
  Map<String, Duration> appUsageToday = {};
  Map<String, Uint8List?> appIcons = {};
  final ApplicationsService _applicationsService = ApplicationsService();
  final AchievementsService _achievementsService = AchievementsService();
  static const String _plusOneRewardTitle = 'Mais 1 min de app';
  static const String _plusOneRewardDescription =
      'Use seus pontos para adicionar 1 minuto extra de uso em um aplicativo bloqueado.';
  static const int _plusOneRewardCost = 10;
  static const int _plusOneRewardQuantidade = 9999;
  List<AplicativoResponse> _remoteApps = [];
  Map<String, AplicativoResponse> _remoteAppsByPackage = {};
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _hasAccessibilityPermission = false;
  int? _resolvedResponsavelId;
  int? _resolvedCriancaId;
  bool _idsResolved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionsAfterResume();
    }
  }

  Future<void> _ensureIdsResolved() async {
    if (_idsResolved) return;

    int? responsavelId = _toInt(widget.idResponsavel);
    int? criancaId = _toInt(widget.idCrianca);

    if (widget.userType == TipoUsuario.crianca) {
      if ((responsavelId == null || responsavelId == 0) &&
          criancaId != null &&
          criancaId > 0) {
        try {
          final dio = Dio();
          final url = '${ApiConfig.api}/criancas/$criancaId';
          final response = await dio.get(url);
          if (response.statusCode == 200 && response.data != null) {
            final responsavel = response.data['responsavel'];
            if (responsavel != null && responsavel['id'] != null) {
              responsavelId = _toInt(responsavel['id']);
            }
          }
        } catch (e) {
          debugPrint('Erro ao resolver responsável para AppBlocker: $e');
        }
      }
    }

    _resolvedResponsavelId = responsavelId;
    _resolvedCriancaId = criancaId;
    _idsResolved = true;
  }

  Future<void> _ensureChildForResponsible() async {
    if (_resolvedCriancaId != null && _resolvedCriancaId != 0) return;
    if (widget.userType != TipoUsuario.responsavel) return;
    final int? responsavelId = _resolvedResponsavelId;
    if (responsavelId == null || responsavelId == 0) return;

    try {
      final children = await ResponsibleService().fetchChildren(responsavelId);
      if (children.length == 1) {
        _resolvedCriancaId = children.first.id;
      }
    } catch (e) {
      debugPrint('Erro ao carregar crianças para responsável: $e');
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  Future<void> _initializeApp() async {
    bool hasUsagePermission = true;
    bool hasAccessibilityPermission = true;
    if (widget.userType == TipoUsuario.crianca) {
      hasUsagePermission = await checkUsagePermission();
      hasAccessibilityPermission = await checkAccessibilityPermission();
    }

    if (!mounted) return;

    setState(() {
      _hasPermission = hasUsagePermission;
      _hasAccessibilityPermission = hasAccessibilityPermission;
    });

    if (widget.userType == TipoUsuario.crianca && !hasUsagePermission) {
      await requestUsagePermission();
      await Future.delayed(const Duration(seconds: 2));
      hasUsagePermission = await checkUsagePermission();
      if (!mounted) return;
      setState(() {
        _hasPermission = hasUsagePermission;
      });
    }

    if (hasUsagePermission || widget.userType == TipoUsuario.responsavel) {
      await loadData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    if (widget.userType == TipoUsuario.crianca && !hasAccessibilityPermission) {
      await _updateAccessibilityStatus(requestIfDenied: true);
    }
  }

  Future<void> _refreshPermissionsAfterResume() async {
    final usageGranted = await checkUsagePermission();
    if (!mounted) return;

    final shouldReloadUsage = usageGranted && !_hasPermission;

    setState(() {
      _hasPermission = usageGranted;
      if (!usageGranted) {
        infos = [];
        appUsageToday = {};
        _isLoading = false;
      }
    });

    await _updateAccessibilityStatus();

    if (shouldReloadUsage) {
      setState(() {
        _isLoading = true;
      });
      await loadData();
    }
  }

  Future<void> _updateAccessibilityStatus({
    bool requestIfDenied = false,
  }) async {
    bool granted = await checkAccessibilityPermission();
    if (!mounted) return;

    setState(() {
      _hasAccessibilityPermission = granted;
    });

    if (!granted && requestIfDenied) {
      await requestAccessibilityPermission();
      await Future.delayed(const Duration(seconds: 1));
      granted = await checkAccessibilityPermission();
      if (!mounted) return;
      setState(() {
        _hasAccessibilityPermission = granted;
      });
    }
  }

  Future<void> _handleUsagePermissionRequest() async {
    await requestUsagePermission();
    await Future.delayed(const Duration(seconds: 2));
    final granted = await checkUsagePermission();
    if (!mounted) return;

    setState(() {
      _hasPermission = granted;
    });

    if (granted) {
      setState(() {
        _isLoading = true;
      });
      await loadData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAccessibilityPermissionRequest() async {
    await _updateAccessibilityStatus(requestIfDenied: true);
  }

  Future<void> loadData() async {
    await _ensureIdsResolved();
    if (!Platform.isAndroid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    await _loadLimits();

    if (widget.userType == TipoUsuario.crianca) {
      await getUsageStats();
      try {
        await _loadAppIcons().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Timeout ao carregar ícones: $e');
      }
      await _syncWithBackendAsChild();
      await _updateNativeBlockedApps();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } else {
      await _loadFromBackendAsResponsible();
      await _loadIconsForRemoteApps();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(hours: 24));
      List<AppUsageInfo> usage = await AppUsage().getAppUsage(
        startDate,
        endDate,
      );

      // Descobre o packageName deste aplicativo para nunca listÃƒÆ’Ã‚Â¡-lo/bloqueÃƒÆ’Ã‚Â¡-lo
      String myPackage = '';
      try {
        final info = await PackageInfo.fromPlatform();
        myPackage = info.packageName;
      } catch (_) {}

      // Remove entradas sem uso e o prÃƒÆ’Ã‚Â³prio app
      usage.removeWhere(
        (app) => app.usage.inSeconds <= 0 || app.packageName == myPackage,
      );
      usage.sort((a, b) => b.usage.compareTo(a.usage));

      setState(() {
        infos = usage;
        appUsageToday = {for (var app in usage) app.packageName: app.usage};
      });

      // -------------------------------
      // Enviar APENAS os apps que atingiram o limite
      // (o serviÃƒÆ’Ã‚Â§o nativo agora lÃƒÆ’Ã‚Âª os limites diretamente, mas mantemos
      //  esse envio para compatibilidade e possibilidade de UI futura)
      // -------------------------------
      final List<String> blockedApps = [];
      appLimits.forEach((pkg, limit) {
        if (pkg == myPackage) return; // nunca bloquear o prÃƒÆ’Ã‚Â³prio app
        final used = appUsageToday[pkg] ?? Duration.zero;
        if (used >= limit) blockedApps.add(pkg);
      });
      try {
        await _appBlockerChannel.invokeMethod('setBlockedApps', {
          'apps': blockedApps,
        });
        debugPrint(
          'Apps bloqueados enviados para o serviÃƒÆ’Ã‚Â§o nativo: $blockedApps',
        );
      } catch (e) {
        debugPrint('Erro ao enviar apps bloqueados para o Android: $e');
      }
    } catch (exception) {
      debugPrint('Erro ao obter estatÃƒÆ’Ã‚Â­sticas de uso: $exception');
      setState(() {
        infos = [];
        appUsageToday = {};
      });
    }
  }

  // FunÃƒÂ§ÃƒÂ£o para obter ÃƒÂ­cone padrÃƒÂ£o baseado no nome do app
  IconData _getDefaultIconForApp(String appName, String packageName) {
    final name = appName.toLowerCase();
    final package = packageName.toLowerCase();

    // Apps de redes sociais
    if (name.contains('whatsapp') || package.contains('whatsapp')) {
      return Icons.chat;
    }
    if (name.contains('instagram') || package.contains('instagram')) {
      return Icons.camera_alt;
    }
    if (name.contains('facebook') || package.contains('facebook')) {
      return Icons.people;
    }
    if (name.contains('twitter') || package.contains('twitter')) {
      return Icons.alternate_email;
    }
    if (name.contains('tiktok') || package.contains('tiktok')) {
      return Icons.video_library;
    }
    if (name.contains('youtube') || package.contains('youtube')) {
      return Icons.play_circle;
    }
    if (name.contains('snapchat') || package.contains('snapchat')) {
      return Icons.camera;
    }

    // Apps de comunicaÃƒÂ§ÃƒÂ£o
    if (name.contains('telegram') || package.contains('telegram')) {
      return Icons.send;
    }
    if (name.contains('discord') || package.contains('discord')) {
      return Icons.chat_bubble;
    }
    if (name.contains('messenger') || package.contains('messenger')) {
      return Icons.message;
    }

    // Apps de jogos
    if (name.contains('game') || package.contains('game')) {
      return Icons.games;
    }
    if (name.contains('play') || package.contains('play')) {
      return Icons.play_arrow;
    }

    // Apps de produtividade
    if (name.contains('chrome') || package.contains('chrome')) {
      return Icons.web;
    }
    if (name.contains('browser') || package.contains('browser')) {
      return Icons.web;
    }
    if (name.contains('gmail') || package.contains('gmail')) {
      return Icons.email;
    }
    if (name.contains('drive') || package.contains('drive')) {
      return Icons.cloud;
    }
    if (name.contains('docs') || package.contains('docs')) {
      return Icons.description;
    }
    if (name.contains('sheets') || package.contains('sheets')) {
      return Icons.table_chart;
    }
    if (name.contains('slides') || package.contains('slides')) {
      return Icons.slideshow;
    }

    // Apps de mÃƒÂºsica e mÃƒÂ­dia
    if (name.contains('music') || package.contains('music')) {
      return Icons.music_note;
    }
    if (name.contains('spotify') || package.contains('spotify')) {
      return Icons.music_note;
    }
    if (name.contains('netflix') || package.contains('netflix')) {
      return Icons.movie;
    }
    if (name.contains('prime') || package.contains('prime')) {
      return Icons.movie;
    }

    // Apps de sistema
    if (name.contains('settings') || package.contains('settings')) {
      return Icons.settings;
    }
    if (name.contains('camera') || package.contains('camera')) {
      return Icons.camera_alt;
    }
    if (name.contains('gallery') || package.contains('gallery')) {
      return Icons.photo_library;
    }
    if (name.contains('files') || package.contains('files')) {
      return Icons.folder;
    }
    if (name.contains('download') || package.contains('download')) {
      return Icons.download;
    }

    // Apps de compras
    if (name.contains('shop') || package.contains('shop')) {
      return Icons.shopping_cart;
    }
    if (name.contains('amazon') || package.contains('amazon')) {
      return Icons.shopping_bag;
    }
    if (name.contains('uber') || package.contains('uber')) {
      return Icons.directions_car;
    }
    if (name.contains('ifood') || package.contains('ifood')) {
      return Icons.restaurant;
    }

    // Apps de fitness
    if (name.contains('fitness') || package.contains('fitness')) {
      return Icons.fitness_center;
    }
    if (name.contains('health') || package.contains('health')) {
      return Icons.favorite;
    }

    // Apps de banco
    if (name.contains('bank') || package.contains('bank')) {
      return Icons.account_balance;
    }
    if (name.contains('nubank') || package.contains('nubank')) {
      return Icons.account_balance_wallet;
    }

    // Apps de transporte
    if (name.contains('uber') || package.contains('uber')) {
      return Icons.directions_car;
    }
    if (name.contains('99') || package.contains('99')) {
      return Icons.directions_car;
    }

    // PadrÃƒÂ£o para apps nÃƒÂ£o identificados
    return Icons.apps;
  }

  Future<void> _loadAppIcons() async {
    try {
      Map<String, Uint8List?> icons = {};

      // Primeira tentativa: usar installed_apps com configuraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes otimizadas
      try {
        // Busca apenas apps nÃƒÆ’Ã‚Â£o-sistema para melhor performance
        List<AppInfo> apps = await InstalledApps.getInstalledApps(false, true);
        Map<String, AppInfo> appsMap = {
          for (var app in apps) app.packageName: app,
        };

        debugPrint('Encontrados ${apps.length} apps instalados');

        for (var info in infos) {
          if (appsMap.containsKey(info.packageName)) {
            AppInfo appInfo = appsMap[info.packageName]!;
            if (appInfo.icon != null) {
              icons[info.packageName] = appInfo.icon;
              debugPrint('ÃƒÆ’Ã‚Âcone encontrado para ${info.appName}');
            } else {
              debugPrint(
                'ÃƒÆ’Ã‚Âcone nÃƒÆ’Ã‚Â£o encontrado para ${info.appName}',
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Erro ao obter ÃƒÆ’Ã‚Â­cones via installed_apps: $e');
      }

      // Segunda tentativa: buscar todos os apps se a primeira falhou
      if (icons.isEmpty) {
        try {
          List<AppInfo> allApps = await InstalledApps.getInstalledApps(
            true,
            true,
          );
          Map<String, AppInfo> allAppsMap = {
            for (var app in allApps) app.packageName: app,
          };

          for (var info in infos) {
            if (allAppsMap.containsKey(info.packageName) &&
                allAppsMap[info.packageName]!.icon != null) {
              icons[info.packageName] = allAppsMap[info.packageName]!.icon;
            }
          }
        } catch (e) {
          debugPrint('Erro ao obter todos os apps: $e');
        }
      }

      debugPrint('Total de ÃƒÆ’Ã‚Â­cones carregados: ${icons.length}');
      setState(() {
        appIcons = icons;
      });
    } catch (e) {
      debugPrint('Erro geral ao carregar ÃƒÆ’Ã‚Â­cones dos apps: $e');
      setState(() {
        appIcons = {};
      });
    }
  }

  Future<void> _loadIconsForRemoteApps() async {
    if (!Platform.isAndroid || _remoteApps.isEmpty) return;
    try {
      final installed = await InstalledApps.getInstalledApps(false, true);
      final Map<String, Uint8List?> icons = {};
      final Map<String, AppInfo> installedMap = {
        for (var app in installed) app.packageName: app,
      };

      for (final remote in _remoteApps) {
        final appInfo = installedMap[remote.identificador];
        if (appInfo != null && appInfo.icon != null) {
          icons[remote.identificador] = appInfo.icon;
        }
      }

      if (icons.isNotEmpty) {
        setState(() {
          appIcons = {...appIcons, ...icons};
        });
      }
      debugPrint('Ícones carregados para apps remotos: ${icons.length}');
    } catch (e) {
      debugPrint('Erro ao carregar ícones para apps remotos: $e');
    }
  }

  Future<void> _saveLimits() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, int> limitsInMinutes = appLimits.map(
      (key, value) => MapEntry(key, value.inMinutes),
    );
    String encodedMap = json.encode(limitsInMinutes);
    await prefs.setString('app_limits', encodedMap);
  }

  Future<void> _loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedMap = prefs.getString('app_limits');
    if (encodedMap != null) {
      Map<String, dynamic> decodedMap = json.decode(encodedMap);
      setState(() {
        appLimits = decodedMap.map(
          (key, value) => MapEntry(key, Duration(minutes: value)),
        );
      });

      // Garante que nÃƒÆ’Ã‚Â£o exista limite salvo para o prÃƒÆ’Ã‚Â³prio app
      try {
        final info = await PackageInfo.fromPlatform();
        final myPackage = info.packageName;
        if (appLimits.containsKey(myPackage)) {
          setState(() {
            appLimits.remove(myPackage);
          });
          // Persiste a remoÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o
          unawaited(_saveLimits());
        }
      } catch (_) {}
    }
  }

  void setAppLimit(String packageName, Duration limit) {
    setState(() {
      appLimits[packageName] = limit;
      _saveLimits();
    });
    // Recalcula estatÃƒÆ’Ã‚Â­sticas e reenvia bloqueios ao serviÃƒÆ’Ã‚Â§o nativo
    // para refletir o novo limite imediatamente
    unawaited(getUsageStats());
  }

  bool isAppOverLimit(String packageName) {
    if (!appLimits.containsKey(packageName)) return false;
    final usage = appUsageToday[packageName] ?? Duration.zero;
    return usage >= appLimits[packageName]!;
  }

  Future<void> _syncWithBackendAsChild() async {
    if (widget.userType != TipoUsuario.crianca) return;

    await _ensureIdsResolved();

    final int? responsavelId = _resolvedResponsavelId;
    final int? criancaId = _resolvedCriancaId;
    if (responsavelId == null || responsavelId == 0) {
      debugPrint('Responsável não identificado para sincronizar aplicativos.');
      return;
    }

    // Se não houver estatísticas de uso (ou permissão), usa a lista de apps instalados para ao menos registrar no backend.
    final List<_AppToSync> appsParaSincronizar = [];
    if (infos.isNotEmpty) {
      for (final info in infos) {
        final minutesUsed = appUsageToday[info.packageName]?.inMinutes ?? 0;
        appsParaSincronizar.add(
          _AppToSync(
            packageName: info.packageName,
            appName: info.appName,
            minutesUsed: minutesUsed,
          ),
        );
      }
    } else {
      try {
        final installed = await InstalledApps.getInstalledApps(false, true);
        for (final app in installed) {
          appsParaSincronizar.add(
            _AppToSync(
              packageName: app.packageName,
              appName: app.name,
              minutesUsed: 0,
            ),
          );
        }
      } catch (e) {
        debugPrint('Erro ao ler apps instalados para sync: $e');
      }
    }

    if (appsParaSincronizar.isEmpty) {
      debugPrint('Nenhum aplicativo encontrado para sincronizar.');
      return;
    }

    try {
      debugPrint(
        'Sync child apps -> respId=$responsavelId, criancaId=$criancaId, total a sincronizar=${appsParaSincronizar.length}',
      );
      final todos = await _applicationsService.fetchAplicativos();
      debugPrint(
        'Recebidos do backend (criança) total=${todos.length}',
      );
      final filtrados = todos.where((app) {
        final matchResp = app.idResponsavel == responsavelId;
        final matchChild =
            criancaId == null || criancaId == 0 || app.idCrianca == criancaId;
        return matchResp && matchChild;
      }).map((app) {
        final normalizedLimit = app.bloqueado ? app.tempoLimite : 0;
        return AplicativoResponse(
          id: app.id,
          idResponsavel: app.idResponsavel,
          idCrianca: app.idCrianca,
          plataforma: app.plataforma,
          identificador: app.identificador,
          nome: app.nome,
          bloqueado: app.bloqueado,
          tempoUsado: app.tempoUsado,
          tempoLimite: normalizedLimit,
        );
      }).toList();
      debugPrint('Filtrados por IDs (criança): ${filtrados.length}');

      final Map<String, AplicativoResponse> byPackage = {
        for (var app in filtrados) app.identificador: app,
      };

      for (final entry in appsParaSincronizar) {
        final pkg = entry.packageName;
        if (!byPackage.containsKey(pkg)) {
          try {
            final created = await _applicationsService.createAplicativo(
              idResponsavel: responsavelId,
              idCrianca: criancaId ?? 0,
              plataforma: 'A',
              identificador: pkg,
              nome: entry.appName,
              bloqueado: false,
              tempoUsado: entry.minutesUsed,
            );
            byPackage[pkg] = created;
            debugPrint('Criado app remoto $pkg para resp $responsavelId');
          } catch (e) {
            debugPrint('Erro ao criar aplicativo remoto para $pkg: $e');
          }
        }

        final app = byPackage[pkg];
        if (app != null) {
          final minutesUsed = entry.minutesUsed;
          final current = app.tempoUsado;
          final delta = minutesUsed - current;
          if (delta != 0) {
            try {
              await _applicationsService.atualizarTempoUsado(
                id: app.id,
                tempoUsado: delta,
              );
              byPackage[pkg] = AplicativoResponse(
                id: app.id,
                idResponsavel: app.idResponsavel,
                idCrianca: app.idCrianca,
                plataforma: app.plataforma,
                identificador: app.identificador,
                nome: app.nome,
                bloqueado: app.bloqueado,
                tempoUsado: minutesUsed,
                tempoLimite: app.tempoLimite,
              );
            } catch (e) {
              debugPrint(
                'Erro ao atualizar tempo usado para ${app.nome}: $e',
              );
            }
          }
        }
      }

      final updatedApps = byPackage.values.toList()
        ..sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
      debugPrint('Total apps sincronizados (criança): ${updatedApps.length}');

      setState(() {
        _remoteApps = updatedApps;
        _remoteAppsByPackage = {
          for (var app in updatedApps) app.identificador: app,
        };

        appLimits.clear();
        for (final app in updatedApps) {
          if (app.bloqueado && app.tempoLimite > 0) {
            appLimits[app.identificador] = Duration(minutes: app.tempoLimite);
          }
        }
      });

      unawaited(_saveLimits());
    } catch (e) {
      debugPrint('Erro ao sincronizar aplicativos com backend: $e');
    }
  }

  Future<void> _loadFromBackendAsResponsible() async {
    try {
      await _ensureIdsResolved();
      await _ensureChildForResponsible();

      final int? responsavelId = _resolvedResponsavelId;
      final int? criancaId = _resolvedCriancaId;
      if (responsavelId == null || responsavelId == 0) {
        debugPrint('Responsável não identificado para carregar aplicativos.');
        return;
      }
      debugPrint('Carregando apps para responsável $responsavelId');

      final todos = await _applicationsService.fetchAplicativos();
      debugPrint(
        'Recebidos do backend (responsável) total=${todos.length}',
      );
      final filtrados = todos.where((app) {
        final matchResp = app.idResponsavel == responsavelId;
        final matchChild =
            criancaId == null || criancaId == 0 ? true : app.idCrianca == criancaId;
        return matchResp && matchChild;
      }).map((app) {
        final normalizedLimit = app.bloqueado ? app.tempoLimite : 0;
        return AplicativoResponse(
          id: app.id,
          idResponsavel: app.idResponsavel,
          idCrianca: app.idCrianca,
          plataforma: app.plataforma,
          identificador: app.identificador,
          nome: app.nome,
          bloqueado: app.bloqueado,
          tempoUsado: app.tempoUsado,
          tempoLimite: normalizedLimit,
        );
      }).toList()
        // Mantém apenas apps que têm uso registrado ou limite definido,
        // para refletir a lista vista na criança e evitar apps de sistema sem uso.
        ..retainWhere((app) => app.tempoUsado > 0 || app.tempoLimite > 0)
        ..sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
      debugPrint('Filtrados por responsável $responsavelId: ${filtrados.length}');

      setState(() {
        _remoteApps = filtrados;
        _remoteAppsByPackage = {
          for (var app in filtrados) app.identificador: app,
        };
      });
    } catch (e) {
      debugPrint('Erro ao carregar aplicativos do backend: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar aplicativos: $e'),
        ),
      );
    }
  }

  Future<void> _updateNativeBlockedApps() async {
    if (!Platform.isAndroid) return;

    String myPackage = '';
    try {
      final info = await PackageInfo.fromPlatform();
      myPackage = info.packageName;
    } catch (_) {}

    final List<String> blockedApps = [];
    appLimits.forEach((pkg, limit) {
      if (pkg == myPackage) return;
      final used = appUsageToday[pkg] ?? Duration.zero;
      if (used >= limit) blockedApps.add(pkg);
    });

    try {
      await _appBlockerChannel.invokeMethod('setBlockedApps', {
        'apps': blockedApps,
      });
      debugPrint(
        'Apps bloqueados enviados para o serviço nativo após sync: $blockedApps',
      );
    } catch (e) {
      debugPrint('Erro ao enviar apps bloqueados para o Android: $e');
    }
  }

  void _showSetLimitDialog(AppUsageInfo info) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Definir limite para ${info.appName}"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Tempo em minutos",
              hintText: "Ex: 60",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Remover Limite"),
              onPressed: () {
                setState(() {
                  appLimits.remove(info.packageName);
                  _saveLimits();
                });
                // Atualiza status de bloqueio apÃƒÆ’Ã‚Â³s remover limite
                unawaited(getUsageStats());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Salvar"),
              onPressed: () {
                final minutes = int.tryParse(controller.text);
                if (minutes != null && minutes > 0) {
                  setAppLimit(info.packageName, Duration(minutes: minutes));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Limite de $minutes min definido para ${info.appName}",
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return "${d.inHours}h ${d.inMinutes.remainder(60)}min";
    }
    return "${d.inMinutes}min";
  }

  Color _withOpacity(Color color, double factor) {
    final alpha = (color.a * factor).clamp(0.0, 1.0);
    return color.withValues(alpha: alpha);
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required IconData buttonIcon,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _withOpacity(color, 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _withOpacity(color, 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                buttonIcon,
                size: 18,
              ),
              label: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut).slideY(
          begin: 0.1,
          curve: Curves.easeOut,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.userType == TipoUsuario.crianca
              ? "Liberar Apps"
              : "Bloqueio de Apps",
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await loadData();
              await _updateAccessibilityStatus();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 8),
                  if (widget.userType == TipoUsuario.responsavel) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Controle de tempo nos apps',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Defina limites diários para os aplicativos usados pela criança.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                          .slideY(begin: -0.1, curve: Curves.easeOut),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.userType == TipoUsuario.crianca &&
                      (!_hasPermission || !_hasAccessibilityPermission))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_hasPermission)
                            _buildPermissionCard(
                              icon: Icons.security,
                              color: Colors.orange,
                              title: 'Permissão de acesso de uso',
                              description:
                                  'Para monitorar o uso dos aplicativos é necessário conceder a permissão de "Acesso de uso".',
                              buttonIcon: Icons.settings,
                              buttonLabel: 'Abrir configurações',
                              onPressed: _handleUsagePermissionRequest,
                            ),
                          if (!_hasAccessibilityPermission)
                            _buildPermissionCard(
                              icon: Icons.accessibility_new,
                              color: Colors.blue,
                              title: 'Permissão de acessibilidade',
                              description:
                                  'Habilite o serviço de acessibilidade para que o aplicativo possa bloquear outros apps quando o limite for atingido.',
                              buttonIcon: Icons.open_in_new,
                              buttonLabel: 'Abrir acessibilidade',
                              onPressed: _handleAccessibilityPermissionRequest,
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: widget.userType == TipoUsuario.crianca
                          ? _buildChildAppList()
                          : _buildResponsibleAppList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildChildAppList() {
    if (infos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum uso de aplicativo encontrado hoje.',
          style: TextStyle(
            color: AppColors.gray400,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: infos.length,
      itemBuilder: (context, index) {
        final info = infos[index];
        final bool overLimit = isAppOverLimit(info.packageName);
        final Duration limit = appLimits[info.packageName] ?? Duration.zero;

        String subtitleText = "Uso hoje: ${_formatDuration(info.usage)}";
        if (limit.inMinutes > 0) {
          subtitleText += " • Limite: ${limit.inMinutes} min";
        }

        final appRemote = _remoteAppsByPackage[info.packageName];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: overLimit ? AppColors.gray100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: overLimit
                ? Border.all(
                    color: Colors.red.shade200,
                    width: 1.5,
                  )
                : limit.inMinutes > 0
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.4),
                        width: 1,
                      )
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: appIcons.containsKey(info.packageName) &&
                    appIcons[info.packageName] != null
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _withOpacity(
                            Colors.black,
                            0.1,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        appIcons[info.packageName]!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          debugPrint(
                            'Erro ao carregar ícone para ${info.appName}: $error',
                          );
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getDefaultIconForApp(
                                info.appName,
                                info.packageName,
                              ),
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDefaultIconForApp(
                        info.appName,
                        info.packageName,
                      ),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
            title: Text(
              info.appName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            subtitle: Text(
              subtitleText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray400,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (overLimit)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.lock,
                        color: Colors.red,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bloqueado',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else if (limit.inMinutes > 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Com limite',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  const Icon(
                    Icons.more_time,
                    color: AppColors.gray300,
                  ),
                if (appRemote != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showAddOneMinuteDialog(appRemote),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      '+1 min',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: null, // Criança não edita limite diretamente
          ),
        )
            .animate()
            .fadeIn(
              duration: 450.ms,
              delay: (index * 70).ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.08,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildResponsibleAppList() {
    if (_remoteApps.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum aplicativo sincronizado ainda.',
          style: TextStyle(
            color: AppColors.gray400,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _remoteApps.length,
      itemBuilder: (context, index) {
        final app = _remoteApps[index];
        final usage = Duration(minutes: app.tempoUsado);
        final limit = Duration(minutes: app.tempoLimite);
        final bool overLimit =
            app.bloqueado && limit.inMinutes > 0 && usage >= limit;

        String subtitleText = "Uso hoje: ${_formatDuration(usage)}";
        if (limit.inMinutes > 0) {
          subtitleText += " • Limite: ${limit.inMinutes} min";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: overLimit ? AppColors.gray100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: overLimit
                ? Border.all(
                    color: Colors.red.shade200,
                    width: 1.5,
                  )
                : limit.inMinutes > 0
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.4),
                        width: 1,
                      )
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: appIcons.containsKey(app.identificador) &&
                      appIcons[app.identificador] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        appIcons[app.identificador]!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      _getDefaultIconForApp(app.nome, app.identificador),
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
            title: Text(
              app.nome,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            subtitle: Text(
              subtitleText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray400,
              ),
            ),
            trailing: overLimit
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.lock,
                        color: Colors.red,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bloqueado',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : limit.inMinutes > 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Com limite',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.more_time,
                        color: AppColors.gray300,
                      ),
            onTap: () => _showSetRemoteLimitDialog(app),
          ),
        )
            .animate()
            .fadeIn(
              duration: 450.ms,
              delay: (index * 70).ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.08,
              curve: Curves.easeOut,
            );
      },
    );
  }

  void _showSetRemoteLimitDialog(AplicativoResponse app) {
    final controller = TextEditingController(
      text: app.tempoLimite > 0 ? app.tempoLimite.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Definir limite para ${app.nome}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tempo em minutos',
              hintText: 'Ex: 60',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Remover limite'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _applicationsService.atualizarBloqueio(
                    id: app.id,
                    bloqueado: false,
                    tempoLimite: 0,
                  );
                  setState(() {
                    final index =
                        _remoteApps.indexWhere((element) => element.id == app.id);
                    if (index != -1) {
                      _remoteApps[index] = AplicativoResponse(
                        id: app.id,
                        idResponsavel: app.idResponsavel,
                        idCrianca: app.idCrianca,
                        plataforma: app.plataforma,
                        identificador: app.identificador,
                        nome: app.nome,
                        bloqueado: false,
                        tempoUsado: app.tempoUsado,
                        tempoLimite: 0,
                      );
                      _remoteAppsByPackage[app.identificador] =
                          _remoteApps[index];
                    }
                    appLimits.remove(app.identificador);
                  });
                  await _updateNativeBlockedApps();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao remover limite: $e'),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () async {
                final minutes = int.tryParse(controller.text);
                if (minutes == null || minutes <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe um tempo válido em minutos.'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                try {
                  // Garante que o backend fique exatamente com o novo limite:
                  // zera primeiro e depois aplica o valor final.
                  await _applicationsService.atualizarBloqueio(
                    id: app.id,
                    bloqueado: false,
                    tempoLimite: 0,
                  );
                  await _applicationsService.atualizarBloqueio(
                    id: app.id,
                    bloqueado: true,
                    tempoLimite: minutes,
                  );
                  setState(() {
                    final index =
                        _remoteApps.indexWhere((element) => element.id == app.id);
                    if (index != -1) {
                      _remoteApps[index] = AplicativoResponse(
                        id: app.id,
                        idResponsavel: app.idResponsavel,
                        idCrianca: app.idCrianca,
                        plataforma: app.plataforma,
                        identificador: app.identificador,
                        nome: app.nome,
                        bloqueado: true,
                        tempoUsado: app.tempoUsado,
                        tempoLimite: minutes,
                      );
                      _remoteAppsByPackage[app.identificador] =
                          _remoteApps[index];
                    }
                    appLimits[app.identificador] = Duration(minutes: minutes);
                  });
                  await _updateNativeBlockedApps();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Limite de $minutes min definido para ${app.nome}',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao salvar limite: $e'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addOneMinute(AplicativoResponse app) async {
    await _ensureIdsResolved();
    final int? responsavelId = _resolvedResponsavelId ?? widget.idResponsavel;
    final int? criancaId = _resolvedCriancaId ?? widget.idCrianca;
    if (criancaId == null || criancaId == 0 || responsavelId == null || responsavelId == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Responsável ou criança não identificado para adicionar tempo.'),
        ),
      );
      return;
    }

    try {
      // Buscar recompensa fixa para +1 min
      final recompensas = await _achievementsService.fetchRecompensas(
        responsavelId: responsavelId,
        criancaId: criancaId,
      );

      RecompensaResponse? recompensaExtraMinuto;
      for (final r in recompensas) {
        if (r.titulo == _plusOneRewardTitle) {
          recompensaExtraMinuto = r;
          break;
        }
      }

      // Se não existir, cria a recompensa fixa automaticamente
      recompensaExtraMinuto ??=
          await _achievementsService.createRecompensa(
        responsavelId: responsavelId,
        titulo: _plusOneRewardTitle,
        observacao: _plusOneRewardDescription,
        pontuacaoNecessaria: _plusOneRewardCost,
        quantidade: _plusOneRewardQuantidade,
      );

      // Tenta resgatar a recompensa (backend valida pontos)
      try {
        await _achievementsService.resgatarRecompensa(
          recompensaId: recompensaExtraMinuto.id,
          idCrianca: criancaId,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao resgatar recompensa: $e'),
          ),
        );
        return;
      }

      final novoLimite = (app.tempoLimite) + 1;

      // Força valor absoluto: zera e seta o novo limite calculado
      await _applicationsService.atualizarBloqueio(
        id: app.id,
        bloqueado: false,
        tempoLimite: 0,
      );
      await _applicationsService.atualizarBloqueio(
        id: app.id,
        bloqueado: true,
        tempoLimite: novoLimite,
      );

      setState(() {
        final index =
            _remoteApps.indexWhere((element) => element.id == app.id);
        if (index != -1) {
          _remoteApps[index] = AplicativoResponse(
            id: app.id,
            idResponsavel: app.idResponsavel,
            idCrianca: app.idCrianca,
            plataforma: app.plataforma,
            identificador: app.identificador,
            nome: app.nome,
            bloqueado: true,
            tempoUsado: app.tempoUsado,
            tempoLimite: novoLimite,
          );
          _remoteAppsByPackage[app.identificador] = _remoteApps[index];
        }
        appLimits[app.identificador] = Duration(minutes: novoLimite);
      });

      await _updateNativeBlockedApps();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mais 1 minuto liberado para ${app.nome}!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar 1 min: $e'),
        ),
      );
    }
  }

  void _showAddOneMinuteDialog(AplicativoResponse app) {
    if (widget.idCrianca == null || widget.idCrianca == 0) return;

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
                  Icons.timer,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Resgatar +1 minuto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deseja gastar $_plusOneRewardCost ponto(s) para liberar +1 minuto em "${app.nome}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                        await _addOneMinute(app);
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
  }
}

class _AppToSync {
  final String packageName;
  final String appName;
  final int minutesUsed;

  _AppToSync({
    required this.packageName,
    required this.appName,
    required this.minutesUsed,
  });
}
