import 'package:flutter/material.dart';
import '../../models/comum.dart';
import '../../services/comum_service.dart';
import '../comum_form/comum_form_page.dart';

class ComumListPage extends StatefulWidget {
  const ComumListPage({super.key});

  @override
  State<ComumListPage> createState() => _ComumListPageState();
}

class _ComumListPageState extends State<ComumListPage> {
  final ComumService service = ComumService();

  List<Comum> comuns = [];
  List<Comum> comunsFiltradas = [];
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarComuns();
  }

  Future<void> carregarComuns() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getComuns();
      setState(() {
        comuns = lista;
        comunsFiltradas = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void filtrarComuns(String texto) {
    final resultado = comuns.where((comum) {
      final termo = texto.toLowerCase();
      return comum.nome.toLowerCase().contains(termo) ||
          (comum.cidade?.toLowerCase().contains(termo) ?? false) ||
          (comum.estado?.toLowerCase().contains(termo) ?? false) ||
          (comum.bairro?.toLowerCase().contains(termo) ?? false);
    }).toList();

    setState(() {
      comunsFiltradas = resultado;
    });
  }

  Future<void> adicionarComum() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComumFormPage(),
      ),
    );

    if (resultado == true) {
      carregarComuns();
    }
  }

  Future<void> editarComum(Comum comum) async {
    try {
      final comumCompleta = await service.getComumById(comum.id);

      if (!context.mounted) return;

      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComumFormPage(comum: comumCompleta),
        ),
      );

      if (resultado == true) {
        carregarComuns();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar comum: $e')),
      );
    }
  }

  Future<void> confirmarExclusao(Comum comum) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir comum'),
          content: Text('Deseja excluir a comum ${comum.nome}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await service.deletarComum(comum.id);
        await carregarComuns();

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comum excluída com sucesso.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível excluir a comum. Ela pode estar vinculada a pessoas ou alunos.',
            ),
          ),
        );
      }
    }
  }

  String montarDescricao(Comum comum) {
    final partes = <String>[
      if (comum.cidade != null && comum.cidade!.isNotEmpty) comum.cidade!,
      if (comum.estado != null && comum.estado!.isNotEmpty) comum.estado!,
      if (comum.bairro != null && comum.bairro!.isNotEmpty) comum.bairro!,
    ];

    if (partes.isEmpty) return 'Sem localização';
    return partes.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comuns'),
        actions: [
          IconButton(
            onPressed: carregarComuns,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarComum,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erro ao carregar comuns:\n$erro',
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
                          hintText: 'Buscar comum...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: filtrarComuns,
                      ),
                    ),
                    Expanded(
                      child: comuns.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma comum cadastrada.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : comunsFiltradas.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma comum encontrada na busca.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: comunsFiltradas.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final comum = comunsFiltradas[index];

                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          comum.nome.isNotEmpty
                                              ? comum.nome[0].toUpperCase()
                                              : '?',
                                        ),
                                      ),
                                      title: Text(comum.nome),
                                      subtitle: Text(montarDescricao(comum)),
                                      onTap: () => editarComum(comum),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => confirmarExclusao(comum),
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