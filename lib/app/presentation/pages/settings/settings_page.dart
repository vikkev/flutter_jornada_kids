import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/pages/settings/profile_page.dart';
import 'package:flutter_jornadakids/app/presentation/pages/settings/children_list_page.dart';
import 'package:flutter_jornadakids/app/presentation/pages/settings/pin_code_page.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final Usuario usuario;

  const SettingsPage({required this.usuario, super.key});

  String _tipoUsuarioLabel(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.crianca:
        return 'Criança/Adolescente';
      case TipoUsuario.responsavel:
        return 'Responsável';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent ,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card do perfil
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    backgroundImage: usuario.avatar != null ? MemoryImage(usuario.avatar!) : null,
                    child: usuario.avatar == null
                        ? Icon(Icons.person, size: 36, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  // Dados do usuário
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nomeCompleto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          usuario.email,
                          style: const TextStyle(fontSize: 14, color: AppColors.gray400),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _tipoUsuarioLabel(usuario.tipoUsuario),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

            const SizedBox(height: 8),

            // Card de opções
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildOption(
                    icon: Icons.person,
                    title: 'Meu perfil',
                    subtitle: 'Visualizar e editar meus dados',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(usuario: usuario),
                        ),
                      );
                    },
                    delay: 200,
                  ),
                  if (usuario.tipoUsuario == TipoUsuario.responsavel)
                    _buildOption(
                      icon: Icons.group,
                      title: 'Crianças/Adolescentes',
                      subtitle: 'Visualizar minhas crianças/adolescentes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildrenListPage(responsavel: usuario),
                          ),
                        );
                      },
                      delay: 300,
                    ),
                  if (usuario.tipoUsuario == TipoUsuario.responsavel)
                    _buildOption(
                      icon: Icons.vpn_key,
                      title: 'Código PIN',
                      subtitle: 'Ver código para cadastro de criança/adolescente',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PinCodePage(usuario: usuario),
                          ),
                        );
                      },
                      delay: 350,
                    ),
                  _buildOption(
                    icon: Icons.logout,
                    title: 'Sair',
                    subtitle: 'Sair da conta',
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const WelcomePage()),
                        (route) => false,
                      );
                    },
                    delay: 400,
                    color: Colors.red.shade400,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int delay = 0,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary, size: 28),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? AppColors.secondary)),
      subtitle: Text(subtitle, style: TextStyle(color: color ?? AppColors.gray400)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    ).animate().fadeIn(duration: 500.ms, delay: delay.ms).slideX(begin: 0.2);
  }
}
