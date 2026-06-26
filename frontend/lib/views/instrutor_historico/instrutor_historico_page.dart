import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../models/aluno.dart';
import '../../models/registro_aula.dart';
import '../../services/registro_aula_service.dart';
import '../registro_aula_form/registro_aula_form_page.dart';

class InstrutorHistoricoPage extends StatefulWidget {
  const InstrutorHistoricoPage({super.key});

  @override
  State<InstrutorHistoricoPage> createState() => _InstrutorHistoricoPageState();
}

class _InstrutorHistoricoPageState extends State<InstrutorHistoricoPage> {
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

  void filtrarAlunos(String texto) {
    final busca = texto.trim().toLowerCase();

    setState(() {
      alunosFiltrados = alunos.where((aluno) {
        return busca.isEmpty ||
            aluno.nome.toLowerCase().contains(busca) ||
            (aluno.cpf ?? '').toLowerCase().contains(busca);
      }).toList();
    });
  }

  List<RegistroAula> historicoAluno(Aluno aluno) {
    final nomeAluno = normalizar(aluno.nome);

    final historico = registros.where((registro) {
      if (registro.alunoId != null) {
        return registro.alunoId == aluno.id;
      }

      return normalizar(registro.alunoNome ?? '') == nomeAluno;
    }).toList();

    historico.sort((a, b) {
      final dataA = a.data ?? DateTime(1900);
      final dataB = b.data ?? DateTime(1900);
      return dataB.compareTo(dataA);
    });

    return historico;
  }

  Future<void> registrarNovaAula() async {
    final aluno = alunoSelecionado;
    if (aluno == null) return;

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroAulaFormPage(
          alunoInicialId: aluno.id,
          instrutorFixoId: AuthSession.usuarioId,
          instrutorFixoNome: AuthSession.nome,
        ),
      ),
    );

    if (resultado == true) {
      carregarDados();
    }
  }

  String normalizar(String texto) => texto.trim().toLowerCase();

  String textoAluno(Aluno aluno) {
    final cpf = aluno.cpf?.trim().isEmpty ?? true
        ? 'CPF não informado'
        : aluno.cpf!.trim();

    return '$cpf - ${aluno.comumCompleta}';
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
        title: const Text('Histórico de Aulas'),
        actions: [
          IconButton(
            onPressed: carregarDados,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: aluno == null
          ? null
          : FloatingActionButton.extended(
              onPressed: registrarNovaAula,
              icon: const Icon(Icons.add),
              label: const Text('Registrar aula'),
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico por aluno',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Selecione um aluno para consultar aulas anteriores e retomar o acompanhamento.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar aluno por nome ou CPF...',
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
                  ...alunosFiltrados.map((aluno) {
                    final selecionado = alunoSelecionado?.id == aluno.id;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          child: Text(
                            aluno.nome.isNotEmpty
                                ? aluno.nome[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(aluno.nome),
                        subtitle: Text(textoAluno(aluno)),
                        selected: selecionado,
                        trailing: selecionado
                            ? const Icon(Icons.check)
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          setState(() {
                            alunoSelecionado = aluno;
                          });
                        },
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                if (aluno == null)
                  const _EstadoVazio(
                    icone: Icons.history,
                    mensagem: 'Selecione um aluno para ver o histórico.',
                  )
                else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Text(
                              aluno.nome.isNotEmpty
                                  ? aluno.nome[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Histórico de ${aluno.nome}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(textoAluno(aluno)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (historico.isEmpty)
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
                                rotulo: 'Aluno',
                                valor: aluno.nome,
                              ),
                              _HistoricoLinha(
                                rotulo: 'CPF',
                                valor: aluno.cpf ?? 'CPF não informado',
                              ),
                              _HistoricoLinha(
                                rotulo: 'Comum',
                                valor: aluno.comumCompleta,
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
