import 'package:flutter/material.dart';

import '../../config/api_config.dart';
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

  List<RegistroAula> registros = [];
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getMeuHistorico();
      setState(() {
        registros = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  String valorOuPadrao(String? valor) {
    final texto = valor?.trim() ?? '';
    return texto.isEmpty ? 'Não informado' : texto;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nome = widget.aluno?.nome ?? AuthSession.nome ?? 'Aluno';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Histórico de Aulas'),
        actions: [
          IconButton(
            onPressed: carregarHistorico,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? _EstadoMensagem(
              icone: Icons.error_outline,
              mensagem: 'Erro ao carregar histórico:\n$erro',
              onRetry: carregarHistorico,
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
                  child: Row(
                    children: [
                      Icon(Icons.history, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Histórico de $nome',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text('${registros.length} registro(s) de aula'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (registros.isEmpty)
                  const _EstadoMensagem(
                    icone: Icons.event_busy,
                    mensagem: 'Nenhum registro de aula encontrado.',
                  )
                else
                  ...registros.map((registro) {
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                Chip(label: Text(registro.presencaTexto)),
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

class _EstadoMensagem extends StatelessWidget {
  final IconData icone;
  final String mensagem;
  final VoidCallback? onRetry;

  const _EstadoMensagem({
    required this.icone,
    required this.mensagem,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
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
