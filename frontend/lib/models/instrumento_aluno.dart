class InstrumentoAluno {
  final int id;
  final String nome;
  final bool principal;

  InstrumentoAluno({
    required this.id,
    required this.nome,
    required this.principal,
  });

  factory InstrumentoAluno.fromJson(Map<String, dynamic> json) {
    return InstrumentoAluno(
      id: json['id'],
      nome: json['nome']?.toString() ?? '',
      principal: json['principal'] == true,
    );
  }
}
