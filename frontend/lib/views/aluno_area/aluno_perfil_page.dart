import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../services/aluno_service.dart';

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
          : aluno == null
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
                            aluno!.nome.isNotEmpty
                                ? aluno!.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            aluno!.nome,
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
                  valor: valorPadrao(aluno!.cpf),
                  icone: Icons.badge,
                ),
                _InfoCard(
                  titulo: 'Comum',
                  valor: valorPadrao(aluno!.comumCompleta),
                  icone: Icons.location_city,
                ),
                _InfoCard(
                  titulo: 'Cidade',
                  valor: valorPadrao(aluno!.comumCidade),
                  icone: Icons.location_on,
                ),
                _InfoCard(
                  titulo: 'Estado/UF',
                  valor: valorPadrao(aluno!.comumUF),
                  icone: Icons.map,
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
