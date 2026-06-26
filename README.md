# Sistema de Gestão de Instrutores e Alunos do GEM

Sistema desenvolvido para a disciplina de Projeto Integrador, com o objetivo de auxiliar no controle de instrutores, alunos, aulas e acompanhamento de progresso do Grupo de Estudos Musicais (GEM).

A proposta do sistema é centralizar informações acadêmicas e administrativas do GEM, facilitando o cadastro de pessoas, comuns/congregações, alunos, instrutores, instrumentos, métodos e registros de aula.

## Visão geral

O sistema é composto por:

* **Backend:** API em Java com Spring Boot.
* **Frontend:** aplicação em Flutter Web.
* **Banco de dados:** PostgreSQL.
* **Ambiente de execução:** Docker e Docker Compose.

Com Docker, o sistema completo pode ser executado com um único comando.

## Funcionalidades principais

O sistema possui três perfis de acesso:

### Administrador

* Acessa a área administrativa.
* Gerencia cadastros de:

  * alunos;
  * pessoas;
  * comuns/congregações;
  * instrutores;
  * instrumentos;
  * métodos;
  * registros de aula.
* Visualiza resumo geral do sistema.
* Utiliza ações rápidas para navegação e cadastro.
* Possui botão de logout.

### Instrutor

* Acessa a área do instrutor.
* Registra aulas dos alunos.
* Consulta histórico de aulas registradas.
* Pesquisa alunos por nome ou CPF.
* Filtra alunos por comum/local ao registrar aula.
* Visualiza registros ordenados do mais recente para o mais antigo.
* Possui botão de logout.

### Aluno

* Acessa apenas sua própria área.
* Visualiza:

  * meu perfil;
  * meu histórico de aulas.
* Não acessa listagem geral de alunos.
* Não seleciona nem visualiza dados de outros alunos pela interface.
* Possui botão de logout.

## Tecnologias utilizadas

* Java 21
* Spring Boot
* Spring Security
* Spring Data JPA
* PostgreSQL
* Flutter
* Dart
* Docker
* Docker Compose
* Nginx

## Requisitos

Para executar o projeto completo, é necessário ter instalado:

* Git
* Docker
* Docker Compose

Não é necessário instalar Java, Maven, Flutter ou PostgreSQL diretamente na máquina para executar o projeto via Docker.

## Como clonar o projeto

```bash
git clone https://github.com/JSangaleti/SistemaDeInstrutoresGEM.git
cd SistemaDeInstrutoresGEM
```

Caso esteja trabalhando na branch de desenvolvimento:

```bash
git switch develop
```

## Configuração das variáveis de ambiente

Antes de executar o projeto, crie um arquivo `.env` na raiz do repositório com base no `.env.example`:

```bash
cp .env.example .env
```

Exemplo de configuração:

```env
DB_HOST=postgres
DB_PORT=5432
DB_NAME=gem_db
DB_USER=gem_user
DB_PASSWORD=123456
```

Essas variáveis são utilizadas pelo Docker Compose para configurar o banco PostgreSQL e a conexão do backend.

> Observação: dentro do Docker, o backend acessa o PostgreSQL pela porta interna `5432`. No computador local, o banco pode estar mapeado para a porta `5433` para evitar conflito com outros projetos que usam PostgreSQL.

## Como executar o projeto com Docker

Na raiz do projeto, execute:

```bash
docker compose up --build
```

Esse comando irá:

* criar e executar o container do PostgreSQL;
* construir e executar o backend Spring Boot;
* construir o frontend Flutter Web;
* servir o frontend com Nginx;
* conectar o backend ao banco de dados;
* executar a seed automática de desenvolvimento, caso o banco ainda esteja vazio.

Após a inicialização, acesse:

```text
Frontend: http://localhost:3000
Backend:  http://localhost:8080
```

## Como parar o projeto

Para parar os containers:

```bash
docker compose down
```

Para parar os containers e apagar também o volume do banco de dados:

```bash
docker compose down -v
```

Atenção: `docker compose down -v` remove os dados locais do banco. Use apenas quando quiser recriar o banco do zero.

## Como recriar o projeto do zero

Caso queira apagar o banco local e rodar a seed novamente:

```bash
docker compose down -v --remove-orphans
docker compose up --build
```

## Seed do banco de dados

O backend executa uma seed automática em ambiente de desenvolvimento.

A seed insere dados iniciais para testes, como:

