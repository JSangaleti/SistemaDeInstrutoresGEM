import 'package:flutter/material.dart';

import '../../services/aluno_service.dart';
import '../../services/comum_service.dart';
import '../../services/instrumento_service.dart';
import '../../services/instrutor_service.dart';
import '../../services/metodo_service.dart';
import '../../services/pessoa_service.dart';
import '../../services/registro_aula_service.dart';
import '../aluno_area/aluno_home_page.dart';
import '../aluno_form/aluno_form_page.dart';
import '../aluno_list/aluno_list_page.dart';
import '../comum_form/comum_form_page.dart';
import '../comum_list/comum_list_page.dart';
import '../instrumento_form/instrumento_form_page.dart';
import '../instrumento_list/instrumento_list_page.dart';
import '../instrutor_form/instrutor_form_page.dart';
import '../instrutor_list/instrutor_list_page.dart';
import '../instrutor_panel/instrutor_panel_page.dart';
import '../metodo_form/metodo_form_page.dart';
import '../metodo_list/metodo_list_page.dart';
import '../pessoa_form/pessoa_form_page.dart';
import '../pessoa_list/pessoa_list_page.dart';
import '../registro_aula_form/registro_aula_form_page.dart';
import '../registro_aula_list/registro_aula_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AlunoService alunoService = AlunoService();
  final PessoaService pessoaService = PessoaService();
  final ComumService comumService = ComumService();
  final InstrumentoService instrumentoService = InstrumentoService();
  final InstrutorService instrutorService = InstrutorService();
  final MetodoService metodoService = MetodoService();
  final RegistroAulaService registroAulaService = RegistroAulaService();

  bool loading = true;
  String? erro;

  int totalAlunos = 0;
  int totalPessoas = 0;
  int totalComuns = 0;
  int totalInstrumentos = 0;
  int totalInstrutores = 0;
  int totalMetodos = 0;
  int totalRegistrosAula = 0;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final alunos = await alunoService.getAlunos();
      final pessoas = await pessoaService.getPessoas();
      final comuns = await comumService.getComuns();
      final instrumentos = await instrumentoService.getInstrumentos();
      final instrutores = await instrutorService.getInstrutores();
      final metodos = await metodoService.getMetodos();
      final registrosAula = await registroAulaService.getRegistrosAula();

      setState(() {
        totalAlunos = alunos.length;
        totalPessoas = pessoas.length;
        totalComuns = comuns.length;
        totalInstrumentos = instrumentos.length;
        totalInstrutores = instrutores.length;
        totalMetodos = metodos.length;
        totalRegistrosAula = registrosAula.length;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  Future<void> abrirTela(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema GEM'),
        actions: [
          IconButton(
            onPressed: carregarDados,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bem-vindo ao Sistema de Gestão do GEM',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gerencie alunos, instrutores, pessoas, comuns, instrumentos, métodos e registros de aula cadastrados no sistema.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  _AcaoRapidaButton(
                    texto: 'Acessar área do instrutor',
                    icone: Icons.dashboard,
                    onPressed: () => abrirTela(const InstrutorPanelPage()),
                  ),
                  const SizedBox(height: 12),
                  _AcaoRapidaButton(
                    texto: 'Acessar área do aluno',
                    icone: Icons.school,
                    onPressed: () => abrirTela(const AlunoHomePage()),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _ResumoCard(
                        titulo: 'Alunos',
                        total: totalAlunos,
                        icone: Icons.school,
                        onTap: () => abrirTela(const AlunoListPage()),
                      ),
                      _ResumoCard(
                        titulo: 'Pessoas',
                        total: totalPessoas,
                        icone: Icons.people,
                        onTap: () => abrirTela(const PessoaListPage()),
                      ),
                      _ResumoCard(
                        titulo: 'Comuns',
                        total: totalComuns,
                        icone: Icons.location_city,
                        onTap: () => abrirTela(const ComumListPage()),
                      ),
                      _ResumoCard(
                        titulo: 'Instrumentos',
                        total: totalInstrumentos,
                        icone: Icons.music_note,
                        onTap: () => abrirTela(const InstrumentoListPage()),
                      ),
                      _ResumoCard(
                        titulo: 'Instrutores',
                        total: totalInstrutores,
                        icone: Icons.co_present,
                        onTap: () => abrirTela(const InstrutorListPage()),
                      ),
                      _ResumoCard(
                        titulo: 'Métodos',
                        total: totalMetodos,
                        icone: Icons.menu_book,
                        onTap: () => abrirTela(const MetodoListPage()),
                      ),
                      _ResumoCard(
                        titulo: 'Registros de Aula',
                        total: totalRegistrosAula,
                        icone: Icons.event_note,
                        onTap: () => abrirTela(const RegistroAulaListPage()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Ações rápidas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _AcaoRapidaButton(
                    texto: 'Cadastrar novo aluno',
                    icone: Icons.person_add,
                    onPressed: () => abrirTela(const AlunoFormPage()),
                  ),
                  _AcaoRapidaButton(
                    texto: 'Cadastrar nova pessoa',
                    icone: Icons.person,
                    onPressed: () => abrirTela(const PessoaFormPage()),
                  ),
                  _AcaoRapidaButton(
                    texto: 'Cadastrar nova comum',
                    icone: Icons.add_business,
                    onPressed: () => abrirTela(const ComumFormPage()),
                  ),
                  _AcaoRapidaButton(
                    texto: 'Cadastrar novo instrumento',
                    icone: Icons.music_note,
                    onPressed: () => abrirTela(const InstrumentoFormPage()),
                  ),
                  _AcaoRapidaButton(
                    texto: 'Cadastrar novo instrutor',
                    icone: Icons.co_present,
                    onPressed: () => abrirTela(const InstrutorFormPage()),
                  ),
                  _AcaoRapidaButton(
                    texto: 'Cadastrar novo método',
                    icone: Icons.menu_book,
                    onPressed: () => abrirTela(const MetodoFormPage()),
                  ),
                  _AcaoRapidaButton(
                    texto: 'Cadastrar novo registro de aula',
                    icone: Icons.event_note,
                    onPressed: () => abrirTela(const RegistroAulaFormPage()),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final int total;
  final IconData icone;
  final VoidCallback onTap;

  const _ResumoCard({
    required this.titulo,
    required this.total,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icone, size: 36),
                const SizedBox(height: 16),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('cadastrados'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcaoRapidaButton extends StatelessWidget {
  final String texto;
  final IconData icone;
  final VoidCallback onPressed;

  const _AcaoRapidaButton({
    required this.texto,
    required this.icone,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icone),
        label: Text(texto),
      ),
    );
  }
}
