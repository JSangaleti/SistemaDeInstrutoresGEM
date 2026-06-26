class Admin {
  final int id;
  final String nome;
  final String? cpf;
  final String? comum;

  Admin({
    required this.id,
    required this.nome,
    this.cpf,
    this.comum,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      nome: json['nome']?.toString() ?? '',
      cpf: json['cpf']?.toString(),
      comum: json['comum']?.toString(),
    );
  }

  String get comumCompleta {
    final valor = comum?.trim() ?? '';
    return valor.isEmpty ? 'Sem comum' : valor;
  }
}
