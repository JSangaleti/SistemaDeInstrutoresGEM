import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
import '../aluno_form/aluno_form_page.dart';

class AlunoListPage extends StatefulWidget {
  const AlunoListPage({super.key});

  @override
  State<AlunoListPage> createState() => _AlunoListPageState();
}

class _AlunoListPageState extends State<AlunoListPage> {
  final AlunoService service = AlunoService();

  List<Aluno> alunos = [];
  List<Aluno> alunosFiltrados = [];
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarAlunos();
  }

  Future<void> carregarAlunos() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getAlunos();
      setState(() {
        alunos = lista;
        alunosFiltrados = lista;
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
    final resultado = alunos.where((aluno) {
      return aluno.nome.toLowerCase().contains(texto.toLowerCase());
    }).toList();

    setState(() {
      alunosFiltrados = resultado;
    });
  }

  Future<void> adicionarAluno() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AlunoFormPage(),
      ),
    );

    if (resultado == true) {
      carregarAlunos();
    }
  }

  Future<void> confirmarExclusao(Aluno aluno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir aluno'),
          content: Text('Deseja excluir o aluno ${aluno.nome}?'),
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
        await service.deletarAluno(aluno.id);
        await carregarAlunos();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno excluído com sucesso.')),
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
        title: const Text('Alunos'),
        actions: [
          IconButton(
            onPressed: carregarAlunos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarAluno,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erro ao carregar alunos:\n$erro',
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
                          hintText: 'Buscar aluno...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: filtrarAlunos,
                      ),
                    ),
                    Expanded(
                      child: alunos.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum aluno cadastrado.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : alunosFiltrados.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum aluno encontrado na busca.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: alunosFiltrados.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final aluno = alunosFiltrados[index];

                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          aluno.nome.isNotEmpty
                                              ? aluno.nome[0].toUpperCase()
                                              : '?',
                                        ),
                                      ),
                                      title: Text(aluno.nome),
                                      subtitle: Text(aluno.comum ?? 'Sem comum'),
                                      onTap: () async {
                                        try {
                                          final alunoCompleto = await service.getAlunoById(aluno.id);

                                          if (!context.mounted) return;

                                          final resultado = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AlunoFormPage(aluno: alunoCompleto),
                                            ),
                                          );

                                          if (resultado == true) {
                                            carregarAlunos();
                                          }
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erro ao carregar dados do aluno: $e')),
                                          );
                                        }
                                      },
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => confirmarExclusao(aluno),
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