import 'package:flutter/material.dart';

import '../../models/instrutor.dart';
import '../../services/instrutor_service.dart';
import '../../widgets/alterar_senha_card.dart';

class InstrutorPerfilPage extends StatefulWidget {
  final Instrutor? instrutor;

  const InstrutorPerfilPage({super.key, this.instrutor});

  @override
  State<InstrutorPerfilPage> createState() => _InstrutorPerfilPageState();
}

class _InstrutorPerfilPageState extends State<InstrutorPerfilPage> {
  final InstrutorService service = InstrutorService();

  Instrutor? instrutor;
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    instrutor = widget.instrutor;
    carregarInstrutor();
  }

  Future<void> carregarInstrutor() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final resultado = await service.getMeuPerfil();
      setState(() {
        instrutor = resultado;
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
    final instrutorAtual = instrutor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do instrutor'),
        actions: [
          IconButton(
            onPressed: carregarInstrutor,
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
          : instrutorAtual == null
          ? const Center(child: Text('Instrutor não encontrado.'))
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
                            instrutorAtual.nome.isNotEmpty
                                ? instrutorAtual.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            instrutorAtual.nome,
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
                  valor: valorPadrao(instrutorAtual.cpf),
                  icone: Icons.badge,
                ),
                _InfoCard(
                  titulo: 'Comum',
                  valor: valorPadrao(instrutorAtual.comumCompleta),
                  icone: Icons.location_city,
                ),
                _InfoCard(
                  titulo: 'Cidade',
                  valor: valorPadrao(instrutorAtual.comumCidade),
                  icone: Icons.location_on,
                ),
                _InfoCard(
                  titulo: 'Estado/UF',
                  valor: valorPadrao(instrutorAtual.comumEstado),
                  icone: Icons.map,
                ),
                const AlterarSenhaCard(),
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
