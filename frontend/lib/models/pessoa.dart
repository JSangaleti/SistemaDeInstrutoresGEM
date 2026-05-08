class Pessoa {
  final String cpf;
  final String nome;

  final int? comumId;
  final String? comumNome;
  final String? comumCidade;
  final String? comumUF;

  Pessoa({
    required this.cpf,
    required this.nome,
    this.comumId,
    this.comumNome,
    this.comumCidade,
    this.comumUF,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    final comumObj = json['comum'] is Map<String, dynamic>
        ? json['comum'] as Map<String, dynamic>
        : null;

    String? comumNomeExtraida;

    if (json['comumNome'] != null) {
      comumNomeExtraida = json['comumNome'].toString();
    } else if (json['comum'] is String) {
      comumNomeExtraida = json['comum'].toString();
    } else if (comumObj != null && comumObj['nome'] != null) {
      comumNomeExtraida = comumObj['nome'].toString();
    }

    return Pessoa(
      cpf: json['cpf']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      comumId: json['comumId'] ?? comumObj?['id'],
      comumNome: comumNomeExtraida,
      comumCidade: json['comumCidade']?.toString() ??
          json['cidade']?.toString() ??
          comumObj?['cidade']?.toString(),
      comumUF: json['comumUF']?.toString() ??
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