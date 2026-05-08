# Frontend

Este diretório contém o frontend do Sistema de Gestão de Instrutores e Alunos do GEM.

A aplicação foi desenvolvida em Flutter e consome a API do backend para gerenciar os dados do sistema, como alunos, instrutores, pessoas e comuns congregações.

## Tecnologias utilizadas

* Flutter
* Dart
* Material Design
* HTTP

## Requisitos

Para executar o frontend, é necessário ter instalado:

* Flutter SDK
* Dart SDK, normalmente já incluído na instalação do Flutter
* Google Chrome, para execução no navegador

Para verificar se o ambiente Flutter está configurado corretamente, execute:

```bash
flutter doctor
```

## Dependências principais

As principais dependências do frontend são:

* `flutter`, SDK principal da aplicação;
* `http`, utilizado para realizar requisições para a API;
* `cupertino_icons`, utilizado para ícones no padrão Cupertino;
* `flutter_lints`, utilizado para padronização e análise do código.

As dependências estão declaradas no arquivo `pubspec.yaml`.

## Antes de executar

Antes de iniciar o frontend, o backend precisa estar em execução.

A partir da raiz do projeto, suba o backend e o banco de dados com:

```bash
docker compose up --build
```

A API deve ficar disponível em:

```text
http://localhost:8080
```

Atualmente, os services do frontend utilizam essa URL como endereço base da API.

## Como executar o frontend

Acesse a pasta do frontend:

```bash
cd frontend
```

Instale as dependências do projeto:

```bash
flutter pub get
```

Execute a aplicação no Chrome:

```bash
flutter run -d chrome
```

Após isso, o Flutter abrirá uma janela do navegador com a aplicação em execução.

## Funcionalidades disponíveis

No estágio atual, o frontend possui telas e serviços relacionados a:

* listagem de alunos;
* cadastro, edição e exclusão de alunos;
* listagem de instrutores;
* cadastro, edição e exclusão de instrutores;
* listagem de pessoas;
* cadastro, edição e exclusão de pessoas;
* listagem de comuns;
* cadastro, edição e exclusão de comuns;
* tela inicial com resumo de registros cadastrados.

## Comunicação com o backend

A comunicação com o backend é feita por meio de services localizados em:

```text
lib/services/
```

Esses services realizam requisições HTTP para a API Spring Boot.

A URL base utilizada atualmente é:

```text
http://localhost:8080
```

Principais endpoints consumidos:

```text
GET    /alunos
POST   /alunos
PUT    /alunos/{id}
DELETE /alunos/{id}

GET    /instrutores
POST   /instrutores
PUT    /instrutores/{id}
DELETE /instrutores/{id}

GET    /pessoas
POST   /pessoas
PUT    /pessoas/{cpf}
DELETE /pessoas/{cpf}

GET    /comuns
POST   /comuns
PUT    /comuns/{id}
DELETE /comuns/{id}
```

## Estrutura principal

```text
frontend/
├── lib/
│   ├── main.dart          # Ponto de entrada da aplicação
│   ├── models/            # Modelos utilizados pelo frontend
│   ├── services/          # Comunicação HTTP com o backend
│   └── views/             # Telas da aplicação
├── test/                  # Testes do Flutter
├── pubspec.yaml           # Dependências e configurações do projeto
└── README.md              # Documentação do frontend
```

## Comandos úteis

Instalar dependências:

```bash
flutter pub get
```

Executar no Chrome:

```bash
flutter run -d chrome
```

Listar dispositivos disponíveis:

```bash
flutter devices
```

Executar testes:

```bash
flutter test
```

Analisar o código:

```bash
flutter analyze
```

Limpar arquivos gerados:

```bash
flutter clean
```

Depois de limpar o projeto, instale novamente as dependências:

```bash
flutter pub get
```

## Observações

* O backend deve estar rodando antes de abrir o frontend.
* A execução recomendada atualmente é pelo Chrome, usando `flutter run -d chrome`.
* Como a URL da API está configurada como `http://localhost:8080`, a aplicação funciona diretamente no navegador quando o backend está rodando na mesma máquina.
* Caso futuramente o frontend seja executado em emulador Android ou dispositivo físico, pode ser necessário ajustar a URL base da API.
* O README padrão gerado pelo Flutter foi substituído por esta documentação específica do projeto.
