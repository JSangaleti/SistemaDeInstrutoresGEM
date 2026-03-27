# Modelo de Dados

## 1. Visão geral

O sistema é composto por entidades que representam usuários, alunos, instrutores, comuns congregações, aulas, presenças e progresso acadêmico.

## 2. Entidades principais

## 2.1 Usuário

Representa a conta de acesso ao sistema.

### Atributos sugeridos
- id
- nome
- email
- senha
- perfil
- ativo

## 2.2 ComumCongregacao

Representa a identificação da comum congregação.

### Atributos sugeridos
- id
- nome
- cidade
- estado
- bairro

## 2.3 Aluno

Representa o aluno cadastrado no sistema.

### Atributos sugeridos
- id
- nome
- idade
- instrumento
- data_ingresso
- classificacao
- comum_congregacao_id
- usuario_id

## 2.4 Instrutor

Representa o instrutor cadastrado no sistema.

### Atributos sugeridos
- id
- nome
- idade
- instrumento_oficializacao
- comum_congregacao_id
- usuario_id

## 2.5 Aula

Representa uma aula ministrada por um instrutor.

### Atributos sugeridos
- id
- data_aula
- conteudo
- observacoes
- instrutor_id

## 2.6 ParticipacaoAula

Representa a participação do aluno em uma aula.

### Atributos sugeridos
- id
- aula_id
- aluno_id
- presente
- avaliacao
- proximas_atividades

## 2.7 ProgressoAluno

Representa o progresso acadêmico ou musical do aluno.

### Atributos sugeridos
- id
- aluno_id
- tipo_conteudo
- descricao
- status
- data_registro
- observacao

## 3. Relacionamentos

- Um **usuário** possui um **perfil**.
- Um **aluno** pode estar vinculado a um **usuário**.
- Um **instrutor** pode estar vinculado a um **usuário**.
- Uma **comum congregação** pode possuir vários **alunos**.
- Uma **comum congregação** pode possuir vários **instrutores**.
- Um **instrutor** pode ministrar várias **aulas**.
- Uma **aula** possui um único **instrutor responsável**.
- Um **aluno** pode participar de várias **aulas**.
- Uma **aula** pode possuir vários **alunos participantes**.
- Um **aluno** pode possuir vários registros de **progresso**.

## 4. Observações de modelagem

- A entidade `ParticipacaoAula` resolve o relacionamento muitos-para-muitos entre `Aluno` e `Aula`.
- A entidade `ProgressoAluno` permite manter histórico em vez de sobrescrever informações anteriores.
- O vínculo entre `Usuário` e `Aluno` ou `Instrutor` pode ser opcional, dependendo da decisão do grupo sobre acesso individual ao sistema.

## 5. Modelo conceitual resumido

- Usuário
- Aluno
- Instrutor
- ComumCongregacao
- Aula
- ParticipacaoAula
- ProgressoAluno