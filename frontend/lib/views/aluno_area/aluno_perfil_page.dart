import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
import '../../widgets/alterar_senha_card.dart';

class AlunoPerfilPage extends StatefulWidget {
  final Aluno? aluno;
  final int? alunoId;

  const AlunoPerfilPage({super.key, this.aluno, this.alunoId});

  @override
  State<AlunoPerfilPage> createState() => _AlunoPerfilPageState();
}

class _AlunoPerfilPageState extends State<AlunoPerfilPage> {
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

  String valorPadrao(String? valor) {
    final texto = valor?.trim() ?? '';
    return texto.isEmpty ? 'Não informado' : texto;
  }

  @override
  Widget build(BuildContext context) {
    final alunoAtual = aluno;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do aluno'),
        actions: [
          IconButton(
            onPressed: carregarAluno,
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
                  'Erro ao carregar perfil:\n$erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : alunoAtual == null
          ? const Center(child: Text('Aluno não encontrado.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          child: Text(
                            alunoAtual.nome.isNotEmpty
                                ? alunoAtual.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            alunoAtual.nome,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  titulo: 'CPF',
                  valor: valorPadrao(alunoAtual.cpf),
                  icone: Icons.badge,
                ),
                _InfoCard(
                  titulo: 'Comum',
                  valor: valorPadrao(alunoAtual.comumCompleta),
                  icone: Icons.location_city,
                ),
                _InfoCard(
                  titulo: 'Cidade',
                  valor: valorPadrao(alunoAtual.comumCidade),
                  icone: Icons.location_on,
                ),
                _InfoCard(
                  titulo: 'Estado/UF',
                  valor: valorPadrao(alunoAtual.comumUF),
                  icone: Icons.map,
                ),
                _InstrumentosCard(aluno: alunoAtual),
                _MetodosInstrumentoPrincipalCard(aluno: alunoAtual),
                const AlterarSenhaCard(),
              ],
            ),
    );
  }
}

class _InstrumentosCard extends StatelessWidget {
  final Aluno aluno;

  const _InstrumentosCard({required this.aluno});

  @override
  Widget build(BuildContext context) {
    final instrumentos = [...aluno.instrumentos]
      ..sort((a, b) {
        if (a.principal == b.principal) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        }
        return a.principal ? -1 : 1;
      });

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.music_note),
            title: Text('Instrumentos que toca'),
          ),
          if (instrumentos.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Nenhum instrumento informado.'),
            )
          else
            ...instrumentos.map(
              (instrumento) => ListTile(
                dense: true,
                leading: Icon(
                  instrumento.principal ? Icons.star : Icons.music_note,
                  color: instrumento.principal
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(instrumento.nome),
                trailing: instrumento.principal
                    ? const Chip(label: Text('Principal'))
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _MetodosInstrumentoPrincipalCard extends StatelessWidget {
  final Aluno aluno;

  const _MetodosInstrumentoPrincipalCard({required this.aluno});

  @override
  Widget build(BuildContext context) {
    final instrumentoPrincipal = aluno.instrumentoPrincipal;

    final metodos =
        instrumentoPrincipal == null
              ? []
              : aluno.metodos.where((metodo) {
                  final mesmoId =
                      metodo.instrumentoId != null &&
                      metodo.instrumentoId == instrumentoPrincipal.id;

                  final mesmoNome =
                      metodo.instrumentoNome != null &&
                      metodo.instrumentoNome!.trim().toLowerCase() ==
                          instrumentoPrincipal.nome.trim().toLowerCase();

                  return mesmoId || mesmoNome;
                }).toList()
          ..sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
          );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Métodos do instrumento principal'),
            subtitle: Text(
              instrumentoPrincipal == null
                  ? 'Instrumento principal não informado'
                  : 'Instrumento principal: ${instrumentoPrincipal.nome}',
            ),
          ),
          if (instrumentoPrincipal == null)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Nenhum instrumento principal informado.'),
            )
          else if (metodos.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Nenhum método informado para o instrumento principal.',
              ),
            )
          else
            ...metodos.map(
              (metodo) => ListTile(
                dense: true,
                leading: const Icon(Icons.book_outlined),
                title: Text(metodo.nome),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _InfoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        subtitle: Text(valor, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
