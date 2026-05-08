import 'package:flutter/material.dart';

import '../../models/instrutor.dart';
import '../../services/instrutor_service.dart';
import '../instrutor_form/instrutor_form_page.dart';

class InstrutorListPage extends StatefulWidget {
  const InstrutorListPage({super.key});

  @override
  State<InstrutorListPage> createState() => _InstrutorListPageState();
}

class _InstrutorListPageState extends State<InstrutorListPage> {
  final InstrutorService service = InstrutorService();

  List<Instrutor> instrutores = [];
  List<Instrutor> instrutoresFiltrados = [];

  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarInstrutores();
  }

  Future<void> carregarInstrutores() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getInstrutores();

      setState(() {
        instrutores = lista;
        instrutoresFiltrados = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void filtrarInstrutores(String texto) {
    final busca = texto.toLowerCase();

    final resultado = instrutores.where((instrutor) {
      return instrutor.nome.toLowerCase().contains(busca) ||
          (instrutor.cpf ?? '').contains(busca) ||
          (instrutor.comum ?? '').toLowerCase().contains(busca);
    }).toList();

    setState(() {
      instrutoresFiltrados = resultado;
    });
  }

  Future<void> adicionarInstrutor() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstrutorFormPage(),
      ),
    );

    if (resultado == true) {
      carregarInstrutores();
    }
  }

  Future<void> editarInstrutor(Instrutor instrutor) async {
    try {
      final instrutorCompleto = await service.getInstrutorById(instrutor.id);

      if (!mounted) return;

      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstrutorFormPage(instrutor: instrutorCompleto),
        ),
      );

      if (resultado == true) {
        carregarInstrutores();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar instrutor: $e')),
      );
    }
  }

  Future<void> confirmarExclusao(Instrutor instrutor) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir instrutor'),
          content: Text('Deseja excluir o instrutor ${instrutor.nome}?'),
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
        await service.deletarInstrutor(instrutor.id);
        await carregarInstrutores();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instrutor excluído com sucesso.')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instrutores'),
        actions: [
          IconButton(
            onPressed: carregarInstrutores,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarInstrutor,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erro ao carregar instrutores:\n$erro',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar instrutor...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: filtrarInstrutores,
                      ),
                    ),
                    Expanded(
                      child: instrutores.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum instrutor cadastrado.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : instrutoresFiltrados.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum instrutor encontrado na busca.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: instrutoresFiltrados.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final instrutor =
                                        instrutoresFiltrados[index];

                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          instrutor.nome.isNotEmpty
                                              ? instrutor.nome[0].toUpperCase()
                                              : '?',
                                        ),
                                      ),
                                      title: Text(instrutor.nome),
                                      subtitle: Text(instrutor.comumCompleta),
                                      onTap: () => editarInstrutor(instrutor),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            confirmarExclusao(instrutor),
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