import 'package:flutter/material.dart';

import '../admin/admin_home_page.dart';
import '../aluno_area/aluno_home_page.dart';
import '../instrutor_panel/instrutor_panel_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> abrirTela(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sistema GEM')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.music_note,
                  size: 36,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sistema de Gestão do GEM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione a área de acesso para continuar.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Áreas de acesso',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _AreaCard(
            titulo: 'Administrador',
            descricao: 'Gerenciar cadastros, registros e dados do sistema.',
            icone: Icons.admin_panel_settings,
            onTap: () => abrirTela(context, const AdminHomePage()),
          ),
          const SizedBox(height: 12),
          _AreaCard(
            titulo: 'Instrutor',
            descricao:
                'Acompanhar alunos, registrar aulas e consultar históricos.',
            icone: Icons.co_present,
            onTap: () => abrirTela(context, const InstrutorPanelPage()),
          ),
          const SizedBox(height: 12),
          _AreaCard(
            titulo: 'Aluno',
            descricao: 'Visualizar perfil e histórico de aulas.',
            icone: Icons.school,
            onTap: () => abrirTela(context, const AlunoHomePage()),
          ),
        ],
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final VoidCallback onTap;

  const _AreaCard({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(radius: 24, child: Icon(icone)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(descricao),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
