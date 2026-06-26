class Instrutor {
  final int id;
  final String nome;
  final String? cpf;
  final String? senha;
  final int? comumId;
  final String? comum;
  final String? comumCidade;
  final String? comumEstado;

  Instrutor({
    required this.id,
    required this.nome,
    this.cpf,
    this.senha,
    this.comumId,
    this.comum,
    this.comumCidade,
    this.comumEstado,
  });

  factory Instrutor.fromJson(Map<String, dynamic> json) {
    final pessoa = json['pessoa'] as Map<String, dynamic>?;
    final comumDaPessoa = pessoa?['comum'] as Map<String, dynamic>?;

    return Instrutor(
      id: json['id'],
      nome: pessoa?['nome'] ?? json['nome'] ?? '',
      cpf: pessoa?['cpf'] ?? json['cpf'],
      senha: json['senha'],
      comumId: comumDaPessoa?['id'] ?? json['comumId'],
      comum: comumDaPessoa?['nome'] ?? json['comum'],
      comumCidade: comumDaPessoa?['cidade'] ?? json['comumCidade'],
      comumEstado:
          comumDaPessoa?['estado'] ?? json['comumUF'] ?? json['comumEstado'],
    );
  }

  String get comumCompleta {
    final partes = <String>[
      comum ?? '',
      comumCidade ?? '',
      comumEstado ?? '',
    ].where((item) => item.trim().isNotEmpty).toList();

    return partes.isEmpty ? 'Sem comum' : partes.join(' - ');
  }
}
