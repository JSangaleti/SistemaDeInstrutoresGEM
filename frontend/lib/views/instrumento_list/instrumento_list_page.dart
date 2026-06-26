import 'package:flutter/material.dart';

import '../../models/instrumento.dart';
import '../../services/instrumento_service.dart';
import '../instrumento_form/instrumento_form_page.dart';

class InstrumentoListPage extends StatefulWidget {
  const InstrumentoListPage({super.key});

  @override
  State<InstrumentoListPage> createState() => _InstrumentoListPageState();
}

class _InstrumentoListPageState extends State<InstrumentoListPage> {
  final InstrumentoService service = InstrumentoService();

  List<Instrumento> instrumentos = [];
  List<Instrumento> instrumentosFiltrados = [];

  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarInstrumentos();
  }

  Future<void> carregarInstrumentos() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getInstrumentos();

      setState(() {
        instrumentos = lista;
        instrumentosFiltrados = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void filtrarInstrumentos(String texto) {
    final busca = texto.toLowerCase();

    setState(() {
      instrumentosFiltrados = instrumentos.where((instrumento) {
        return instrumento.nome.toLowerCase().contains(busca);
      }).toList();
    });
  }

  Future<void> adicionarInstrumento() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InstrumentoFormPage()),
    );

    if (resultado == true) {
      carregarInstrumentos();
    }
  }

  Future<void> editarInstrumento(Instrumento instrumento) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstrumentoFormPage(instrumento: instrumento),
      ),
    );

    if (resultado == true) {
      carregarInstrumentos();
    }
  }

  Future<void> confirmarExclusao(Instrumento instrumento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir instrumento'),
          content: Text('Deseja excluir o instrumento ${instrumento.nome}?'),
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
        await service.deletarInstrumento(instrumento.id);
        await carregarInstrumentos();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instrumento excluído com sucesso.')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir instrumento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instrumentos'),
        actions: [
          IconButton(
            onPressed: carregarInstrumentos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarInstrumento,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(child: Text('Erro ao carregar instrumentos:\n$erro'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar instrumento...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: filtrarInstrumentos,
                  ),
                ),
                Expanded(
                  child: instrumentosFiltrados.isEmpty
                      ? const Center(
                          child: Text('Nenhum instrumento encontrado.'),
                        )
                      : ListView.separated(
                          itemCount: instrumentosFiltrados.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final instrumento = instrumentosFiltrados[index];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  instrumento.nome.isNotEmpty
                                      ? instrumento.nome[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(instrumento.nome),
                              onTap: () => editarInstrumento(instrumento),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => confirmarExclusao(instrumento),
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
