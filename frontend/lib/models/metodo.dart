class Metodo {
  final int id;
  final String nome;
  final int? instrumentoId;
  final String? instrumentoNome;

  Metodo({
    required this.id,
    required this.nome,
    this.instrumentoId,
    this.instrumentoNome,
  });

  factory Metodo.fromJson(Map<String, dynamic> json) {
    final instrumento = json['instrumento'] is Map<String, dynamic>
        ? json['instrumento'] as Map<String, dynamic>
        : null;

    return Metodo(
      id: json['id'],
      nome: json['nome']?.toString() ?? '',
      instrumentoId: json['instrumentoId'] ?? instrumento?['id'],
      instrumentoNome: json['instrumentoNome']?.toString() ??
          instrumento?['nome']?.toString(),
    );
  }

  String get instrumentoTexto {
    final nomeLimpo = instrumentoNome?.trim() ?? '';
    return nomeLimpo.isEmpty ? 'Sem instrumento' : nomeLimpo;
  }
}
