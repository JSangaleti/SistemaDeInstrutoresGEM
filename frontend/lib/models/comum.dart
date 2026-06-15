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
      nome: json['nome']?.toString() ?? '',
      cidade: json['cidade']?.toString(),
      estado: json['estado']?.toString(),
      bairro: json['bairro']?.toString(),
    );
  }

  String get nomeCompleto {
    final partes = <String>[
      nome,
      cidade ?? '',
      estado ?? '',
    ].where((item) => item.trim().isNotEmpty).toList();

    return partes.join(' - ');
  }
}
