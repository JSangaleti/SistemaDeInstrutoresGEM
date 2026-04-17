class Comum {
  final int id;
  final String nome;

  Comum({
    required this.id,
    required this.nome,
  });

  factory Comum.fromJson(Map<String, dynamic> json) {
    return Comum(
      id: json['id'],
      nome: json['nome'] ?? '',
    );
  }
}