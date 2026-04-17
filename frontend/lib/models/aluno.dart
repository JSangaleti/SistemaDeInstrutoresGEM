class Aluno {
  final int id;
  final String nome;
  final String? comum;

  Aluno({
    required this.id,
    required this.nome,
    this.comum,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'] ?? '',
      comum: json['comum'],
    );
  }
}