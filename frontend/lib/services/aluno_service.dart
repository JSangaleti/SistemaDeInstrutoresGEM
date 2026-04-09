import '../models/aluno.dart';

class AlunoService {
  List<Aluno> getAlunos() {
    return [
      Aluno(
        id: 1,
        nome: 'Maria',
        comum: 'Centro',
      ),
      Aluno(
        id: 2,
        nome: 'João',
        comum: 'Bairro São José',
      ),
    ];
  }
}