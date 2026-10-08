# Histórico de Alterações

## [1.2.0] - 2026-10-07

### Configurações, boas-vindas e Customize
- Traduzidos rótulos que faltavam nas telas dos prints: `Sign in`, `Please log in`, `Try a new window for running parallel agents`, `Indexing`, `Breadcrumb` e `Output (Ctrl+Shift+U)`.
- Revisadas as telas de boas-vindas, barra de status, configurações do Cursor, Customize e Composer. As frases `Plan, Build, / for skills, @ for context` e `[[Press {0} to generate code.]] Start typing to dismiss.` já estavam no dicionário e no catálogo de localização; elas aparecem em português depois de aplicar o patch.
- Adicionada a tradução de `Drag and drop agent chats to split your view into tiled panes` e ampliado o tratamento de atributos `data-placeholder`, usado por campos de entrada do Composer.
- Mantidos sem tradução nomes próprios de extensões, plugins e skills adicionados pelo usuário, além de identificadores e siglas técnicas.
- Confirmado o patch do diálogo “Sobre”: ele insere `Tradução PT-BR: Emerson Teles` em azul turquesa abaixo dos direitos autorais, usando o bundle original exato da compilação.

### Auditoria de cobertura
- Executada uma varredura estática dos bundles do Cursor 3.23.23. Os candidatos incluem conteúdo interno e de teste, então a contagem não equivale a frases de interface pendentes nem garante cobertura completa.
- Na captura inicial, o patch ainda não tinha sido aplicado. Após a aplicação, confirmados no Cursor local o carregamento do dicionário, o crédito no diálogo “Sobre” e o ponto de entrada da tela Glass.

## [1.1.0] - 2026-10-06

### Traduções e auditoria do Cursor 3.23.23
- Aprimorada a tradução de `History (Mem)` para **Histórico (Memória)** no dicionário dinâmico e no catálogo PT-BR gerado pelo `setup-locale.js`.
- Adicionada a tradução de `Choose a plan with more usage` (**Escolha um plano com mais uso**).
- Corrigidos dois rótulos que ainda misturavam português e inglês: `Ignore Process Names` e `Terminal: Ignore Process Names`.
- Revisados os rótulos do Explorador de processos mostrados no print: nome da janela, abas Live/History, nome do processo, memória e rede. As entradas existentes do dicionário dinâmico também são incluídas no catálogo PT-BR.
- Executada a varredura estática em 3.23.23: 179 candidatos em inglês encontrados nos bundles. A revisão identificou principalmente nomes próprios, modelos, identificadores e exemplos de desenvolvimento/teste, que foram mantidos; o número não representa 179 frases de interface confirmadamente pendentes.

## [1.0.0] - 2026-10-05

### Tradução da Interface
- O usuário confirmou que as correções de tradução e descrições estão funcionando no Cursor.
- Localização integral do aplicativo Cursor para Português do Brasil (PT-BR).
- Cobertura completa do núcleo do editor VS Code e da camada exclusiva de IA do Cursor (Glass, Composer, Chat, Agentes e configurações de modelos).
- Dicionário com mais de 10.400 termos técnicos de IA e 13.527 mensagens do catálogo do editor traduzidos.
- Patcher dinâmico com suporte a backup modular automático por versão e commit.
- Scripts de instalação e restauração em um clique (`Instalar-Traducao.bat` e `Restaurar-Original.bat`).
- Auditoria estática e validação de integridade dos pacotes de linguagem concluídas.
