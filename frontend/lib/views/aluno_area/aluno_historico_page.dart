import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../models/registro_aula.dart';
import '../../services/registro_aula_service.dart';

class AlunoHistoricoPage extends StatefulWidget {
  final Aluno? aluno;

  const AlunoHistoricoPage({super.key, this.aluno});

  @override
  State<AlunoHistoricoPage> createState() => _AlunoHistoricoPageState();
}

class _AlunoHistoricoPageState extends State<AlunoHistoricoPage> {
  final RegistroAulaService service = RegistroAulaService();

  List<Aluno> alunos = [];
  List<Aluno> alunosFiltrados = [];
  List<RegistroAula> registros = [];
  Aluno? alunoSelecionado;
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    alunoSelecionado = widget.aluno;
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final alunosLista = await service.getAlunos();
      final registrosLista = await service.getRegistrosAula();

      setState(() {
        alunos = alunosLista;
        alunosFiltrados = alunosLista;
        alunoSelecionado ??= _buscarAlunoInicial(alunosLista);
        registros = registrosLista;
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

  List<RegistroAula> historicoAluno(Aluno aluno) {
    final nomeAluno = _normalizar(aluno.nome);

    final historico = registros.where((registro) {
      if (registro.alunoId != null) {
        return registro.alunoId == aluno.id;
      }

      return _normalizar(registro.alunoNome ?? '') == nomeAluno;
    }).toList();

    historico.sort((a, b) {
      final dataA = a.data ?? DateTime(1900);
      final dataB = b.data ?? DateTime(1900);
      return dataB.compareTo(dataA);
    });

    return historico;
  }

  String valorOuPadrao(String? valor) {
    final texto = valor?.trim() ?? '';
    return texto.isEmpty ? 'Não informado' : texto;
  }

  @override
  Widget build(BuildContext context) {
    final aluno = alunoSelecionado;
    final historico = aluno == null ? <RegistroAula>[] : historicoAluno(aluno);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Histórico de Aulas'),
        actions: [
          IconButton(
            onPressed: carregarDados,
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
                  'Erro ao carregar histórico:\n$erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aluno == null
                            ? 'Selecione um aluno'
                            : 'Histórico de ${aluno.nome}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        aluno == null
                            ? 'Escolha o cadastro para visualizar os registros de aula.'
                            : _textoAluno(aluno),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.aluno == null) ...[
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
                      final selecionado = alunoSelecionado?.id == item.id;

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            child: Text(_inicial(item.nome)),
                          ),
                          title: Text(item.nome),
                          subtitle: Text(_textoAluno(item)),
                          selected: selecionado,
                          trailing: selecionado
                              ? const Icon(Icons.check)
                              : const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() {
                              alunoSelecionado = item;
                            });
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                ],
                if (aluno == null)
                  const _EstadoVazio(
                    icone: Icons.history,
                    mensagem: 'Selecione um aluno para ver o histórico.',
                  )
                else if (historico.isEmpty)
                  const _EstadoVazio(
                    icone: Icons.event_busy,
                    mensagem: 'Nenhum registro de aula para este aluno.',
                  )
                else
                  ...historico.map((registro) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    registro.dataTexto,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(registro.presencaTexto),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _HistoricoLinha(
                              rotulo: 'Instrutor',
                              valor: registro.instrutorTexto,
                            ),
                            const Divider(height: 20),
                            _HistoricoLinha(
                              rotulo: 'Descrição',
                              valor: valorOuPadrao(registro.descricao),
                            ),
                            _HistoricoLinha(
                              rotulo: 'Próxima aula',
                              valor: valorOuPadrao(registro.paraProximaAula),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
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

class _HistoricoLinha extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _HistoricoLinha({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$rotulo: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: valor),
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

String _normalizar(String texto) => texto.trim().toLowerCase();

String _textoAluno(Aluno aluno) {
  final cpf = aluno.cpf?.trim().isEmpty ?? true
      ? 'CPF não informado'
      : aluno.cpf!.trim();

  return '$cpf - ${aluno.comumCompleta}';
}
