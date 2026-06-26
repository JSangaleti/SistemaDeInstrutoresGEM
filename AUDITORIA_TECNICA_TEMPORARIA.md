# Auditoria de fluxos do usuario final

Revisao realizada em 26/06/2026 com foco em problemas percebidos por aluno,
instrutor e administrador durante o uso normal do sistema. Esta auditoria nao
trata de vulnerabilidades, infraestrutura, hardening ou melhorias tecnicas sem
impacto direto na experiencia do usuario.

## Resumo

O projeto esta em bom estado geral para uso, mas ainda ha alguns fluxos que
podem causar erro, confusao ou bloqueio para o usuario final. Os pontos mais
importantes estao concentrados na area do instrutor, principalmente em registro
e edicao de aulas. Tambem ha pequenos ajustes necessarios em formularios de
senha e no cadastro do instrumento principal do instrutor.

## Problemas relevantes

### UX-01 - Instrutor nao consegue registrar aula a partir do historico

**Onde ocorre:** area do instrutor, tela `Historico de Aulas`.

**Evidencias:**

- `frontend/lib/views/instrutor_historico/instrutor_historico_page.dart:87-95`
  abre `RegistroAulaFormPage` apenas com `alunoInicialId`.
- `frontend/lib/views/registro_aula_form/registro_aula_form_page.dart:83-88`
  tenta buscar a lista de instrutores quando nao recebe um instrutor fixo.
- `backend/src/main/java/com/gem/backend/controller/InstrutorController.java:40-43`
  restringe a listagem de instrutores ao administrador.

**Impacto para o usuario:** o instrutor seleciona um aluno no historico, toca em
`Registrar aula` e tende a receber erro ao carregar o formulario, porque a tela
faz uma chamada que o proprio instrutor nao pode executar.

**Recomendacao:** ao abrir o formulario pelo historico do instrutor, passar
`instrutorFixoId` e `instrutorFixoNome` da sessao, como ja acontece no atalho
`Registros de Aula` do painel do instrutor.

### UX-02 - Instrutor ve registros de outros instrutores como se fossem editaveis

**Onde ocorre:** area do instrutor, tela `Registros de Aula`.

**Evidencias:**

- `backend/src/main/java/com/gem/backend/service/RegistroAulaService.java:59-62`
  retorna todos os registros em `GET /registro-aulas`.
- `frontend/lib/views/registro_aula_list/registro_aula_list_page.dart:88-96`
  permite abrir qualquer registro para edicao.
- `backend/src/main/java/com/gem/backend/service/RegistroAulaService.java:97-103`
  bloqueia a edicao quando o registro nao pertence ao instrutor autenticado.

**Impacto para o usuario:** registros de outros instrutores aparecem na lista e
parecem editaveis. O erro surge apenas depois de abrir o registro e tentar
salvar, criando a sensacao de que a tela permitiu uma acao que o sistema
recusou.

**Recomendacao:** para instrutores, exibir apenas registros do instrutor
autenticado. Se a regra for permitir consulta geral, a tela deve marcar registros
de outros instrutores como somente leitura e remover a acao de edicao.

### UX-03 - Perfil do instrutor mostra instrumento principal, mas nao ha cadastro para isso

**Onde ocorre:** perfil do instrutor e cadastro/edicao de instrutores.

**Evidencias:**

- `frontend/lib/views/instrutor_panel/instrutor_perfil_page.dart:133-136`
  mostra o campo `Instrumento principal`.
- `backend/src/main/java/com/gem/backend/service/InstrutorService.java:107-112`
  busca o dado na tabela `instrutores_has_instrumentos`.
- `frontend/lib/views/instrutor_form/instrutor_form_page.dart:162-194`
  permite escolher apenas pessoa e senha, sem selecao de instrumentos.

**Impacto para o usuario:** o instrutor pode ver `Instrumento principal: Nao
informado` mesmo quando esse dado deveria existir. O administrador tambem nao
tem uma tela clara para preencher ou corrigir essa informacao.

**Recomendacao:** incluir no cadastro/edicao de instrutor a selecao de
instrumentos e a marcacao de exatamente um instrumento principal, seguindo o
padrao ja usado no cadastro de aluno.

### UX-04 - Tela admin de alterar senhas pode ficar sem feedback ao trocar perfil

**Onde ocorre:** area do administrador, tela `Alterar senhas`.

**Evidencias:**

- `frontend/lib/views/admin/admin_alterar_senhas_page.dart:207-211` limpa
  `_usuarioSelecionado` quando o administrador troca entre alunos, instrutores e
  admins.
- `frontend/lib/widgets/searchable_selection.dart:37-39` usa `initialValue`, mas
  nao sincroniza automaticamente alteracoes externas do `value`.
- `frontend/lib/views/admin/admin_alterar_senhas_page.dart:125-129` retorna sem
  mensagem quando nao ha usuario selecionado.

**Impacto para o usuario:** o administrador pode trocar o tipo de usuario, ver
um valor antigo ainda renderizado e clicar em `Alterar senha`. Se o estado
interno estiver sem usuario selecionado, nada acontece e nenhuma mensagem
explica o que falta fazer.

**Recomendacao:** ao trocar o perfil, forcar a recriacao do campo de selecao
com uma `Key` dependente do perfil ou ajustar o componente para sincronizar
`value`. Tambem exibir mensagem quando o administrador tentar salvar sem usuario
selecionado.

### UX-05 - Confirmacao de senha trata espacos de forma inconsistente

**Onde ocorre:** troca de senha do aluno, instrutor e administrador.

**Evidencias:**

- `frontend/lib/widgets/alterar_senha_card.dart:106-110` compara a confirmacao
  usando `trim()`.
- `frontend/lib/widgets/alterar_senha_card.dart:38-41` envia os textos originais
  para a API.
- `frontend/lib/views/admin/admin_alterar_senhas_page.dart:251-255` repete o
  uso de `trim()` na validacao.
- `frontend/lib/views/admin/admin_alterar_senhas_page.dart:134-139` envia os
  valores originais.
- `backend/src/main/java/com/gem/backend/service/AuthService.java:89-91` e
  `backend/src/main/java/com/gem/backend/service/AuthService.java:126-128`
  comparam nova senha e confirmacao literalmente.

**Impacto para o usuario:** uma senha com espaco no inicio ou no fim pode passar
pela validacao visual, mas ser recusada pelo backend com erro de confirmacao.
Isso faz a tela e o servidor parecerem discordar.

**Recomendacao:** definir uma regra unica. Para este sistema, a opcao mais
simples e aplicar `trim()` antes de validar e enviar senhas nos formularios de
troca. Se espacos forem permitidos como parte da senha, remover o `trim()` da
validacao visual.

## Ordem sugerida de correcao

1. Corrigir o registro de aula pelo historico do instrutor.
2. Filtrar ou bloquear visualmente registros de outros instrutores na tela de
   registros de aula.
3. Adicionar instrumento principal no cadastro/edicao de instrutor.
4. Ajustar a tela admin de alteracao de senhas para limpar visualmente o usuario
   selecionado e exibir mensagem quando faltar selecao.
5. Unificar a regra de espacos na troca de senha.
