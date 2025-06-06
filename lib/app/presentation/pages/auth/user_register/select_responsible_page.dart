import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/user_register/register_page.dart';

class SelectResponsiblePage extends StatefulWidget {
  final String responsibleCode;
  final String responsibleName;
  final String responsibleId;

  const SelectResponsiblePage({
    super.key,
    required this.responsibleCode,
    required this.responsibleName,
    required this.responsibleId,
  });

  @override
  State<SelectResponsiblePage> createState() => _SelectResponsiblePageState();
}

class _SelectResponsiblePageState extends State<SelectResponsiblePage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Selecionar Responsável',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,letterSpacing: 0.5,),
          
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              AppColors.darkBlue,
              AppColors.secondary,
              AppColors.primary,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height:100),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Responsável identificado:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.15),
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            title: Text(widget.responsibleName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Código: ${widget.responsibleCode}'),
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedScale(
                          scale: _isLoading ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 225, // largura menor
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() => _isLoading = true);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RegisterPage(
                                              isResponsible: false,
                                              responsibleId: widget.responsibleId,
                                              responsibleName: widget.responsibleName,
                                            ),
                                          ),
                                        ).then((_) => setState(() => _isLoading = false));
                                      },
                                style: ElevatedButton.styleFrom(
                                  // Remover backgroundColor para usar Ink com gradient
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32), // mais arredondado
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: AppColors.gray200,
                                  disabledForegroundColor: Colors.white.withAlpha(204),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.darkBlue,
                                        AppColors.secondary,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 48,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Confirmar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}