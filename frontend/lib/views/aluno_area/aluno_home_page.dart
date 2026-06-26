import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
import '../../widgets/logout_button.dart';
import 'aluno_historico_page.dart';
import 'aluno_perfil_page.dart';

class AlunoHomePage extends StatefulWidget {
  final Aluno? aluno;

  const AlunoHomePage({super.key, this.aluno});

  @override
  State<AlunoHomePage> createState() => _AlunoHomePageState();
}

class _AlunoHomePageState extends State<AlunoHomePage> {
  final AlunoService service = AlunoService();

  Aluno? aluno;
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    aluno = widget.aluno;
    carregarAluno();
  }

  Future<void> carregarAluno() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final resultado = await service.getMeuPerfil();
      setState(() {
        aluno = resultado;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  Future<void> abrirTela(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    carregarAluno();
  }

  @override
  Widget build(BuildContext context) {
    final alunoAtual = aluno;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Aluno'),
        actions: [
          IconButton(
            onPressed: carregarAluno,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          const LogoutButton(),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? _ErroTela(
              mensagem: 'Erro ao carregar a área do aluno:\n$erro',
              onRetry: carregarAluno,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        child: Text(
                          _inicial(alunoAtual?.nome ?? AuthSession.nome ?? ''),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, ${alunoAtual?.nome ?? AuthSession.nome ?? 'aluno'}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alunoAtual?.comumCompleta ??
                                  'Área pessoal do aluno',
                              style: TextStyle(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Consultas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _AlunoAreaCard(
                  titulo: 'Meu perfil',
                  descricao: 'Dados cadastrais vinculados ao seu login.',
                  icone: Icons.account_circle,
                  onTap: () => abrirTela(AlunoPerfilPage(aluno: alunoAtual)),
                ),
                const SizedBox(height: 12),
                _AlunoAreaCard(
                  titulo: 'Meu histórico de aulas',
                  descricao: 'Registros, presença e orientações das aulas.',
                  icone: Icons.history,
                  onTap: () => abrirTela(const AlunoHistoricoPage()),
                ),
              ],
            ),
    );
  }
}

class _AlunoAreaCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final VoidCallback onTap;

  const _AlunoAreaCard({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Icon(icone),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium,
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

class _ErroTela extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErroTela({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

String _inicial(String nome) {
  final texto = nome.trim();
  return texto.isEmpty ? '?' : texto[0].toUpperCase();
}
