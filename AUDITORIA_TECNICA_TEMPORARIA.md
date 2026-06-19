# Auditoria tecnica temporaria

> Documento temporario. Auditoria realizada em 19/06/2026 sobre a branch
> `feat-135/testes-correcoes-finais`, commit `0a0aa91`.

## Escopo e metodo

Foram revisados os arquivos versionados do backend Spring Boot, frontend
Flutter, configuracao Docker/Nginx, seed, modelos de banco e testes. A analise
foi estatica e manual, complementada por busca global de entradas, validacoes,
autorizacoes, segredos, consultas, limites e tratamento de erros.

Verificacoes executadas:

- `flutter analyze`: passou sem apontamentos.
- `flutter test`: 1 teste executado e aprovado.
- `./mvnw test`: falhou ao carregar o contexto por ausencia de
  `org.h2.Driver`; nenhum teste de comportamento foi executado.
- Busca por SQL manual: nao foi encontrado SQL concatenado nem consulta nativa.
- Busca por upload de arquivos: nao foi encontrada superficie de upload.

Esta nao foi uma prova de invasao nem uma varredura de CVEs das dependencias.
Os achados abaixo refletem o codigo e a configuracao presentes no snapshot.

## Resumo executivo

O problema mais urgente e o segredo JWT padrao e publicamente previsivel. Como
o Compose nao fornece outro segredo e o filtro confia no perfil contido no
token, uma pessoa que conheca o codigo pode fabricar um token de administrador.
Isso deve ser corrigido antes de qualquer exposicao fora de uma maquina local.

Tambem exigem prioridade: uso permanente do perfil `dev` com credenciais
conhecidas, possibilidade de um instrutor atribuir aulas a outro instrutor,
ausencia de limites para textos e listagens, validacao incompleta nas rotas de
edicao, falta de restricoes para instrumento principal e uso de
`ddl-auto=update` sem migracoes.

## Achados criticos

### CR-01 - Segredo JWT conhecido permite forjar qualquer perfil

**Evidencias:**

- `backend/src/main/java/com/gem/backend/service/TokenService.java:27` usa o
  fallback fixo `gem-secret`.
- `docker-compose.yml:18-24` nao injeta `api.security.token.secret`.
- `backend/src/main/java/com/gem/backend/config/SecurityFilter.java:39-45`
  aceita o CPF e o perfil do token sem confirmar a conta no banco.

**Impacto:** com o segredo conhecido, e possivel assinar um JWT com
`perfil=ADMIN` e obter acesso administrativo completo. A assinatura deixa de
ser uma barreira de autenticacao.

**Recomendacao:** remover o valor padrao e fazer a aplicacao falhar ao iniciar
quando `JWT_SECRET` estiver ausente; usar segredo aleatorio de alta entropia,
armazenado fora do repositorio; injeta-lo por ambiente/secret manager e
rotacionar o segredo atual. Depois da rotacao, invalidar os tokens existentes.

## Achados altos

### AL-01 - Compose inicia sempre em `dev` com contas conhecidas

**Evidencias:** `docker-compose.yml:19` fixa `SPRING_PROFILES_ACTIVE=dev`;
`DataSeeder.java:29-30` habilita a seed nesse perfil; as credenciais completas
estao em `README.md:183-209`.

**Impacto:** se esse Compose for reutilizado em homologacao ou producao, uma
conta administrativa conhecida sera criada em banco vazio. A senha de banco de
exemplo tambem e fraca (`.env.example:5`).

**Recomendacao:** separar arquivos/perfis de desenvolvimento e producao;
deixar seed e portas de depuracao apenas em override local; nunca criar usuarios
padrao em producao e exigir troca de senha quando houver bootstrap controlado.

### AL-02 - Instrutor pode atribuir ou mover uma aula para outro instrutor

**Evidencias:** `RegistroAulaController.java:30-33` permite criacao por
instrutor; `RegistroAulaService.java:43-47` aceita qualquer `instrutor.id` do
corpo. Na edicao, `RegistroAulaService.java:95-97` tambem substitui o instrutor
sem comparar com a identidade autenticada.

