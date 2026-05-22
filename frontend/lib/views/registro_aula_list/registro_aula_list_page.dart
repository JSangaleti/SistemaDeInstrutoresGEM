import 'package:flutter/material.dart';

import '../../models/registro_aula.dart';
import '../../services/registro_aula_service.dart';
import '../registro_aula_form/registro_aula_form_page.dart';

class RegistroAulaListPage extends StatefulWidget {
  final bool exibirExcluir;
  final int? instrutorFixoId;
  final String? instrutorFixoNome;

  const RegistroAulaListPage({
    super.key,
    this.exibirExcluir = true,
    this.instrutorFixoId,
    this.instrutorFixoNome,
  });

  @override
  State<RegistroAulaListPage> createState() => _RegistroAulaListPageState();
}

class _RegistroAulaListPageState extends State<RegistroAulaListPage> {
  final RegistroAulaService service = RegistroAulaService();

  List<RegistroAula> registros = [];
  List<RegistroAula> registrosFiltrados = [];
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarRegistros();
  }

  Future<void> carregarRegistros() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getRegistrosAula();

      setState(() {
        registros = lista;
        registrosFiltrados = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void filtrarRegistros(String texto) {
    final busca = texto.toLowerCase();

    setState(() {
      registrosFiltrados = registros.where((registro) {
        return registro.alunoTexto.toLowerCase().contains(busca) ||
            registro.instrutorTexto.toLowerCase().contains(busca) ||
            registro.dataTexto.toLowerCase().contains(busca) ||
            (registro.descricao ?? '').toLowerCase().contains(busca);
      }).toList();
    });
  }

  Future<void> adicionarRegistro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroAulaFormPage(
          instrutorFixoId: widget.instrutorFixoId,
          instrutorFixoNome: widget.instrutorFixoNome,
        ),
      ),
    );

    if (resultado == true) {
      carregarRegistros();
    }
  }

  Future<void> editarRegistro(RegistroAula registro) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroAulaFormPage(
          registro: registro,
          instrutorFixoId: widget.instrutorFixoId,
          instrutorFixoNome: widget.instrutorFixoNome,
        ),
      ),
    );

    if (resultado == true) {
      carregarRegistros();
    }
  }

  Future<void> confirmarExclusao(RegistroAula registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir registro de aula'),
          content: Text(
            'Deseja excluir o registro de ${registro.alunoTexto} em ${registro.dataTexto}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await service.deletarRegistroAula(registro.id);
        await carregarRegistros();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de aula excluído com sucesso.'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir registro de aula: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Aula'),
        actions: [
          IconButton(
            onPressed: carregarRegistros,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarRegistro,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar registros de aula:\n$erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registros de aula',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar por aluno, instrutor, data ou descrição...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: filtrarRegistros,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: registrosFiltrados.isEmpty
                      ? const _RegistroVazio()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                          itemCount: registrosFiltrados.length,
                          itemBuilder: (context, index) {
                            final registro = registrosFiltrados[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                leading: CircleAvatar(
                                  child: Text(
                                    registro.alunoTexto.isNotEmpty
                                        ? registro.alunoTexto[0].toUpperCase()
                                        : '?',
                                  ),
                                ),
                                title: Text(
                                  registro.alunoTexto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(registro.dataTexto),
                                      const SizedBox(height: 2),
                                      Text(registro.instrutorTexto),
                                      const SizedBox(height: 6),
                                      Chip(
                                        label: Text(registro.presencaTexto),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () => editarRegistro(registro),
                                trailing: widget.exibirExcluir
                                    ? IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            confirmarExclusao(registro),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _RegistroVazio extends StatelessWidget {
  const _RegistroVazio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 48),
            SizedBox(height: 12),
            Text(
              'Nenhum registro de aula encontrado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
