class RegistroAula {
  final int id;
  final String? descricao;
  final int? presente;
  final DateTime? data;
  final int? alunoId;
  final String? alunoNome;
  final int? instrutorId;
  final String? instrutorNome;
  final String? paraProximaAula;

  RegistroAula({
    required this.id,
    this.descricao,
    this.presente,
    this.data,
    this.alunoId,
    this.alunoNome,
    this.instrutorId,
    this.instrutorNome,
    this.paraProximaAula,
  });

  factory RegistroAula.fromJson(Map<String, dynamic> json) {
    final aluno = json['aluno'] is Map<String, dynamic>
        ? json['aluno'] as Map<String, dynamic>
        : null;

    final instrutor = json['instrutor'] is Map<String, dynamic>
        ? json['instrutor'] as Map<String, dynamic>
        : null;

    final dataTexto = json['data']?.toString();

    return RegistroAula(
      id: json['id'],
      descricao: json['descricao']?.toString(),
      presente: json['presente'],
      data: dataTexto == null || dataTexto.isEmpty
          ? null
          : DateTime.tryParse(dataTexto),
      alunoId: json['alunoId'] ?? aluno?['id'],
      alunoNome: json['alunoNome']?.toString() ?? aluno?['nome']?.toString(),
      instrutorId: json['instrutorId'] ?? instrutor?['id'],
      instrutorNome:
          json['instrutorNome']?.toString() ?? instrutor?['nome']?.toString(),
      paraProximaAula: json['paraProximaAula']?.toString(),
    );
  }

  String get dataTexto {
    if (data == null) return 'Sem data';

    final dia = data!.day.toString().padLeft(2, '0');
    final mes = data!.month.toString().padLeft(2, '0');
    final ano = data!.year.toString();

    return '$dia/$mes/$ano';
  }

  String get dataApi {
    if (data == null) return '';

    final mes = data!.month.toString().padLeft(2, '0');
    final dia = data!.day.toString().padLeft(2, '0');

    return '${data!.year}-$mes-$dia';
  }

  String get alunoTexto {
    final nomeLimpo = alunoNome?.trim() ?? '';
    return nomeLimpo.isEmpty ? 'Sem aluno' : nomeLimpo;
  }

  String get instrutorTexto {
    final nomeLimpo = instrutorNome?.trim() ?? '';
    return nomeLimpo.isEmpty ? 'Sem instrutor' : nomeLimpo;
  }

  String get presencaTexto {
    if (presente == 1) return 'Presente';
    if (presente == 0) return 'Ausente';
    return 'Presença não informada';
  }
}