**Impacto:** quebra de autoria e trilha de auditoria. Um instrutor pode produzir
registros em nome de outro ou transferir registros existentes.

**Recomendacao:** para `ROLE_INSTRUTOR`, obter o instrutor exclusivamente do CPF
autenticado; ignorar/rejeitar `instrutorId` enviado pelo cliente. Manter a
escolha de outro instrutor apenas para administrador, se for uma regra explicita.

### AL-03 - Campos e respostas sem limites permitem consumo excessivo

**Evidencias:** `RegistroAula.java:35-39` define `descricao` e
`paraProximaAula` como `TEXT`, sem `@Size`; o formulario correspondente tambem
nao define `maxLength`. Nao ha limite global de corpo HTTP. Todas as listagens
usam `findAll()` ou retornam `List`, por exemplo `AlunoService.java:66-69`,
`MetodoService.java:53-55` e `RegistroAulaRepository.java:21-23`.

**Impacto:** requisicoes muito grandes podem consumir memoria e banco; com o
tempo, listagens completas podem degradar ou derrubar API, navegador e rede.

**Recomendacao:** definir limites de negocio em caracteres para os dois textos,
limite de corpo HTTP e validacao equivalente no frontend. Paginar todas as
colecoes, impor tamanho maximo de pagina e filtrar historicos no banco.

### AL-04 - Rotas de atualizacao nao executam Bean Validation

**Evidencias:** as rotas `PUT` em `AdminController.java:41-43`,
`AlunoController.java:57-60`, `ComumController.java:50-53`,
`InstrumentoController.java:47-50`, `InstrutorController.java:45-47`,
`MetodoController.java:40-43`, `PessoaController.java:53-59` e
`RegistroAulaController.java:54-57` recebem corpo sem `@Valid`.

**Impacto:** limites `@Size`, obrigatoriedade e faixa de presenca funcionam na
criacao, mas podem ser contornados na edicao. O resultado varia entre dados
invalidos, erro de banco reportado como conflito e erro 500.

**Recomendacao:** usar DTOs distintos para criacao e atualizacao, ambos
validados; aplicar `@Valid` e validacao aninhada onde necessaria; testar todos os
limites nas duas operacoes.

### AL-05 - Banco nao garante unicidade nem um unico instrumento principal

**Evidencias:** `AlunoInstrumento.java:17-38` e
`InstrutorInstrumento.java:17-38` nao possuem restricao unica para o par
usuario/instrumento, deixam `JoinColumn` e flag sem `nullable=false` e nao
impedem dois registros principais. Nao ha repository/service para essas
entidades neste snapshot.

**Impacto:** duplicidade, nenhum principal ou varios principais podem existir,
inclusive por concorrencia ou escrita direta. O fluxo de instrumentos nao tem
uma API transacional que preserve a regra.

**Recomendacao:** criar `UNIQUE(aluno_id, instrumento_id)`, colunas `NOT NULL` e
uma garantia atomica de no maximo um principal por aluno (indice parcial no
PostgreSQL ou transacao com bloqueio e validacao). Aplicar regra equivalente ao
instrutor se esse conceito for usado.

### AL-06 - Modelo de metodo nao representa compartilhamento entre alunos

**Evidencia:** `Metodo.java:26-28` possui um unico `aluno_id` dentro do proprio
metodo. A resposta em `MetodoResponseDTO.java:14-21` nem informa esse vinculo.

**Impacto:** um mesmo metodo de estudo nao pode ser associado a varios alunos
sem duplicar o cadastro. Tambem nao ha uma relacao explicita aluno-metodo que
permita manter metodos antigos ao trocar o instrumento principal com integridade.

**Recomendacao:** separar catalogo de metodos da associacao de estudo, por
exemplo `metodos` e `alunos_metodos`, com chaves estrangeiras, unicidade e
operacao transacional. Filtrar as opcoes pelo instrumento principal no servico,
sem apagar associacoes historicas.

