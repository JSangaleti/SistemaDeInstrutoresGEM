import 'package:flutter/material.dart';

import '../../models/metodo.dart';
import '../../services/metodo_service.dart';
import '../metodo_form/metodo_form_page.dart';

class MetodoListPage extends StatefulWidget {
  const MetodoListPage({super.key});

  @override
  State<MetodoListPage> createState() => _MetodoListPageState();
}

class _MetodoListPageState extends State<MetodoListPage> {
  final MetodoService service = MetodoService();

  List<Metodo> metodos = [];
  List<Metodo> metodosFiltrados = [];

  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarMetodos();
  }

  Future<void> carregarMetodos() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getMetodos();

      setState(() {
        metodos = lista;
        metodosFiltrados = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void filtrarMetodos(String texto) {
    final busca = texto.toLowerCase();

    setState(() {
      metodosFiltrados = metodos.where((metodo) {
        return metodo.nome.toLowerCase().contains(busca) ||
            metodo.instrumentoTexto.toLowerCase().contains(busca);
      }).toList();
    });
  }

  Future<void> adicionarMetodo() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MetodoFormPage()),
    );

    if (resultado == true) {
      carregarMetodos();
    }
  }

  Future<void> editarMetodo(Metodo metodo) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MetodoFormPage(metodo: metodo)),
    );

    if (resultado == true) {
      carregarMetodos();
    }
  }

  Future<void> confirmarExclusao(Metodo metodo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir método'),
          content: Text('Deseja excluir o método ${metodo.nome}?'),
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
        await service.deletarMetodo(metodo.id);
        await carregarMetodos();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Método excluído com sucesso.')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir método: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos'),
        actions: [
          IconButton(
            onPressed: carregarMetodos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarMetodo,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(child: Text('Erro ao carregar métodos:\n$erro'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar método...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: filtrarMetodos,
                  ),
                ),
                Expanded(
                  child: metodosFiltrados.isEmpty
                      ? const Center(child: Text('Nenhum método encontrado.'))
                      : ListView.separated(
                          itemCount: metodosFiltrados.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final metodo = metodosFiltrados[index];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  metodo.nome.isNotEmpty
                                      ? metodo.nome[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(metodo.nome),
                              subtitle: Text(metodo.instrumentoTexto),
                              onTap: () => editarMetodo(metodo),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => confirmarExclusao(metodo),
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
