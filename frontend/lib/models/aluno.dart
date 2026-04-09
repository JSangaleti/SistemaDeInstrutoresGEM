class Aluno {
  final int id;
  final String nome;
  final String? comum;

  Aluno({
    required this.id,
    required this.nome,
    this.comum,
  });
}