### AL-07 - Schema e alterado automaticamente sem migracoes versionadas

**Evidencia:** `application.properties:11` usa
`spring.jpa.hibernate.ddl-auto=update` em qualquer perfil. Nao existem scripts
Flyway/Liquibase no projeto.

**Impacto:** mudancas de entidade podem gerar schema diferente entre ambientes,
falhar parcialmente ou causar perda/inconsistencia dificil de reproduzir.

**Recomendacao:** usar Flyway ou Liquibase, `validate` em producao e migracoes
revisadas, testadas e com estrategia de rollback/backup.

### AL-08 - Login nao tem protecao contra tentativas automatizadas

**Evidencias:** `AuthController.java:29-36` expoe o login sem limitacao;
`AuthService.java:42-80` consulta e calcula BCrypt a cada tentativa. Nao ha
rate limit, atraso progressivo, bloqueio temporario ou monitoramento.

**Impacto:** facilita forca bruta e pode ser usado para consumir CPU por meio do
BCrypt, principalmente porque CPF, senha e tamanho do corpo nao sao limitados.

**Recomendacao:** limitar por IP e identidade, adicionar backoff/bloqueio
temporario, metricas e alertas. Aplicar limites de tamanho antes do BCrypt.

### AL-09 - Implantacao nao fornece transporte ou cabecalhos seguros

**Evidencias:** `ApiConfig` usa `http://localhost:8080` em
`frontend/lib/config/api_config.dart:6-10`; Nginx escuta HTTP e so configura
`try_files` (`frontend/nginx.conf:1-10`); Compose publica banco, API e frontend
em todas as interfaces (`docker-compose.yml:11-12`, `27-28`, `36-37`).

**Impacto:** fora do localhost, senha e token podem trafegar sem criptografia; o
banco fica acessivel pela rede do host e faltam HSTS, CSP/`frame-ancestors`,
`X-Content-Type-Options` e politica de referrer.

**Recomendacao:** terminar TLS em proxy/gateway, servir frontend e API sob HTTPS,
nao publicar PostgreSQL em producao e adicionar cabecalhos de seguranca. Restringir
binds/firewall e configurar a URL da API no build.

## Achados medios

### ME-01 - Entidades JPA sao usadas como contratos de entrada

Controllers recebem `Admin`, `Aluno`, `Pessoa`, `Metodo` e outras entidades
diretamente. Isso acopla a API ao schema, amplia risco de mass assignment e
dificulta regras diferentes entre create/update. As associacoes tambem nao usam
validacao em cascata. Criar request DTOs com apenas os campos aceitos e IDs de
relacionamento.

### ME-02 - Login nao valida formato, nulos ou tamanho

`LoginRequestDTO.java:13-17` nao tem `@NotBlank`, `@Pattern`, `@Size` ou
`@NotNull`, e `AuthController.java:30` nao usa `@Valid`. Nulos acabam como 401
por captura generica, em vez de 400; entradas enormes chegam aos repositorios e
ao encoder. Definir CPF com 11 digitos, perfil obrigatorio e limites coerentes
para senha.

### ME-03 - Politica de senha e inconsistente e fraca

O backend aceita senha nao vazia de ate 255 caracteres (`Admin.java:16-18`,
`Aluno.java:24-26`, `Instrutor.java:25-27`), sem tamanho minimo. O frontend
limita a 16 e aplica `trim()` antes de cadastrar, por exemplo
`aluno_form_page.dart:86-91` e `112-120`, enquanto o login envia a senha sem
`trim()` (`home_page.dart:55`). Uma senha criada com espacos pode mudar
silenciosamente. Definir politica unica, preservar a senha literalmente e usar
limite em bytes compativel com o encoder.

### ME-04 - Dados textuais nao sao normalizados antes de persistir

Os servicos testam `trim().isEmpty()` em alguns pontos, mas salvam o valor
original. Nao ha normalizacao de espacos, caixa, Unicode ou caracteres de
controle. Isso permite nomes visualmente duplicados e buscas inconsistentes.
Centralizar normalizacao no backend e criar indices/restricoes para unicidades
de negocio; o frontend nao deve ser a barreira de seguranca.