* comuns;
* pessoas;
* alunos;
* instrutores;
* administrador;
* instrumentos;
* métodos;
* registros de aula.

Caso o banco já possua dados, a seed não insere registros novamente.

## Usuários de teste

Após executar a seed, é possível acessar o sistema com os seguintes usuários:

### Administrador

```text
CPF: 00000000001
Senha: admin123
Perfil: ADMIN
```

### Aluno

```text
CPF: 11111111111
Senha: senha123
Perfil: ALUNO
```

### Instrutor

```text
CPF: 44444444444
Senha: senha123
Perfil: INSTRUTOR
```

## Autenticação

O sistema utiliza autenticação via JWT.

O login é feito pelo frontend informando:

* CPF;
* senha;
* perfil.

Após o login, o backend retorna:

* token;
* perfil;
* usuarioId;
* nome;
* CPF.

O token é enviado nas requisições autenticadas por meio do header:

```text
Authorization: Bearer <token>
```

## Endpoints básicos

Com o projeto em execução, alguns endpoints disponíveis no backend são:

```text
POST http://localhost:8080/auth/login

GET  http://localhost:8080/comuns
GET  http://localhost:8080/pessoas
GET  http://localhost:8080/alunos
GET  http://localhost:8080/instrutores
GET  http://localhost:8080/instrumentos
GET  http://localhost:8080/metodos
GET  http://localhost:8080/registro-aulas
GET  http://localhost:8080/admins
```

Endpoints específicos da área do aluno:

```text
GET http://localhost:8080/alunos/me
GET http://localhost:8080/registro-aulas/meu-historico
```

Esses endpoints retornam apenas os dados do aluno autenticado.

## Exemplo de login com curl

```bash
curl -i -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"cpf":"00000000001","senha":"admin123","perfil":"ADMIN"}'
```

## Exemplo de requisição autenticada

Depois de obter o token no login:

```bash
curl -i http://localhost:8080/alunos \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## Testes e validações

### Backend

```bash
cd backend
./mvnw test
```

### Frontend

```bash
cd frontend
flutter pub get
flutter analyze
flutter test
```

### Docker

Na raiz do projeto:

```bash
docker compose down --remove-orphans
docker compose build --no-cache backend frontend
docker compose up --force-recreate
```

## Estrutura do projeto

```text
SistemaDeInstrutoresGEM/
├── backend/                # API Java com Spring Boot
├── frontend/               # Aplicação Flutter Web
├── docker-compose.yml      # Serviços do PostgreSQL, backend e frontend
├── .env.example            # Exemplo de variáveis de ambiente
└── README.md               # Documentação principal do projeto
```

## Documentação específica

As instruções de execução manual e detalhes específicos de cada aplicação ficam nos READMEs internos:

```text
backend/README.md
frontend/README.md
```

## Fluxo de desenvolvimento

O desenvolvimento principal do projeto é realizado na branch `develop`.

Fluxo recomendado:

```bash
git switch develop
git pull origin develop
git switch -c nome-da-branch-da-issue
```

Após concluir a implementação:

```bash
git add .
git commit -m "tipo: descrição da alteração"
git push -u origin nome-da-branch-da-issue
```

Em seguida, abra um Pull Request para a branch `develop`.

## Comandos úteis

Ver containers em execução:

```bash
docker compose ps
```

Ver logs do backend:

```bash
docker compose logs backend --tail=200
```

Ver logs do frontend:

```bash
docker compose logs frontend --tail=200
```

Ver logs em tempo real:

```bash
docker compose logs -f
```

Recriar containers sem apagar o banco:

```bash
docker compose down --remove-orphans
docker compose up --build
```

Recriar containers apagando o banco:

```bash
docker compose down -v --remove-orphans
docker compose up --build
```

## Observações importantes

* O arquivo `.env` não deve ser versionado.
* O arquivo `.env.example` deve ser mantido atualizado.
* O banco de dados local é persistido em um volume Docker.
* Para recriar o banco do zero, utilize `docker compose down -v`.
* O frontend dockerizado é servido na porta `3000`.
* O backend é servido na porta `8080`.
* O PostgreSQL pode ser acessado pela máquina local na porta `5433`, caso esteja configurado assim no `docker-compose.yml`.
* A comunicação interna entre backend e banco continua usando `postgres:5432`.
* A área do aluno deve permanecer restrita ao perfil e histórico do aluno autenticado.
* A branch `main` deve ser reservada para integrações finais ou entregas consolidadas do projeto.
