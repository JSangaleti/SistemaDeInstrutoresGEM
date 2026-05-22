import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../models/instrutor.dart';
import '../../models/registro_aula.dart';
import '../../services/registro_aula_service.dart';

class RegistroAulaFormPage extends StatefulWidget {
  final RegistroAula? registro;
  final int? alunoInicialId;
  final int? instrutorFixoId;
  final String? instrutorFixoNome;

  const RegistroAulaFormPage({
    super.key,
    this.registro,
    this.alunoInicialId,
    this.instrutorFixoId,
    this.instrutorFixoNome,
  });

  @override
  State<RegistroAulaFormPage> createState() => _RegistroAulaFormPageState();
}

class _RegistroAulaFormPageState extends State<RegistroAulaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final RegistroAulaService service = RegistroAulaService();

  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController paraProximaAulaController =
      TextEditingController();
  final TextEditingController dataController = TextEditingController();
  final TextEditingController alunoController = TextEditingController();

  List<Aluno> alunos = [];
  List<Instrutor> instrutores = [];
  int? alunoSelecionadoId;
  int? instrutorSelecionadoId;
  int? presenteSelecionado;
  DateTime? dataSelecionada;

  bool loading = true;
  bool salvando = false;
  String? erro;

  bool get isEdicao => widget.registro != null;
  bool get possuiInstrutorFixo => widget.instrutorFixoId != null;

  @override
  void initState() {
    super.initState();

    if (widget.registro != null) {
      descricaoController.text = widget.registro!.descricao ?? '';
      paraProximaAulaController.text = widget.registro!.paraProximaAula ?? '';
      alunoSelecionadoId = widget.registro!.alunoId;
      instrutorSelecionadoId = widget.registro!.instrutorId;
      presenteSelecionado = widget.registro!.presente;
      dataSelecionada = widget.registro!.data;
      dataController.text = _formatarData(dataSelecionada);
    } else {
      dataSelecionada = DateTime.now();
      dataController.text = _formatarData(dataSelecionada);
      presenteSelecionado = 1;
    }

    alunoSelecionadoId ??= widget.alunoInicialId;
    instrutorSelecionadoId ??= widget.instrutorFixoId;

    carregarDados();
  }

  @override
  void dispose() {
    descricaoController.dispose();
    paraProximaAulaController.dispose();
    dataController.dispose();
    alunoController.dispose();
    super.dispose();
  }

  Future<void> carregarDados() async {
    try {
      final alunosLista = await service.getAlunos();
      final instrutoresLista = possuiInstrutorFixo
          ? <Instrutor>[]
          : await service.getInstrutores();

      setState(() {
        alunos = alunosLista;
        instrutores = instrutoresLista;
        _preencherRelacionamentosPorNome();
        _atualizarAlunoController();
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void _preencherRelacionamentosPorNome() {
    if (!isEdicao) return;

    alunoSelecionadoId ??= _buscarAlunoPorNome(widget.registro!.alunoNome);
    instrutorSelecionadoId ??= _buscarInstrutorPorNome(
      widget.registro!.instrutorNome,
    );
  }

  int? _buscarAlunoPorNome(String? nome) {
    final nomeBusca = nome?.trim().toLowerCase() ?? '';
    if (nomeBusca.isEmpty) return null;

    for (final aluno in alunos) {
      if (aluno.nome.trim().toLowerCase() == nomeBusca) {
        return aluno.id;
      }
    }

    return null;
  }

  int? _buscarInstrutorPorNome(String? nome) {
    final nomeBusca = nome?.trim().toLowerCase() ?? '';
    if (nomeBusca.isEmpty) return null;

    for (final instrutor in instrutores) {
      if (instrutor.nome.trim().toLowerCase() == nomeBusca) {
        return instrutor.id;
      }
    }

    return null;
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data == null) return;

    setState(() {
      dataSelecionada = data;
      dataController.text = _formatarData(dataSelecionada);
    });
  }

  Future<void> selecionarAluno() async {
    final aluno = await showDialog<Aluno>(
      context: context,
      builder: (dialogContext) {
        String busca = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final alunosFiltrados = filtrarAlunos(busca);

            return AlertDialog(
              title: const Text('Selecionar aluno'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nome, CPF ou comum...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          busca = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: alunosFiltrados.isEmpty
                          ? const Center(
                              child: Text('Nenhum aluno encontrado.'),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: alunosFiltrados.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final aluno = alunosFiltrados[index];

                                return ListTile(
                                  title: Text(aluno.nome),
                                  subtitle: Text(textoAlunoDetalhes(aluno)),
                                  onTap: () =>
                                      Navigator.pop(dialogContext, aluno),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (aluno == null) return;

    setState(() {
      alunoSelecionadoId = aluno.id;
      _atualizarAlunoController();
    });

    _formKey.currentState?.validate();
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (alunoSelecionadoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um aluno')));
      return;
    }

    if (instrutorSelecionadoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um instrutor')));
      return;
    }

    if (dataSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma data')));
      return;
    }

    if (presenteSelecionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe a presença')));
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final descricaoInformada = descricaoController.text.trim();
      final descricaoFinal =
          presenteSelecionado == 0 && descricaoInformada.isEmpty
          ? 'Aluno ausente.'
          : descricaoInformada;

      if (isEdicao) {
        final paraProximaAula = paraProximaAulaController.text.trim();
        final deveEnviarParaProximaAula =
            widget.registro!.paraProximaAula != null ||
            paraProximaAula.isNotEmpty;

        await service.editarRegistroAula(
          id: widget.registro!.id,
          alunoId: alunoSelecionadoId!,
          instrutorId: instrutorSelecionadoId!,
          data: dataSelecionada!,
          presente: presenteSelecionado!,
          descricao: descricaoFinal,
          paraProximaAula: deveEnviarParaProximaAula ? paraProximaAula : null,
        );
      } else {
        await service.criarRegistroAula(
          alunoId: alunoSelecionadoId!,
          instrutorId: instrutorSelecionadoId!,
          data: dataSelecionada!,
          presente: presenteSelecionado!,
          descricao: descricaoFinal,
          paraProximaAula: paraProximaAulaController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar registro de aula: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }

  String textoAluno(Aluno aluno) {
    return '${aluno.nome} - ${textoAlunoDetalhes(aluno)}';
  }

  String textoAlunoDetalhes(Aluno aluno) {
    final cpfLimpo = aluno.cpf?.trim() ?? '';
    final cpf = cpfLimpo.isEmpty ? 'CPF não informado' : cpfLimpo;

    return '$cpf - ${aluno.comumCompleta}';
  }

  List<Aluno> filtrarAlunos(String texto) {
    final busca = texto.trim().toLowerCase();
    if (busca.isEmpty) return alunos;

    return alunos.where((aluno) {
      return aluno.nome.toLowerCase().contains(busca) ||
          (aluno.cpf ?? '').toLowerCase().contains(busca) ||
          aluno.comumCompleta.toLowerCase().contains(busca);
    }).toList();
  }

  Aluno? alunoSelecionado() {
    for (final aluno in alunos) {
      if (aluno.id == alunoSelecionadoId) return aluno;
    }

    return null;
  }

  void _atualizarAlunoController() {
    final aluno = alunoSelecionado();
    alunoController.text = aluno == null ? '' : textoAluno(aluno);
  }

  String textoInstrutorFixo() {
    final nome = widget.instrutorFixoNome?.trim();
    if (nome != null && nome.isNotEmpty) return nome;

    return 'Instrutor atual';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdicao ? 'Editar Registro de Aula' : 'Cadastrar Registro de Aula',
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar dados:\n$erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: alunoController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Aluno',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onTap: selecionarAluno,
                      validator: (value) {
                        if (alunoSelecionadoId == null) {
                          return 'Selecione um aluno';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (possuiInstrutorFixo) ...[
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Instrutor',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(textoInstrutorFixo()),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      DropdownButtonFormField<int>(
                        initialValue: instrutorSelecionadoId,
                        decoration: const InputDecoration(
                          labelText: 'Instrutor',
                          border: OutlineInputBorder(),
                        ),
                        items: instrutores.map((instrutor) {
                          return DropdownMenuItem<int>(
                            value: instrutor.id,
                            child: Text(
                              instrutor.nome,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            instrutorSelecionadoId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um instrutor';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: selecionarData,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Selecione uma data';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: presenteSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Presença',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text('Presente'),
                        ),
                        DropdownMenuItem<int>(value: 0, child: Text('Ausente')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          presenteSelecionado = value;
                        });
                        _formKey.currentState?.validate();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Informe a presença';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (presenteSelecionado == 1 &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Informe a descrição';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: paraProximaAulaController,
                      decoration: const InputDecoration(
                        labelText: 'Para próxima aula',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: salvando ? null : salvar,
                      child: Text(
                        salvando
                            ? 'Salvando...'
                            : isEdicao
                            ? 'Salvar alterações'
                            : 'Cadastrar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
