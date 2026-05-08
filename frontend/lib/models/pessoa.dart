class Pessoa {
  final String cpf;
  final String nome;
  final String? comum;

  Pessoa({
    required this.cpf,
    required this.nome,
    this.comum,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      cpf: json['cpf'],
      nome: json['nome'] ?? '',
      comum: json['comum'],
    );
  }
}