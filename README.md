# Sistema de Gestão de Instrutores e Alunos do GEM

Sistema desenvolvido para a disciplina de Projeto Integrador, com o objetivo de auxiliar no controle de instrutores, alunos, aulas e acompanhamento de progresso do Grupo de Estudos Musicais (GEM).

A proposta do sistema é centralizar informações acadêmicas e administrativas do GEM, facilitando o cadastro de pessoas, comuns congregações, alunos e demais dados necessários para o acompanhamento das atividades musicais.

## Visão geral

O sistema está sendo desenvolvido em uma arquitetura com backend, frontend e banco de dados separados:

* **Backend:** API desenvolvida em Java com Spring Boot.
* **Frontend:** aplicação desenvolvida em Flutter.
* **Banco de dados:** PostgreSQL.
* **Ambiente de execução:** Docker e Docker Compose.

No estágio atual do desenvolvimento, o backend já possui estrutura para persistência de dados com JPA, conexão com PostgreSQL e seed automática em ambiente de desenvolvimento.

## Tecnologias utilizadas

* Java
* Spring Boot
* Spring Data JPA
* PostgreSQL
* Docker
* Docker Compose
* Flutter
* Dart

## Requisitos

Para executar o projeto, é necessário ter instalado:

* Git
* Docker
* Docker Compose
* Flutter SDK
* Google Chrome, caso deseje executar o frontend no navegador

> Observação: para executar o backend via Docker, não é necessário instalar Java ou Maven diretamente na máquina, pois o backend é construído dentro do container.

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

Antes de executar o projeto, crie um arquivo `.env` na raiz do repositório com base no arquivo `.env.example`:

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

Essas variáveis são utilizadas pelo Docker Compose para criar o banco PostgreSQL e configurar a conexão do backend com o banco de dados.

## Como executar o backend e o banco de dados

Na raiz do projeto, execute:

```bash
docker compose up --build
```

Esse comando irá:

* criar o container do PostgreSQL;
* construir a imagem do backend;
* executar a API Spring Boot;
* conectar o backend ao banco de dados;
* executar a seed automática de desenvolvimento, caso o banco ainda não possua dados.

A API ficará disponível em:

```text
http://localhost:8080
```

## Seed do banco de dados

O projeto possui uma seed automática para facilitar os testes durante o desenvolvimento.

Essa seed é executada quando o backend sobe com o perfil de desenvolvimento ativo:

```env
SPRING_PROFILES_ACTIVE=dev
```

No Docker Compose, esse perfil já é configurado no serviço do backend.

A seed insere dados iniciais para testes, como comuns, pessoas e alunos. Caso o banco já possua dados, a seed não insere registros novamente, evitando duplicações.

Para apagar os dados e testar a seed novamente do zero, execute:

```bash
docker compose down -v
docker compose up --build
```

> Atenção: o comando `docker compose down -v` remove também o volume do banco de dados. Use apenas quando quiser limpar os dados locais de desenvolvimento.

## Endpoints básicos para teste

Com o backend em execução, alguns endpoints disponíveis são:

```text
GET http://localhost:8080/comuns
GET http://localhost:8080/pessoas
GET http://localhost:8080/alunos
```

Esses endpoints podem ser testados pelo navegador, por ferramentas como Postman/Insomnia ou por terminal com `curl`.

Exemplo:

```bash
curl http://localhost:8080/alunos
```

## Como executar o frontend

Em outro terminal, acesse a pasta do frontend:

```bash
cd frontend
```

Instale as dependências do Flutter:

```bash
flutter pub get
```

Execute a aplicação no Chrome:

```bash
flutter run -d chrome
```

O Flutter abrirá uma janela do navegador com a aplicação em execução.

## Estrutura do projeto

```text
SistemaDeInstrutoresGEM/
├── backend/              # API Java com Spring Boot
├── frontend/             # Aplicação Flutter
├── docker-compose.yml    # Serviços do PostgreSQL e backend
├── .env.example          # Exemplo de variáveis de ambiente
└── README.md             # Documentação principal do projeto
```

## Fluxo de desenvolvimento

O desenvolvimento principal do projeto é realizado na branch `develop`.

De forma geral, o fluxo recomendado é:

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

* O arquivo `.env` não deve ser versionado.
* O arquivo `.env.example` deve ser mantido atualizado com as variáveis necessárias.
* O banco de dados local é persistido em um volume Docker.
* Para recriar o banco do zero, utilize `docker compose down -v`.
* A branch `main` deve ser reservada para integrações finais ou entregas consolidadas do projeto.
