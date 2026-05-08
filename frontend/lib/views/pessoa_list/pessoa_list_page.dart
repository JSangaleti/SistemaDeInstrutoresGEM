import 'package:flutter/material.dart';
import '../../models/pessoa.dart';
import '../../services/pessoa_service.dart';
import '../pessoa_form/pessoa_form_page.dart';

class PessoaListPage extends StatefulWidget {
  const PessoaListPage({super.key});

  @override
  State<PessoaListPage> createState() => _PessoaListPageState();
}

class _PessoaListPageState extends State<PessoaListPage> {
  final PessoaService service = PessoaService();

  List<Pessoa> pessoas = [];
  List<Pessoa> pessoasFiltradas = [];
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarPessoas();
  }

  Future<void> carregarPessoas() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getPessoas();
      setState(() {
        pessoas = lista;
        pessoasFiltradas = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void filtrarPessoas(String texto) {
    final resultado = pessoas.where((pessoa) {
      return pessoa.nome.toLowerCase().contains(texto.toLowerCase()) ||
          pessoa.cpf.contains(texto);
    }).toList();

    setState(() {
      pessoasFiltradas = resultado;
    });
  }

  Future<void> adicionarPessoa() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PessoaFormPage(),
      ),
    );

    if (resultado == true) {
      carregarPessoas();
    }
  }

  Future<void> editarPessoa(Pessoa pessoa) async {
    try {
      final pessoaCompleta = await service.getPessoaByCpf(pessoa.cpf);

      if (!context.mounted) return;

      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PessoaFormPage(pessoa: pessoaCompleta),
        ),
      );

      if (resultado == true) {
        carregarPessoas();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pessoa: $e')),
      );
    }
  }

  Future<void> confirmarExclusao(Pessoa pessoa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir pessoa'),
          content: Text('Deseja excluir a pessoa ${pessoa.nome}?'),
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
        await service.deletarPessoa(pessoa.cpf);
        await carregarPessoas();

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pessoa excluída com sucesso.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível excluir a pessoa. Ela pode estar vinculada a um aluno.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas'),
        actions: [
          IconButton(
            onPressed: carregarPessoas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarPessoa,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erro ao carregar pessoas:\n$erro',
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
                          hintText: 'Buscar pessoa...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: filtrarPessoas,
                      ),
                    ),
                    Expanded(
                      child: pessoas.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma pessoa cadastrada.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : pessoasFiltradas.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma pessoa encontrada na busca.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: pessoasFiltradas.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final pessoa = pessoasFiltradas[index];

                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          pessoa.nome.isNotEmpty
                                              ? pessoa.nome[0].toUpperCase()
                                              : '?',
                                        ),
                                      ),
                                      title: Text(pessoa.nome),
                                      subtitle: Text(
                                        '${pessoa.cpf}\n${pessoa.comum ?? 'Sem comum'}',
                                      ),
                                      isThreeLine: true,
                                      onTap: () => editarPessoa(pessoa),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => confirmarExclusao(pessoa),
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