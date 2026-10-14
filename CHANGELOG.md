# Histórico de Alterações

### Teste confirmado — Cursor 3.24.12 — 14/10/2026
- O usuário confirmou o teste da tradução na instalação e informou que o Cursor está funcionando.


### Menu da bandeja e console — 13/10/2026
- Adicionadas 5 traduções nativas do Cursor: “Nova Conversa”, “Limpar todas as notificações”, “Abrir o Cursor”, “Configurações” e “Sair”.
- O instalador preserva um backup original do `out/main.js` por versão/commit; o restaurador recupera o mesmo arquivo e interrompe se encontrar PT-BR sem backup confiável.
- Lançadores CMD e scripts PowerShell usam UTF-8 para manter acentos e cedilhas.

## Em desenvolvimento — Cursor 3.24.12 (13/10/2026)

### Atualização de interface do Cursor 3.24.12 — 13/10/2026
- A instalação local está na versão 3.24.12. A varredura inicial encontrou 223 candidatos. Após mapear as strings confirmadas, restam 190 candidatos; muitos parecem exemplos internos, modelos e ferramentas de diagnóstico, mas a classificação não está completa.
- Adicionadas 36 traduções confirmadas de interface: servidores MCP, opções de merge, estado de outra janela, edições em lote, largura do chat, modo Design/Anotar, configurações de microfone, worktrees e desempenho do React, confirmação de descarte de comentário, pesquisa de conversas laterais e rótulos relacionados.
- O ZCode instalado permanece na versão 3.15.3; a varredura do catálogo IntlProvider encontrou 6.313 mensagens mapeadas e 0 lacunas por ID ou texto.

## Histórico de compatibilidade anterior — Cursor 3.23.23 (13/10/2026)

### Correção da busca de instalações — 13/10/2026
- Instalador e restaurador validam primeiro caminhos do processo, registro e locais conhecidos; só quando nenhum candidato válido contém Cursor.exe e `resources\app\package.json` iniciam a busca profunda em unidades fixas e removíveis. A busca ignora pastas raiz do sistema e junctions, deduplica caminhos, mantém instalações distintas selecionáveis e não usa a barra sobreposta do PowerShell. Mantenha `Find-Installations.ps1` ao lado dos scripts.
- A busca mostra a unidade atual, o número de pastas verificadas e as candidatas encontradas; não segue junctions/reparse points para evitar ciclos. Por cobrir todo o volume, pode levar mais tempo em discos grandes ou externos.
- Esta correção altera apenas a localização: 0 novas strings de interface foram adicionadas nesta etapa.

### Busca em camadas sem barra sobreposta — 13/10/2026
- O instalador e o restaurador validam primeiro caminhos obtidos do processo, registro e locais conhecidos. Só se nenhum contiver `Cursor.exe` e `resources\app\package.json` fazem busca profunda em unidades fixas/removíveis.
- A busca profunda ignora pastas de sistema na raiz e junctions, valida o executável junto com `resources\app\package.json`, deduplica caminhos e mantém instalações distintas selecionáveis. O progresso aparece no título da janela; a barra `Write-Progress` foi removida.
- Esta melhoria altera a busca, não a interface: 0 novas strings.

- Corrigida a persistência do inglês na tela inicial do Glass: o placeholder `Plan, Build, / for skills, @ for context` e as duas variantes da descrição de automações agora são traduzidos diretamente no bundle original da compilação, além do fallback dinâmico. Incluído tratamento da frase parcial que chegava misturada com o rótulo `Ativado`.
- Correção na busca: instalador e restaurador normalizam e deduplicam caminhos descobertos por fontes diferentes, sem ocultar instalações que estejam em pastas distintas.
- Ampliada a detecção automática para procurar `Cursor.exe` recursivamente em todas as unidades montadas, inclusive externas, e validar o `resources\app\package.json` de cada instalação.
- Total nesta rodada: 5 mensagens novas de interface (4 de voz/gravação e 1 de orientação durante a execução); a última tem 2 variantes de pontuação no dicionário. O placeholder “Plan, Build...” já existia no dicionário; o escaneamento agora também o processa dentro da superfície do editor.
- Ajustado o escaneamento do DOM para traduzir placeholders dentro de superfícies do editor sem alterar o conteúdo de código; demais caminhos dos instaladores/restauradores e backups continuam pareados.
- Revisada a acentuação: corrigidos 9 textos visíveis do instalador, restaurador e mensagens auxiliares (por exemplo, “possível”, “está”, “usuário” e “já está”). São ajustes de textos existentes; 0 novas strings de interface foram adicionadas nesta correção.
- Instalador e restaurador agora procuram `Cursor.exe` recursivamente em todas as unidades montadas, além da instalação em execução, locais conhecidos e registro. Validam `resources\app\package.json`, deduplicam o mesmo diretório e permitem selecionar cópias distintas.
- Quando nenhum candidato válido é encontrado, o caminho manual é validado pela presença de `Cursor.exe` e `resources\app\package.json`. A restauração continua vinculada à versão, ao commit e ao backup imutável da instalação selecionada.
- Varredura inicial da compilação 3.23.23 gerou 178 candidatos de texto. A lista contém nomes de comandos internos, telemetria e conteúdo técnico, portanto não representa 178 rótulos de interface pendentes.

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