### ME-05 - Limites de Comum divergem entre frontend e backend

O frontend permite nome com 100 caracteres e cidade/bairro com 60
(`comum_form_page.dart:124-155` e `179-190`), mas o backend/banco aceita apenas
32 (`Comum.java:23-45`). Valores validos na tela falham na API. Compartilhar o
contrato ou alinhar todos os limites; preferir mensagens 400 de validacao.

### ME-06 - Erros de entrada podem virar 500 e excecoes nao sao registradas

`GlobalExceptionHandler.java:102-116` captura qualquer excecao, nao a registra e
responde 500. JSON malformado, tipo invalido e outros erros de desserializacao
nao tem handler 400 dedicado. `AuthController.java:31-35` ainda converte qualquer
`RuntimeException`, inclusive falha interna, em 401. Adicionar handlers
especificos e log estruturado com correlation ID, sem expor stack trace ao
cliente.

### ME-07 - Operacoes compostas e checagens nao sao transacionais

Nao foi encontrado `@Transactional`. Fluxos de buscar/verificar/salvar e
checagens `exists...` ficam sujeitos a corrida; restricoes de banco cobrem
apenas parte dos casos. Delimitar transacoes no servico e tratar unicidade no
banco como fonte final da verdade.

### ME-08 - Ciclo de vida do token e fraco

`SecurityFilter.java:51-55` remove `Bearer ` com `replace`, em vez de validar o
prefixo estritamente, e valida o mesmo token duas vezes. Tokens continuam
validos por duas horas mesmo apos exclusao, troca de senha ou revogacao de
perfil, pois nao ha consulta/revogacao. `TokenService.java:57-59` usa offset
`-03:00` fixo. Fazer uma unica verificacao, parser estrito, expiracao baseada em
`Instant`, estrategia de revogacao/versao e rotacao de chave.

### ME-09 - Cliente HTTP pode ficar pendurado e nao encerra sessao expirada

`api_config.dart:182-211` nao aplica timeout. Um 401 e apenas transformado em
erro; nao limpa a sessao nem redireciona. Na inicializacao,
`AuthSession.autenticado` (`api_config.dart:28`) verifica apenas se existe token,
nao sua expiracao. Adicionar timeout, cancelamento, tratamento central de 401 e
validacao/renovacao da sessao.

### ME-10 - Seed e tudo-ou-nada e nao corrige banco parcial

`DataSeeder.java:47-56` aborta se qualquer uma das oito tabelas tiver um
registro. Um banco parcialmente populado pode ficar sem administrador ou sem
dados dependentes, e novas partes da seed nunca entram. Tornar a seed idempotente
por chave natural ou usar migracoes de dados separadas.

### ME-11 - Teste do backend nao e hermetico e esta quebrado

Existe apenas `BackendApplicationTests.contextLoads()`
(`backend/src/test/java/com/gem/backend/BackendApplicationTests.java:6-11`). Na
auditoria, `./mvnw test` terminou com 1 erro porque tentou carregar
`org.h2.Driver`, que nao esta nas dependencias. Criar perfil de teste completo
com H2 compativel ou Testcontainers/PostgreSQL e garantir que o comando funcione
sem variaveis externas.

### ME-12 - Cobertura automatizada e insuficiente para regras sensiveis

Nao ha testes de autenticacao, autorizacao por perfil, ownership, validacao de
tamanho, concorrencia do instrumento principal, seed ou controllers. O frontend
tem somente um teste da tela de login (`frontend/test/widget_test.dart:12-19`).
Priorizar testes de integracao para CR-01, AL-02, AL-04 e AL-05.

### ME-13 - Containers sem endurecimento ou verificacao de saude

Os Dockerfiles nao definem usuario nao-root e usam tags moveis
(`eclipse-temurin:21-*`, `flutter:stable`, `nginx:alpine`). O Compose nao tem
`healthcheck`, e `depends_on` nao garante que banco/API estejam prontos.
Fixar digests/versoes, executar com usuario minimo, adicionar healthchecks e
limites de recursos.

