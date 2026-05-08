class Aluno {
  final int id;
  final String nome;
  final String? comum;
  final String? cpf;
  final String? senha;
  final int? comumId;

  Aluno({
    required this.id,
    required this.nome,
    this.comum,
    this.cpf,
    this.senha,
    this.comumId,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'] ?? '',
      comum: json['comum'],
      cpf: json['cpf'],
      senha: json['senha'],
      comumId: json['comumId'],
    );
  }
}