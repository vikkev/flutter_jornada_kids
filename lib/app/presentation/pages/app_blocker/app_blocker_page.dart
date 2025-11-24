import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  const AppBlockerPage({super.key});

  @override
  State<AppBlockerPage> createState() => _AppBlockerPageState();
}

class _AppBlockerPageState extends State<AppBlockerPage>
    with WidgetsBindingObserver {
  List<AppUsageInfo> infos = [];
  Map<String, Duration> appLimits = {};
  Map<String, Duration> appUsageToday = {};
  Map<String, Uint8List?> appIcons = {};
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _hasAccessibilityPermission = false;

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

  Future<void> _initializeApp() async {
    bool hasUsagePermission = await checkUsagePermission();
    bool hasAccessibilityPermission = await checkAccessibilityPermission();

    if (!mounted) return;

    setState(() {
      _hasPermission = hasUsagePermission;
      _hasAccessibilityPermission = hasAccessibilityPermission;
    });

    if (!hasUsagePermission) {
      await requestUsagePermission();
      await Future.delayed(const Duration(seconds: 2));
      hasUsagePermission = await checkUsagePermission();
      if (!mounted) return;
      setState(() {
        _hasPermission = hasUsagePermission;
      });
    }

    if (hasUsagePermission) {
      await loadData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    if (!hasAccessibilityPermission) {
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
    if (!Platform.isAndroid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    await _loadLimits();
    await getUsageStats();
    try {
      await _loadAppIcons().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Timeout ao carregar ícones: $e');
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _withOpacity(color, 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(buttonIcon),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        title: const Text("Monitor de Uso"),
        actions: [
          // Indicadores de permissÃƒÆ’Ã‚Â£o
          Icon(
            _hasPermission ? Icons.check_circle : Icons.warning,
            color: _hasPermission ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Icon(
            _hasAccessibilityPermission
                ? Icons.accessibility_new
                : Icons.accessibility,
            color: _hasAccessibilityPermission ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Mensagem de permissÃƒÆ’Ã‚Â£o se necessÃƒÆ’Ã‚Â¡rio
                  if (!_hasPermission || !_hasAccessibilityPermission)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_hasPermission)
                            _buildPermissionCard(
                              icon: Icons.security,
                              color: Colors.orange,
                              title: 'PermissÃƒÆ’Ã‚Â£o de acesso de uso',
                              description:
                                  'Para monitorar o uso dos aplicativos ÃƒÆ’Ã‚Â© necessÃƒÆ’Ã‚Â¡rio conceder a permissÃƒÆ’Ã‚Â£o de "Acesso de uso".',
                              buttonIcon: Icons.settings,
                              buttonLabel: 'Abrir configuraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes',
                              onPressed: _handleUsagePermissionRequest,
                            ),
                          if (!_hasAccessibilityPermission)
                            _buildPermissionCard(
                              icon: Icons.accessibility_new,
                              color: Colors.blue,
                              title: 'PermissÃƒÆ’Ã‚Â£o de acessibilidade',
                              description:
                                  'Habilite o serviÃƒÆ’Ã‚Â§o de acessibilidade para que o aplicativo possa bloquear outros apps quando o limite for atingido.',
                              buttonIcon: Icons.open_in_new,
                              buttonLabel: 'Abrir acessibilidade',
                              onPressed: _handleAccessibilityPermissionRequest,
                            ),
                        ],
                      ),
                    ),
                  // Lista de apps
                  Expanded(
                    child: ListView.builder(
                      itemCount: infos.length,
                      itemBuilder: (context, index) {
                        AppUsageInfo info = infos[index];
                        bool overLimit = isAppOverLimit(info.packageName);
                        Duration limit =
                            appLimits[info.packageName] ?? Duration.zero;

                        String subtitleText =
                            "Uso: ${_formatDuration(info.usage)}";
                        if (limit.inMinutes > 0) {
                          subtitleText += " / Limite: ${limit.inMinutes}min";
                        }

                        return ListTile(
                          leading:
                              appIcons.containsKey(info.packageName) &&
                                      appIcons[info.packageName] != null
                                  ? Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
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
                                      borderRadius: BorderRadius.circular(8),
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
                                            'Erro ao carregar ÃƒÆ’Ã‚Â­cone para ${info.appName}: $error',
                                          );
                                          return Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
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
                                    child: Icon(
                                      _getDefaultIconForApp(
                                        info.appName,
                                        info.packageName,
                                      ),
                                      color: Colors.blue.shade700,
                                      size: 24,
                                    ),
                                  ),
                          title: Text(info.appName),
                          subtitle: Text(subtitleText),
                          trailing:
                              overLimit
                                  ? const Icon(Icons.lock, color: Colors.red)
                                  : limit.inMinutes > 0
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                  : null,
                          onTap: () {
                            _showSetLimitDialog(info);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