### ME-14 - CORS e fixo para localhost

`CorsConfig.java:17-20` aceita apenas origens HTTP locais. Isso e adequado ao
desenvolvimento, mas uma implantacao remota quebra ou incentiva ampliacao
apressada para `*`. Externalizar uma allowlist exata por ambiente e manter
credenciais/origens sob controle.

### ME-15 - SQL detalhado esta habilitado em todos os ambientes

`application.properties:12-13` ativa `show-sql` e formatacao globalmente. Isso
aumenta volume de logs e pode revelar estrutura e padroes de acesso. Desativar
em producao e controlar logging por perfil.

### ME-16 - Atualizacoes assincronas podem chamar `setState` apos descarte

Varias telas chamam `setState` depois de `await` sem conferir `mounted`, por
exemplo `registro_aula_form_page.dart:83-101` e
`aluno_perfil_page.dart:30-46`. Isso pode gerar excecoes ao navegar rapidamente.
Checar `mounted` antes de todo `setState` pos-`await` ou encapsular o estado.

### ME-17 - Expressao de autorizacao de Metodo esta incorreta

`MetodoController.java:13` usa `hasAuthority` com dois argumentos. A funcao
correta e `hasAnyAuthority`. Hoje todas as rotas tem anotacao propria, mas a
anotacao de classe e invalida/fragil e pode causar erro de avaliacao ao adicionar
um endpoint sem override.

## Achados baixos e regras a confirmar

- CPF e validado apenas por formato de 11 digitos (`Pessoa.java:21-24`), nao por
  digitos verificadores. Confirmar se CPFs ficticios devem continuar permitidos.
- `RegistroAula.data` nao tem `@NotNull` e datas de 2000 a 2100 sao aceitas pela
  tela. Definir se aula futura ou muito antiga e valida.
- `presente` aceita nulo no banco/modelo, embora a tela sempre escolha 0 ou 1.
- Nomes de comum, instrumento e metodo nao tem restricao de unicidade; confirmar
  se duplicatas por caixa/espacos sao permitidas.
- `InstrutorResponseDTO.java:25-29` verifica `pessoa` em alguns campos, mas a
  dereferencia sem protecao nos seguintes. O schema atual exige pessoa, porem
  dados legados corrompidos provocariam 500.
- `AdminController.java:13` tem import duplicado, sem impacto funcional.

## Pontos positivos observados

- Senhas sao persistidas com BCrypt (`PasswordConfig.java:19-22`) e os DTOs de
  resposta revisados nao expoem hashes.
- O backend usa repositorios Spring Data e consultas derivadas; nao foi
  encontrada concatenacao de SQL, reduzindo risco de SQL injection.
- O aluno e impedido no servico de consultar perfil e registro de aula de outro
  aluno (`AlunoService.java:72-86` e `RegistroAulaService.java:69-83`).
- O `.env` esta ignorado pelo Git, e o arquivo local nao foi incluido na analise
  nem teve seu conteudo documentado.
- Stack traces e mensagens internas estao desabilitados na resposta padrao
  (`application.properties:15-17`).
- O frontend renderiza dados com widgets `Text`, sem uso de HTML bruto
  identificado; nao foi encontrada uma superficie direta de XSS armazenado.

## Ordem sugerida de correcao

1. Corrigir CR-01, rotacionar a chave e separar configuracao de producao.
2. Remover seed/credenciais conhecidas de ambientes publicados e implementar
   rate limit no login.
3. Corrigir autoria dos registros de aula e adicionar testes de autorizacao.
4. Introduzir request DTOs validados, limites de texto/corpo e paginacao.
5. Criar migracoes e restricoes para instrumentos/metodos/principal.
6. Corrigir o perfil de testes do backend e cobrir os fluxos criticos.
7. Endurecer TLS, Nginx, containers, CORS, logs e ciclo de sessao.
