import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
import '../aluno_form/aluno_form_page.dart';

class AlunoListPage extends StatefulWidget {
  @override
  _AlunoListPageState createState() => _AlunoListPageState();
}

class _AlunoListPageState extends State<AlunoListPage> {
  final AlunoService service = AlunoService();

  List<Aluno> alunos = [];
  List<Aluno> alunosFiltrados = [];

  @override
  void initState() {
    super.initState();

    alunos = service.getAlunos();
    alunosFiltrados = alunos;
  }

  void filtrarAlunos(String texto) {
    final resultado = alunos.where((aluno) {
      return aluno.nome.toLowerCase().contains(texto.toLowerCase());
    }).toList();

    setState(() {
      alunosFiltrados = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Alunos'),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final novoAluno = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlunoFormPage(),
              ),
            );

            if (novoAluno != null) {
              setState(() {
                alunos.add(novoAluno);
                alunosFiltrados = alunos;
              });
            }
          },
          child: Icon(Icons.add),
        ),

        body: Column(
        children: [
          // CAMPO DE BUSCA
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar aluno...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filtrarAlunos,
            ),
          ),

          // LISTA
          Expanded(
            child: ListView.builder(
              itemCount: alunosFiltrados.length,
              itemBuilder: (context, index) {
                final aluno = alunosFiltrados[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(aluno.nome[0]),
                  ),
                  title: Text(aluno.nome),
                  onTap: () async {
                    final alunoEditado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlunoFormPage(aluno: aluno),
                      ),
                    );

                    if (alunoEditado != null) {
                      setState(() {
                        final index = alunos.indexWhere((a) => a.id == aluno.id);
                        alunos[index] = alunoEditado;
                        alunosFiltrados = alunos;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}