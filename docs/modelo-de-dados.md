# Modelo de Dados

## 1. Visão geral

O banco de dados do sistema foi modelado para representar os principais elementos do domínio do GEM, incluindo pessoas, instrutores, administradores, alunos, comuns congregações, instrumentos, métodos e aulas.

A modelagem atual busca atender ao controle cadastral e ao registro básico de aulas, servindo como base inicial para a evolução do sistema.

---

## 2. Entidades do sistema

### 2.1 Pessoa

Representa uma pessoa cadastrada no sistema, contendo dados básicos de autenticação e vínculo com a comum congregação.

**Atributos:**
- `cpf`
- `id_comum`
- `nome`
- `usuario`
- `senha`

**Observação:**
A entidade `pessoa` serve de base para os perfis de administrador e instrutor.

---

### 2.2 Admin

Representa um usuário com permissões administrativas no sistema.

**Atributos:**
- `cpf_pessoa`

**Relacionamento:**
- cada administrador está vinculado a uma pessoa cadastrada no sistema.

---

### 2.3 Instrutor

Representa um instrutor do GEM.

**Atributos:**
- `cpf_pessoa`

**Relacionamento:**
- cada instrutor está vinculado a uma pessoa cadastrada no sistema.

---

### 2.4 Aluno

Representa um aluno cadastrado no sistema.

**Atributos:**
- `id`
- `id_instrumento`
- `id_metodo`
- `id_comum`
- `nome`

**Relacionamentos:**
- um aluno está vinculado a uma comum congregação;
- um aluno possui um instrumento associado;
- um aluno possui um método associado.

**Observação:**
Na modelagem atual, o aluno não está vinculado diretamente à entidade `pessoa`, diferentemente de instrutores e administradores.

---

### 2.5 Comum

Representa a comum congregação associada ao aluno ou à pessoa.

**Atributos:**
- `id`
- `sigla`
- `endereco`
- `nome`

**Relacionamentos:**
- uma comum pertence a um estado;
- uma comum pode estar associada a várias pessoas e alunos.

---

### 2.6 Estado

Representa o estado ao qual uma comum congregação pertence.

**Atributos:**
- `sigla`
- `estado`

---

### 2.7 Instrumento

Representa o instrumento estudado pelo aluno.

**Atributos:**
- `id`
- `nome`

---

### 2.8 Metodo

Representa o método de estudo associado ao aluno.

**Atributos:**
- `id`
- `nome`

---

### 2.9 Aula

Representa um registro de aula ministrada por um instrutor para um aluno.

**Atributos:**
- `id`
- `cpf_instrutor`
- `id_aluno`
- `data`
- `descricao`
- `presenca`

**Relacionamentos:**
- uma aula está vinculada a um instrutor;
- uma aula está vinculada a um aluno.

**Observação:**
Na modelagem atual, a tabela `aula` concentra tanto os dados da aula quanto a presença do aluno, o que indica uma relação direta entre aula e aluno.

---

## 3. Relacionamentos principais

- uma **pessoa** pode estar vinculada a uma **comum**;
- um **administrador** referencia uma **pessoa**;
- um **instrutor** referencia uma **pessoa**;
- um **aluno** referencia uma **comum**;
- um **aluno** referencia um **instrumento**;
- um **aluno** referencia um **método**;
- uma **comum** referencia um **estado**;
- uma **aula** referencia um **instrutor**;
- uma **aula** referencia um **aluno**.

---

## 4. Análise da modelagem atual

A modelagem atual atende parcialmente ao domínio do sistema e já apresenta os principais elementos necessários para o cadastro e controle básico do GEM. Entretanto, alguns pontos podem ser melhorados para representar de forma mais fiel o funcionamento real do sistema.

### 4.1 Pontos positivos
- separação entre pessoa, instrutor e administrador;
- existência das entidades principais do domínio;
- uso de chaves estrangeiras para garantir relacionamento entre tabelas.

### 4.2 Limitações identificadas

#### a) Aluno não vinculado à entidade Pessoa
Atualmente, o aluno possui dados próprios e não herda da entidade `pessoa`, o que torna a modelagem inconsistente em relação a instrutores e administradores.

#### b) Aula vinculada diretamente a um único aluno
A tabela `aula` associa diretamente um aluno à aula e registra a presença no mesmo registro. Isso dificulta a expansão do sistema caso uma aula envolva mais de um aluno ou seja necessário armazenar avaliações e atividades por aluno.

#### c) Ausência de histórico de progresso
A modelagem atual associa apenas um método ao aluno, mas não mantém histórico de evolução, conteúdo estudado, hinos praticados ou mudanças de classificação.

#### d) Ausência de classificação do aluno
A classificação do aluno, prevista nos requisitos do sistema, ainda não aparece explicitamente no modelo atual.

#### e) Falta de atributos relevantes
Ainda não foram incluídos alguns atributos importantes para o domínio, como data de ingresso, idade, instrumento de oficialização do instrutor e informações mais completas para acompanhamento do aluno.

---

## 5. Sugestões de evolução

Para aproximar melhor o modelo do funcionamento real do GEM, recomenda-se considerar as seguintes melhorias:

- vincular `aluno` à entidade `pessoa`, caso o aluno também deva ser tratado como uma pessoa do sistema;
- separar o conceito de `aula` do conceito de `participação do aluno na aula`;
- criar uma entidade para histórico ou progresso do aluno;
- incluir classificação do aluno no banco de dados;
- ampliar os atributos cadastrais de aluno e instrutor.

Uma possível evolução seria incluir entidades como:

- `participacao_aula`
- `progresso_aluno`
- `classificacao`

---

## 6. Considerações finais

O modelo atual representa uma boa base inicial para o projeto, mas ainda precisa de ajustes para atender com mais fidelidade às funcionalidades previstas e ao domínio real do GEM. As principais melhorias recomendadas envolvem a representação do histórico do aluno, a separação adequada entre aula e presença, e a padronização da estrutura cadastral entre os diferentes tipos de pessoa do sistema.