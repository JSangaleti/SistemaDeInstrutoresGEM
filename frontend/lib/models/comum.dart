class Comum {
  final int id;
  final String nome;
  final String? cidade;
  final String? estado;
  final String? bairro;

  Comum({
    required this.id,
    required this.nome,
    this.cidade,
    this.estado,
    this.bairro,
  });

  factory Comum.fromJson(Map<String, dynamic> json) {
    return Comum(
      id: json['id'],
      nome: json['nome'] ?? '',
      cidade: json['cidade'],
      estado: json['estado'],
      bairro: json['bairro'],
    );
  }
}