class Aluno {
  final int id;
  final String nome;
  final String? cpf;
  final int? comumId;
  final String? comumNome;
  final String? comumCidade;
  final String? comumUF;

  Aluno({
    required this.id,
    required this.nome,
    this.cpf,
    this.comumId,
    this.comumNome,
    this.comumCidade,
    this.comumUF,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    final pessoa = json['pessoa'] is Map<String, dynamic>
        ? json['pessoa'] as Map<String, dynamic>
        : null;

    final comumDireta = json['comum'] is Map<String, dynamic>
        ? json['comum'] as Map<String, dynamic>
        : null;

    final comumPessoa =
        pessoa != null && pessoa['comum'] is Map<String, dynamic>
        ? pessoa['comum'] as Map<String, dynamic>
        : null;

    final comumObj = comumDireta ?? comumPessoa;

    String? comumNomeExtraida;

    if (json['comumNome'] != null) {
      comumNomeExtraida = json['comumNome'].toString();
    } else if (json['comum'] is String) {
      comumNomeExtraida = json['comum'].toString();
    } else if (comumObj != null && comumObj['nome'] != null) {
      comumNomeExtraida = comumObj['nome'].toString();
    }

    return Aluno(
      id: json['id'],
      nome: json['nome']?.toString() ?? pessoa?['nome']?.toString() ?? '',
      cpf: json['cpf']?.toString() ?? pessoa?['cpf']?.toString(),
      comumId: json['comumId'] ?? comumObj?['id'],
      comumNome: comumNomeExtraida,
      comumCidade:
          json['comumCidade']?.toString() ??
          json['cidade']?.toString() ??
          comumObj?['cidade']?.toString(),
      comumUF:
          json['comumUF']?.toString() ??
          json['uf']?.toString() ??
          json['estado']?.toString() ??
          json['comumEstado']?.toString() ??
          comumObj?['uf']?.toString() ??
          comumObj?['estado']?.toString(),
    );
  }

  String get comumCompleta {
    final partes = <String>[
      comumNome ?? '',
      comumCidade ?? '',
      comumUF ?? '',
    ].where((item) => item.trim().isNotEmpty).toList();

    return partes.isEmpty ? 'Sem comum' : partes.join(' - ');
  }
}
