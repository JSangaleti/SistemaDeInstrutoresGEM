# Sistema de Gestão de Instrutores e Alunos do GEM

Sistema desenvolvido para a disciplina de Projeto Integrador, com o objetivo de auxiliar no controle de instrutores, alunos, aulas e acompanhamento de progresso do Grupo de Estudos Musicais (GEM).

A proposta do sistema é centralizar informações acadêmicas e administrativas do GEM, facilitando o cadastro de pessoas, comuns/congregações, alunos, instrutores, instrumentos, métodos e registros de aula.

## Visão geral

O sistema é composto por:

- **Backend:** API em Java com Spring Boot.
- **Frontend:** aplicação em Flutter Web.
- **Banco de dados:** PostgreSQL.
- **Ambiente de execução:** Docker e Docker Compose.

Com Docker, o sistema completo pode ser executado com um único comando.

## Tecnologias utilizadas

- Java
- Spring Boot
- Spring Data JPA
- PostgreSQL
- Flutter
- Dart
- Docker
- Docker Compose
- Nginx

## Requisitos

Para executar o projeto completo, é necessário ter instalado:

- Git
- Docker
- Docker Compose

> Não é necessário instalar Java, Maven, Flutter ou PostgreSQL diretamente na máquina para executar o projeto via Docker.

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

## Como executar o projeto com Docker

Na raiz do projeto, execute:

```bash
docker compose up --build
```

Esse comando irá:

- criar e executar o container do PostgreSQL;
- construir e executar o backend Spring Boot;
- construir o frontend Flutter Web;
- servir o frontend com Nginx;
- conectar o backend ao banco de dados;
- executar a seed automática de desenvolvimento, caso o banco ainda esteja vazio.

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

> Atenção: `docker compose down -v` remove os dados locais do banco. Use apenas quando quiser recriar o banco do zero.

## Seed do banco de dados

O backend executa uma seed automática em ambiente de desenvolvimento.

A seed insere dados iniciais para testes, como:

- comuns;
- pessoas;
- alunos;
- instrutores;
- administrador;
- instrumentos;
- métodos;
- registros de aula.

Caso o banco já possua dados, a seed não insere registros novamente.

Para recriar o banco e executar a seed do zero:

```bash
docker compose down -v
docker compose up --build
```

## Endpoints básicos para teste

Com o projeto em execução, alguns endpoints disponíveis no backend são:

```text
GET http://localhost:8080/comuns
GET http://localhost:8080/pessoas
GET http://localhost:8080/alunos
GET http://localhost:8080/instrutores
GET http://localhost:8080/instrumentos
GET http://localhost:8080/metodos
GET http://localhost:8080/registro-aulas
GET http://localhost:8080/admins
```

Exemplo com `curl`:

```bash
curl http://localhost:8080/alunos
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

## Observações importantes

- O arquivo `.env` não deve ser versionado.
- O arquivo `.env.example` deve ser mantido atualizado.
- O banco de dados local é persistido em um volume Docker.
- Para recriar o banco do zero, utilize `docker compose down -v`.
- O frontend dockerizado é servido na porta `3000`.
- O backend é servido na porta `8080`.
- A branch `main` deve ser reservada para integrações finais ou entregas consolidadas do projeto.
