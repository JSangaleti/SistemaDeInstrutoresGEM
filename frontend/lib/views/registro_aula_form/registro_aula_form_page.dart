import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../models/instrutor.dart';
import '../../models/registro_aula.dart';
import '../../services/registro_aula_service.dart';
import '../../widgets/searchable_selection.dart';

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

  List<Aluno> alunos = [];
  List<Instrutor> instrutores = [];
  int? alunoSelecionadoId;
  int? instrutorSelecionadoId;
  _ComumFiltro? comumFiltroSelecionada;
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

  Aluno? alunoSelecionado() {
    for (final aluno in alunos) {
      if (aluno.id == alunoSelecionadoId) return aluno;
    }

    return null;
  }

  Instrutor? instrutorSelecionado() {
    for (final instrutor in instrutores) {
      if (instrutor.id == instrutorSelecionadoId) return instrutor;
    }

    return null;
  }

  List<_ComumFiltro> filtrosComumAluno() {
    final filtros = <String, _ComumFiltro>{};

    for (final aluno in alunos) {
      final label = aluno.comumCompleta.trim();
      if (label.isEmpty || label == 'Sem comum') continue;
      filtros.putIfAbsent(label, () => _ComumFiltro(label));
    }

    final lista = filtros.values.toList();
    lista.sort((a, b) => a.label.compareTo(b.label));
    return lista;
  }

  List<Aluno> alunosDisponiveis() {
    final filtro = comumFiltroSelecionada;
    if (filtro == null) return alunos;

    return alunos.where((aluno) {
      return aluno.comumCompleta.trim() == filtro.label;
    }).toList();
  }

  void selecionarFiltroComum(_ComumFiltro? filtro) {
    setState(() {
      comumFiltroSelecionada = filtro;

      final alunoAtual = alunoSelecionado();
      if (alunoAtual != null &&
          filtro != null &&
          alunoAtual.comumCompleta.trim() != filtro.label) {
        alunoSelecionadoId = null;
      }
    });

    _formKey.currentState?.validate();
  }

  void limparFiltroComum() {
    setState(() {
      comumFiltroSelecionada = null;
    });
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
                    const _SecaoFormulario(
                      titulo: 'Participantes',
                      subtitulo: 'Informe o aluno e o instrutor responsável.',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SearchableSelectionField<_ComumFiltro>(
                              labelText: 'Filtro por comum',
                              dialogTitle: 'Filtrar alunos por comum',
                              items: filtrosComumAluno(),
                              value: comumFiltroSelecionada,
                              itemTitle: (item) => item.label,
                              itemSearchText: (item) => item.label,
                              searchHintText:
                                  'Buscar por comum, cidade ou estado...',
                              emptyText: 'Nenhuma comum encontrada.',
                              suffixIcon: comumFiltroSelecionada == null
                                  ? const Icon(Icons.filter_list)
                                  : IconButton(
                                      onPressed: limparFiltroComum,
                                      icon: const Icon(Icons.clear),
                                      tooltip: 'Limpar filtro',
                                    ),
                              onChanged: selecionarFiltroComum,
                            ),
                            const SizedBox(height: 16),
                            SearchableSelectionField<Aluno>(
                              labelText: 'Aluno',
                              dialogTitle: 'Selecionar aluno',
                              items: alunosDisponiveis(),
                              value: alunoSelecionado(),
                              itemTitle: (aluno) => aluno.nome,
                              itemSubtitle: textoAlunoDetalhes,
                              itemSearchText: (aluno) =>
                                  '${aluno.nome} ${aluno.cpf ?? ''} ${aluno.comumCompleta}',
                              searchHintText:
                                  'Buscar por nome, CPF ou comum...',
                              emptyText: 'Nenhum aluno encontrado.',
                              onChanged: (aluno) {
                                setState(() {
                                  alunoSelecionadoId = aluno?.id;
                                });
                              },
                              validator: (value) {
                                if (alunoSelecionadoId == null) {
                                  return 'Selecione um aluno';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (possuiInstrutorFixo)
                              InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Instrutor',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(textoInstrutorFixo()),
                              )
                            else
                              SearchableSelectionField<Instrutor>(
                                labelText: 'Instrutor',
                                dialogTitle: 'Selecionar instrutor',
                                items: instrutores,
                                value: instrutorSelecionado(),
                                itemTitle: (instrutor) => instrutor.nome,
                                itemSubtitle: (instrutor) =>
                                    '${instrutor.cpf ?? 'CPF não informado'} - ${instrutor.comumCompleta}',
                                itemSearchText: (instrutor) =>
                                    '${instrutor.nome} ${instrutor.cpf ?? ''} ${instrutor.comumCompleta}',
                                searchHintText:
                                    'Buscar por nome, CPF ou comum...',
                                onChanged: (instrutor) {
                                  setState(() {
                                    instrutorSelecionadoId = instrutor?.id;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecione um instrutor';
                                  }

                                  return null;
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SecaoFormulario(
                      titulo: 'Aula',
                      subtitulo: 'Registre a data, presença e observações.',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
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
                                DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text('Ausente'),
                                ),
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: salvando ? null : salvar,
                        icon: const Icon(Icons.save),
                        label: Text(
                          salvando
                              ? 'Salvando...'
                              : isEdicao
                              ? 'Salvar alterações'
                              : 'Cadastrar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SecaoFormulario extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const _SecaoFormulario({required this.titulo, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(subtitulo),
        ],
      ),
    );
  }
}

class _ComumFiltro {
  final String label;

  const _ComumFiltro(this.label);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _ComumFiltro &&
            runtimeType == other.runtimeType &&
            label == other.label;
  }

  @override
  int get hashCode => label.hashCode;
}
