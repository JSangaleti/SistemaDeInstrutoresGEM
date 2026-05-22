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
    return Scaffold(
      appBar: AppBar(title: const Text('Área do Instrutor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Painel do Instrutor',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acesse os alunos e registre as aulas acompanhadas.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
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
      child: ListTile(
        leading: CircleAvatar(child: Icon(icone)),
        title: Text(titulo),
        subtitle: Text(descricao),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
