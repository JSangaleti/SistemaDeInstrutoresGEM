import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../models/aluno.dart';
import '../../models/instrumento.dart';
import '../../models/metodo.dart';
import '../../models/pessoa.dart';
import '../../services/aluno_service.dart';
import '../../services/instrumento_service.dart';
import '../../services/metodo_service.dart';
import '../../services/pessoa_service.dart';
import '../../widgets/searchable_selection.dart';

class AlunoFormPage extends StatefulWidget {
  final Aluno? aluno;

  const AlunoFormPage({super.key, this.aluno});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
}

class _AlunoFormPageState extends State<AlunoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AlunoService service = AlunoService();
  final PessoaService pessoaService = PessoaService();
  final InstrumentoService instrumentoService = InstrumentoService();
  final MetodoService metodoService = MetodoService();

  final TextEditingController senhaController = TextEditingController();

  List<Pessoa> pessoas = [];
  List<Instrumento> instrumentos = [];
  List<Metodo> metodos = [];
  final Set<int> instrumentoIdsSelecionados = {};
  final Set<int> metodoIdsSelecionados = {};
  String? cpfSelecionado;
  int? instrumentoPrincipalId;

  bool loading = true;
  bool salvando = false;
  String? erro;

  bool get isEdicao => widget.aluno != null;
  bool get podeInformarSenha => !isEdicao || AuthSession.perfil == 'ADMIN';

  List<Metodo> get metodosDoInstrumentoPrincipal {
    final principalId = instrumentoPrincipalId;
    if (principalId == null) return [];
    return metodos
        .where((metodo) => metodo.instrumentoId == principalId)
        .toList();
  }

  int get quantidadeMetodosPreservados {
    final idsVisiveis = metodosDoInstrumentoPrincipal
        .map((metodo) => metodo.id)
        .toSet();
    return metodoIdsSelecionados.difference(idsVisiveis).length;
  }

  @override
  void initState() {
    super.initState();
    cpfSelecionado = widget.aluno?.cpf;
    carregarDados();
  }

  @override
  void dispose() {
    senhaController.dispose();
    super.dispose();
  }

  Future<void> carregarDados() async {
    try {
      final requisicoes = <Future<dynamic>>[
        pessoaService.getPessoas(),
        instrumentoService.getInstrumentos(),
        metodoService.getMetodos(),
        if (isEdicao) service.getAlunoById(widget.aluno!.id),
      ];
      final resultados = await Future.wait(requisicoes);
      final alunoAtual = isEdicao ? resultados[3] as Aluno : null;

      if (!mounted) return;
      setState(() {
        pessoas = resultados[0] as List<Pessoa>;
        instrumentos = resultados[1] as List<Instrumento>;
        metodos = resultados[2] as List<Metodo>;

        if (alunoAtual != null) {
          cpfSelecionado = alunoAtual.cpf;
          instrumentoIdsSelecionados.addAll(
            alunoAtual.instrumentos.map((instrumento) => instrumento.id),
          );
          instrumentoPrincipalId = alunoAtual.instrumentoPrincipal?.id;
          metodoIdsSelecionados.addAll(
            alunoAtual.metodos.map((metodo) => metodo.id),
          );
        }
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (cpfSelecionado == null) {
      _mostrarMensagem('Selecione uma pessoa.');
      return;
    }
    if (instrumentoIdsSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um instrumento.');
      return;
    }
    final principalId = instrumentoPrincipalId;
    if (principalId == null ||
        !instrumentoIdsSelecionados.contains(principalId)) {
      _mostrarMensagem('Defina o instrumento principal do aluno.');
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      if (isEdicao) {
        await service.editarAluno(
          id: widget.aluno!.id,
          cpf: cpfSelecionado!,
          senha: podeInformarSenha ? senhaController.text.trim() : null,
          instrumentoIds: instrumentoIdsSelecionados,
          instrumentoPrincipalId: principalId,
          metodoIds: metodoIdsSelecionados,
        );
      } else {
        await service.criarAluno(
          cpf: cpfSelecionado!,
          senha: senhaController.text.trim(),
          instrumentoIds: instrumentoIdsSelecionados,
          instrumentoPrincipalId: principalId,
          metodoIds: metodoIdsSelecionados,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _alternarInstrumento(int instrumentoId, bool selecionado) {
    setState(() {
      if (selecionado) {
        instrumentoIdsSelecionados.add(instrumentoId);
        instrumentoPrincipalId ??= instrumentoId;
      } else {
        instrumentoIdsSelecionados.remove(instrumentoId);
        if (instrumentoPrincipalId == instrumentoId) {
          instrumentoPrincipalId = instrumentoIdsSelecionados.isEmpty
              ? null
              : instrumentoIdsSelecionados.first;
        }
      }
    });
  }

  String? validarSenha(String? value) {
    final senha = value?.trim() ?? '';
    if (!isEdicao && senha.isEmpty) return 'Informe a senha';
    if (senha.isNotEmpty && senha.length > 255) {
      return 'Senha deve ter no máximo 255 caracteres';
    }
    return null;
  }

  String textoPessoa(Pessoa pessoa) => '${pessoa.nome} - ${pessoa.cpf}';

  Pessoa? pessoaSelecionada() {
    for (final pessoa in pessoas) {
      if (pessoa.cpf == cpfSelecionado) return pessoa;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Aluno' : 'Cadastrar Aluno'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar dados do formulário:\n$erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDadosPessoais(),
                  const SizedBox(height: 24),
                  _buildInstrumentos(),
                  const SizedBox(height: 24),
                  _buildMetodos(),
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
    );
  }

  Widget _buildDadosPessoais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados do aluno', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SearchableSelectionField<Pessoa>(
          labelText: 'Pessoa',
          dialogTitle: 'Selecionar pessoa',
          items: pessoas,
          value: pessoaSelecionada(),
          itemTitle: textoPessoa,
          itemSubtitle: (pessoa) => pessoa.comumCompleta,
          itemSearchText: (pessoa) =>
              '${pessoa.nome} ${pessoa.cpf} ${pessoa.comumCompleta}',
          searchHintText: 'Buscar por nome, CPF ou comum...',
          onChanged: (pessoa) {
            setState(() {
              cpfSelecionado = pessoa?.cpf;
            });
          },
          validator: (value) => value == null ? 'Selecione uma pessoa' : null,
        ),
        const SizedBox(height: 16),
        if (podeInformarSenha)
          TextFormField(
            controller: senhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: isEdicao ? 'Nova senha (opcional)' : 'Senha',
              border: const OutlineInputBorder(),
            ),
            validator: validarSenha,
          ),
      ],
    );
  }

  Widget _buildInstrumentos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instrumentos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text(
          'Selecione os instrumentos do aluno e marque exatamente um como principal.',
        ),
        const SizedBox(height: 8),
        if (instrumentos.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum instrumento cadastrado.'),
            ),
          )
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: instrumentos.map((instrumento) {
                final selecionado = instrumentoIdsSelecionados.contains(
                  instrumento.id,
                );
                final principal = instrumentoPrincipalId == instrumento.id;

                return ListTile(
                  onTap: () =>
                      _alternarInstrumento(instrumento.id, !selecionado),
                  leading: Checkbox(
                    value: selecionado,
                    onChanged: (value) =>
                        _alternarInstrumento(instrumento.id, value ?? false),
                  ),
                  title: Text(instrumento.nome),
                  subtitle: principal
                      ? const Text('Instrumento principal')
                      : null,
                  trailing: IconButton(
                    onPressed: selecionado
                        ? () {
                            setState(() {
                              instrumentoPrincipalId = instrumento.id;
                            });
                          }
                        : null,
                    tooltip: principal
                        ? 'Instrumento principal'
                        : 'Definir como principal',
                    icon: Icon(
                      principal
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMetodos() {
    final metodosVisiveis = metodosDoInstrumentoPrincipal;
    final principal = instrumentos
        .where((instrumento) => instrumento.id == instrumentoPrincipalId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Métodos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          principal == null
              ? 'Defina o instrumento principal para escolher os métodos.'
              : 'Métodos disponíveis para ${principal.nome}.',
        ),
        if (quantidadeMetodosPreservados > 0) ...[
          const SizedBox(height: 4),
          Text(
            '$quantidadeMetodosPreservados método(s) de outros instrumentos serão preservados.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        if (principal != null && metodosVisiveis.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum método cadastrado para este instrumento.'),
            ),
          )
        else if (metodosVisiveis.isNotEmpty)
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: metodosVisiveis.map((metodo) {
                return CheckboxListTile(
                  value: metodoIdsSelecionados.contains(metodo.id),
                  title: Text(metodo.nome),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (selecionado) {
                    setState(() {
                      if (selecionado == true) {
                        metodoIdsSelecionados.add(metodo.id);
                      } else {
                        metodoIdsSelecionados.remove(metodo.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
