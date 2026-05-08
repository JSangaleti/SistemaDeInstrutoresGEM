# Backend

Este diretório contém o backend do Sistema de Gestão de Instrutores e Alunos do GEM.

A API foi desenvolvida em Java com Spring Boot e utiliza PostgreSQL como banco de dados. O backend está preparado para ser executado com Docker, junto com o banco de dados, a partir do `docker-compose.yml` localizado na raiz do repositório.

## Tecnologias utilizadas

* Java
* Spring Boot
* Spring Data JPA
* PostgreSQL
* Docker
* Docker Compose
* Maven Wrapper

## Requisitos

Para executar o backend da forma recomendada, é necessário ter instalado:

* Docker
* Docker Compose

> Não é necessário instalar Java ou Maven localmente para executar via Docker, pois a aplicação é construída dentro do container.

## Configuração do ambiente

Antes de subir o backend, crie um arquivo `.env` na raiz do repositório com base no arquivo `.env.example`:

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

Essas variáveis são usadas pelo Docker Compose para configurar o banco PostgreSQL e a conexão do backend.

## Como executar

A execução deve ser feita pela raiz do repositório, pois o `docker-compose.yml` principal está fora da pasta `backend`.

Na raiz do projeto, execute:

```bash
docker compose up --build
```

Esse comando irá:

* criar o serviço do PostgreSQL;
* construir a imagem Docker do backend;
* executar a aplicação Spring Boot;
* conectar o backend ao banco de dados;
* disponibilizar a API na porta `8080`.

Após a inicialização, a API estará disponível em:

```text
http://localhost:8080
```

## Seed de desenvolvimento

O ambiente de desenvolvimento utiliza o perfil:

```env
SPRING_PROFILES_ACTIVE=dev
```

Esse perfil é definido no serviço do backend dentro do `docker-compose.yml`.

Quando o backend é iniciado nesse perfil, a seed de desenvolvimento pode popular o banco automaticamente com dados iniciais para teste, como comuns, pessoas e alunos.

Caso o banco já possua dados, a seed não deve inserir registros novamente, evitando duplicações.

Para apagar o banco local e testar a seed do zero:

```bash
docker compose down -v
docker compose up --build
```

> Atenção: `docker compose down -v` remove o volume do banco de dados. Use apenas quando quiser limpar os dados locais.

## Endpoints básicos

Com a aplicação em execução, alguns endpoints disponíveis para teste são:

```text
GET /comuns
GET /pessoas
GET /alunos
```

Exemplos com `curl`:

```bash
curl http://localhost:8080/comuns
curl http://localhost:8080/pessoas
curl http://localhost:8080/alunos
```

## Execução local sem Docker

A execução local diretamente pela pasta `backend` não é o fluxo principal do projeto.

Caso deseje executar sem Docker, será necessário ter:

* Java compatível com a versão configurada no projeto;
* PostgreSQL acessível pela máquina local;
* variáveis de ambiente configuradas corretamente.

Também é importante observar que, no Docker Compose atual, o PostgreSQL é usado internamente pelos containers. Portanto, para rodar o backend fora do Docker usando o banco do container, pode ser necessário expor a porta do PostgreSQL no `docker-compose.yml` ou utilizar uma instalação local do PostgreSQL.

Com o ambiente configurado, o backend pode ser iniciado com:

```bash
cd backend
./mvnw spring-boot:run
```

## Estrutura principal

```text
backend/
├── src/
│   ├── main/
│   │   ├── java/com/gem/backend/
│   │   │   ├── config/        # Configurações da aplicação
│   │   │   ├── controller/    # Controllers REST
│   │   │   ├── dto/           # Objetos de transferência de dados
│   │   │   ├── model/         # Entidades JPA
│   │   │   ├── repository/    # Repositórios Spring Data JPA
│   │   │   └── service/       # Regras de serviço
│   │   └── resources/         # Configurações da aplicação
│   └── test/                  # Testes automatizados
├── Dockerfile                 # Build Docker do backend
├── mvnw                       # Maven Wrapper para Linux/macOS
├── mvnw.cmd                   # Maven Wrapper para Windows
├── pom.xml                    # Configuração do projeto Maven
└── README.md                  # Documentação do backend
```

## Comandos úteis

Subir backend e banco:

```bash
docker compose up --build
```

Parar os containers:

```bash
docker compose down
```

Parar e remover também os dados do banco:

```bash
docker compose down -v
```

Ver logs do backend:

```bash
docker compose logs -f backend
```

Ver logs do PostgreSQL:

```bash
docker compose logs -f postgres
```
