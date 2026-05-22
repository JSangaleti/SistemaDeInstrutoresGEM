import 'package:flutter/material.dart';

import '../aluno_list/aluno_list_page.dart';
import '../instrutor_historico/instrutor_historico_page.dart';
import '../registro_aula_list/registro_aula_list_page.dart';

class InstrutorPanelPage extends StatelessWidget {
  const InstrutorPanelPage({super.key});

  Future<void> _abrirTela(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Área do Instrutor')),
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
                  Icons.co_present,
                  size: 36,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'Painel do Instrutor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acompanhe alunos, registre aulas e consulte históricos para dar continuidade ao trabalho.',
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
            'Ações principais',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InstrutorPanelCard(
            titulo: 'Alunos',
            descricao: 'Consultar, cadastrar e editar alunos.',
            icone: Icons.school,
            onTap: () => _abrirTela(context, const AlunoListPage()),
          ),
          const SizedBox(height: 12),
          _InstrutorPanelCard(
            titulo: 'Registros de Aula',
            descricao: 'Cadastrar e editar registros sem excluir histórico.',
            icone: Icons.event_note,
            onTap: () => _abrirTela(
              context,
              const RegistroAulaListPage(exibirExcluir: false),
            ),
          ),
          const SizedBox(height: 12),
          _InstrutorPanelCard(
            titulo: 'Histórico de Aulas',
            descricao: 'Consultar aulas anteriores por aluno.',
            icone: Icons.history,
            onTap: () => _abrirTela(context, const InstrutorHistoricoPage()),
          ),
        ],
      ),
    );
  }
}

class _InstrutorPanelCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final VoidCallback onTap;

  const _InstrutorPanelCard({
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
