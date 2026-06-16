import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../services/aluno_service.dart';
import '../../services/comum_service.dart';
import '../../services/instrumento_service.dart';
import '../../services/instrutor_service.dart';
import '../../services/metodo_service.dart';
import '../../services/pessoa_service.dart';
import '../../services/registro_aula_service.dart';
import '../../widgets/logout_button.dart';
import '../admin_form/admin_form_page.dart';
import '../admin_list/admin_list_page.dart';
import '../aluno_form/aluno_form_page.dart';
import '../aluno_list/aluno_list_page.dart';
import '../comum_form/comum_form_page.dart';
import '../comum_list/comum_list_page.dart';
import '../instrumento_form/instrumento_form_page.dart';
import '../instrumento_list/instrumento_list_page.dart';
import '../instrutor_form/instrutor_form_page.dart';
import '../instrutor_list/instrutor_list_page.dart';
import '../metodo_form/metodo_form_page.dart';
import '../metodo_list/metodo_list_page.dart';
import '../pessoa_form/pessoa_form_page.dart';
import '../pessoa_list/pessoa_list_page.dart';
import '../registro_aula_form/registro_aula_form_page.dart';
import '../registro_aula_list/registro_aula_list_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminService adminService = AdminService();
  final AlunoService alunoService = AlunoService();
  final PessoaService pessoaService = PessoaService();
  final ComumService comumService = ComumService();
  final InstrumentoService instrumentoService = InstrumentoService();
  final InstrutorService instrutorService = InstrutorService();
  final MetodoService metodoService = MetodoService();
  final RegistroAulaService registroAulaService = RegistroAulaService();

  bool loading = true;
  String? erro;

  int totalAdmins = 0;
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
      final admins = await adminService.getAdmins();
      final alunos = await alunoService.getAlunos();
      final pessoas = await pessoaService.getPessoas();
      final comuns = await comumService.getComuns();
      final instrumentos = await instrumentoService.getInstrumentos();
      final instrutores = await instrutorService.getInstrutores();
      final metodos = await metodoService.getMetodos();
      final registrosAula = await registroAulaService.getRegistrosAula();

      setState(() {
        totalAdmins = admins.length;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Administrador'),
        actions: [
          IconButton(
            onPressed: carregarDados,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          const LogoutButton(),
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 36,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Área do Administrador',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gerencie cadastros, acompanhe registros e mantenha os dados do GEM atualizados.',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Resumo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _ResumoGrid(
                  children: [
                    _ResumoCard(
                      titulo: 'Administradores',
                      total: totalAdmins,
                      icone: Icons.admin_panel_settings,
                      onTap: () => abrirTela(const AdminListPage()),
                    ),
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
                _AcoesGrid(
                  children: [
                    _AcaoRapidaCard(
                      texto: 'Novo administrador',
                      icone: Icons.admin_panel_settings,
                      onTap: () => abrirTela(const AdminFormPage()),
                    ),
                    _AcaoRapidaCard(
                      texto: 'Novo aluno',
                      icone: Icons.person_add,
                      onTap: () => abrirTela(const AlunoFormPage()),
                    ),
                    _AcaoRapidaCard(
                      texto: 'Nova pessoa',
                      icone: Icons.person,
                      onTap: () => abrirTela(const PessoaFormPage()),
                    ),
                    _AcaoRapidaCard(
                      texto: 'Nova comum',
                      icone: Icons.add_business,
                      onTap: () => abrirTela(const ComumFormPage()),
                    ),
                    _AcaoRapidaCard(
                      texto: 'Novo instrumento',
                      icone: Icons.music_note,
                      onTap: () => abrirTela(const InstrumentoFormPage()),
                    ),
                    _AcaoRapidaCard(
                      texto: 'Novo instrutor',
                      icone: Icons.co_present,
                      onTap: () => abrirTela(const InstrutorFormPage()),
                    ),
                    _AcaoRapidaCard(
                      texto: 'Novo método',
                      icone: Icons.menu_book,
                      onTap: () => abrirTela(const MetodoFormPage()),
                    ),
                    _AcaoRapidaCard(
                      texto: 'Novo registro de aula',
                      icone: Icons.event_note,
                      onTap: () => abrirTela(const RegistroAulaFormPage()),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ResumoGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResumoGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 900
            ? 5
            : largura >= 640
            ? 4
            : largura >= 340
            ? 2
            : 1;
        final larguraItem = (largura - (colunas - 1) * 10) / colunas;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map((child) => SizedBox(width: larguraItem, child: child))
              .toList(),
        );
      },
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icone,
                    size: 21,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        total.toString(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              height: 1,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'cadastrados',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcoesGrid extends StatelessWidget {
  final List<Widget> children;

  const _AcoesGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraItem = constraints.maxWidth >= 760
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth >= 520
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((child) => SizedBox(width: larguraItem, child: child))
              .toList(),
        );
      },
    );
  }
}

class _AcaoRapidaCard extends StatelessWidget {
  final String texto;
  final IconData icone;
  final VoidCallback onTap;

  const _AcaoRapidaCard({
    required this.texto,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(radius: 20, child: Icon(icone, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}
