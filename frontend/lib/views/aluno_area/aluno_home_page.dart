import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
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

  List<Aluno> alunos = [];
  List<Aluno> alunosFiltrados = [];
  Aluno? alunoSelecionado;
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    alunoSelecionado = widget.aluno;
    carregarAlunos();
  }

  Future<void> carregarAlunos() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getAlunos();

      setState(() {
        alunos = lista;
        alunosFiltrados = lista;
        alunoSelecionado ??= _buscarAlunoInicial(lista);
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  Aluno? _buscarAlunoInicial(List<Aluno> lista) {
    final aluno = widget.aluno;
    if (aluno == null) return null;

    for (final item in lista) {
      if (item.id == aluno.id) return item;
    }

    return aluno;
  }

  void filtrarAlunos(String texto) {
    final busca = texto.trim().toLowerCase();

    setState(() {
      alunosFiltrados = alunos.where((aluno) {
        return busca.isEmpty ||
            aluno.nome.toLowerCase().contains(busca) ||
            (aluno.cpf ?? '').toLowerCase().contains(busca) ||
            aluno.comumCompleta.toLowerCase().contains(busca);
      }).toList();
    });
  }

  void selecionarAluno(Aluno aluno) {
    setState(() {
      alunoSelecionado = aluno;
    });
  }

  Future<void> abrirTela(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aluno = alunoSelecionado;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Aluno'),
        actions: [
          IconButton(
            onPressed: carregarAlunos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar alunos:\n$erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.school,
                        size: 36,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Painel do Aluno',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aluno == null
                            ? 'Selecione seu cadastro para consultar perfil e histórico de aulas.'
                            : 'Olá, ${aluno.nome}.',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar aluno por nome, CPF ou comum...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: filtrarAlunos,
                ),
                const SizedBox(height: 12),
                if (alunosFiltrados.isEmpty)
                  const _EstadoVazio(
                    icone: Icons.person_search,
                    mensagem: 'Nenhum aluno encontrado.',
                  )
                else
                  ...alunosFiltrados.map((item) {
                    final selecionado = aluno?.id == item.id;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(child: Text(_inicial(item.nome))),
                        title: Text(item.nome),
                        subtitle: Text(_textoAluno(item)),
                        selected: selecionado,
                        trailing: selecionado
                            ? const Icon(Icons.check)
                            : const Icon(Icons.chevron_right),
                        onTap: () => selecionarAluno(item),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                const Text(
                  'Consultas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _AlunoAreaCard(
                  titulo: 'Perfil',
                  descricao: aluno == null
                      ? 'Selecione um aluno para visualizar o perfil.'
                      : 'Dados cadastrais de ${aluno.nome}.',
                  icone: Icons.account_circle,
                  onTap: aluno == null
                      ? null
                      : () => abrirTela(AlunoPerfilPage(aluno: aluno)),
                ),
                const SizedBox(height: 12),
                _AlunoAreaCard(
                  titulo: 'Histórico de Aulas',
                  descricao: aluno == null
                      ? 'Selecione um aluno para consultar os registros.'
                      : 'Registros, presença e observações das aulas.',
                  icone: Icons.history,
                  onTap: aluno == null
                      ? null
                      : () => abrirTela(AlunoHistoricoPage(aluno: aluno)),
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
  final VoidCallback? onTap;

  const _AlunoAreaCard({
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
              Icon(onTap == null ? Icons.lock_outline : Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String mensagem;

  const _EstadoVazio({required this.icone, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
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

String _textoAluno(Aluno aluno) {
  final cpf = aluno.cpf?.trim().isEmpty ?? true
      ? 'CPF não informado'
      : aluno.cpf!.trim();

  return '$cpf - ${aluno.comumCompleta}';
}
