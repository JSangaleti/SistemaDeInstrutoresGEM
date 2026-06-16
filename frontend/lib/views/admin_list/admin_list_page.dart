import 'package:flutter/material.dart';

import '../../models/admin.dart';
import '../../services/admin_service.dart';
import '../admin_form/admin_form_page.dart';

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  final AdminService service = AdminService();

  List<Admin> admins = [];
  List<Admin> adminsFiltrados = [];

  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarAdmins();
  }

  Future<void> carregarAdmins() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final lista = await service.getAdmins();

      setState(() {
        admins = lista;
        adminsFiltrados = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  void filtrarAdmins(String texto) {
    final busca = texto.toLowerCase();

    final resultado = admins.where((admin) {
      return admin.nome.toLowerCase().contains(busca) ||
          (admin.cpf ?? '').contains(busca) ||
          (admin.comum ?? '').toLowerCase().contains(busca);
    }).toList();

    setState(() {
      adminsFiltrados = resultado;
    });
  }

  Future<void> adicionarAdmin() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminFormPage()),
    );

    if (resultado == true) {
      carregarAdmins();
    }
  }

  Future<void> editarAdmin(Admin admin) async {
    try {
      final adminCompleto = await service.getAdminById(admin.id);

      if (!mounted) return;

      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminFormPage(admin: adminCompleto),
        ),
      );

      if (resultado == true) {
        carregarAdmins();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar admin: $e')));
    }
  }

  Future<void> confirmarExclusao(Admin admin) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir administrador'),
          content: Text('Deseja excluir o administrador ${admin.nome}?'),
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
        await service.deletarAdmin(admin.id);
        await carregarAdmins();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Administrador excluído com sucesso.')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administradores'),
        actions: [
          IconButton(
            onPressed: carregarAdmins,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarAdmin,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar administradores:\n$erro',
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
                      hintText: 'Buscar administrador...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: filtrarAdmins,
                  ),
                ),
                Expanded(
                  child: admins.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum administrador cadastrado.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : adminsFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum administrador encontrado na busca.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: adminsFiltrados.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final admin = adminsFiltrados[index];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  admin.nome.isNotEmpty
                                      ? admin.nome[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(admin.nome),
                              subtitle: Text(
                                [
                                  admin.cpf ?? '',
                                  admin.comumCompleta,
                                ].where((item) => item.trim().isNotEmpty).join(
                                  ' • ',
                                ),
                              ),
                              onTap: () => editarAdmin(admin),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => confirmarExclusao(admin),
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
