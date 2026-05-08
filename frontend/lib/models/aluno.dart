class Aluno {
  final int id;
  final String nome;
  final String? cpf;
  final int? comumId;
  final String? comumNome;
  final String? comumUF;
  final String? comumCidade;
  final String? comumEstado;

  Aluno({
    required this.id,
    required this.nome,
    this.cpf,
    this.comumId,
    this.comumNome,
    this.comumUF,
    this.comumCidade,
    this.comumEstado,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    final pessoa = json['pessoa'] is Map<String, dynamic>
        ? json['pessoa'] as Map<String, dynamic>
        : null;

    final comumDireta = json['comum'] is Map<String, dynamic>
        ? json['comum'] as Map<String, dynamic>
        : null;

    final comumPessoa = pessoa != null && pessoa['comum'] is Map<String, dynamic>
        ? pessoa['comum'] as Map<String, dynamic>
        : null;

    final comumObj = comumDireta ?? comumPessoa;

    String? comumNomeExtraida;

    if (json['comumNome'] != null) {
      comumNomeExtraida = json['comumNome'];
    } else if (json['comum'] is String) {
      comumNomeExtraida = json['comum'];
    } else {
      comumNomeExtraida = comumObj?['nome'];
    }

    return Aluno(
      id: json['id'],
      nome: json['nome'] ?? pessoa?['nome'] ?? '',
      cpf: json['cpf'] ?? pessoa?['cpf'],
      comumId: json['comumId'] ?? comumObj?['id'],
      comumNome: comumNomeExtraida,
      comumCidade: json['comumCidade'] ?? json['cidade'] ?? comumObj?['cidade'],
      comumUF: json['comumUF'] ??
          json['uf'] ??
          json['estado'] ??
          json['comumEstado'] ??
          comumObj?['uf'] ??
          comumObj?['estado'],
      comumEstado: json['comumEstado'] ??
          json['estado'] ??
          json['comumUF'] ??
          json['uf'] ??
          comumObj?['estado'] ??
          comumObj?['uf'],
    );
  }

  String get comumCompleta {
    final partes = <String>[
      comumNome ?? '',
      comumCidade ?? '',
      comumEstado ?? comumUF ?? '',
    ].where((item) => item.trim().isNotEmpty).toList();

    return partes.isEmpty ? 'Sem comum' : partes.join(' - ');
  }
}