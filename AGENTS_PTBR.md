# AGENTS_PTBR.md — Diretrizes para Agentes Autônomos de IA no Cursor AI PT-BR

Este documento define detalhes arquiteturais, padrões operacionais e invariantes de segurança para agentes autônomos de IA (como Google Antigravity, Claude Code, Cursor e Codex) que atuem na manutenção ou atualização do pacote de tradução em Português do Brasil (PT-BR) para o Cursor AI.

---

## 1. Visão Geral e Arquitetura do Projeto

* **Aplicativo Alvo:** Cursor AI Desktop (Fork do VS Code / Electron para Windows x64).
* **Build de referência:** dinâmico; o instalador detecta a versão e o commit instalados. Trate o build da última validação apenas como referência.
* **Autor e Desenvolvedor Principal:** **Emerson Teles** (Padrão de créditos: "Tradução PTBR - Emerson Teles").
* **Propósito do Repositório:** Traduzir o núcleo do editor e a interface do Cursor preservando os bundles e backups específicos de cada compilação.

### Arquitetura de 3 Camadas do Sistema:
1. **Camada 1 — Núcleo Base do Editor (Cache NLS/CLP Oficial):** Localizado via pacote de idioma oficial da Microsoft e cache compilado CLP (`%APPDATA%\Cursor\clp\<hash>.pt-br\<commit>\nls.messages.json` com mais de 13.500 mensagens) gerado por `setup-locale.js`. Tradução com 0% de overhead para menus, terminal, git, explorador, paleta de comandos e preferências gerais.
2. **Camada 2 — Patcher com Versão Correspondente (`patch-workbench.js`):** Aplica literais nativos em `workbench.desktop.main.js` e somente o crédito do Sobre em `workbench.glass.main.js`, sempre usando backups imutáveis da versão e do commit exatos. Nunca aplique bundles dourados do repositório à instalação.
3. **Camada 3 — Observador DOM Seguro (`cursor-pt-dict.js`):** Instalado somente em `out/vs/workbench/`, ao lado de `workbench.desktop.main.js`. O `workbench.js` da versão instalada carrega o dicionário somente quando o Cursor seleciona uma janela Glass. O observador ignora `.monaco-editor`, `.terminal`, `.xterm`, `.view-lines`, `<svg>`, `<script>`, `<style>` e `<canvas>`.
   Observe `childList`, `characterData` e atributos relevantes (`placeholder`, `title`, `aria-label`, `data-tooltip`). Quando texto ou atributo mudar in-place, remova o alvo de `processedNodes` antes de enfileirá-lo novamente para traduzir atualizações de React/Solid.
4. **Isolamento do React e Glass:** Preserve `workbench.glass.main.js` original no backup versionado. A única exceção é a inserção do crédito no Sobre, feita por `patch-workbench.js` a partir do backup exato da versão/commit. Não aplique bundles do repositório, imports do dicionário ou outras substituições nesse arquivo ou nos runtimes React.
5. **Validação de Integridade e Checksums:** `repair-integrity.js` recalcula e sincroniza os hashes em `product.json` garantindo integridade e ausência total de BOM UTF-8.

---

## 2. Invariantes Críticos de Segurança (REGRAS OBRIGATÓRIAS)

1. **NUNCA INTERCEPTAR JSX NO RUNTIME DO REACT 19:**
   * Não injete o observador nos bundles minificados Glass ou React. A integração com Glass é somente um import dinâmico protegido no `workbench.js`, com backup da versão instalada.
2. **COPIAR `cursor-pt-dict.js` SEMPRE PARA `out/vs/workbench/`:**
   * `workbench.desktop.main.js` reside em `out/vs/workbench/` e importa `./cursor-pt-dict.js`. Se o dicionário for colocado apenas em `react-runtime/react/`, o Chromium emite `net::ERR_FILE_NOT_FOUND` e aborta a inicialização do editor, gerando tela branca seguida de tela cinza congelada.
3. **NUNCA FAZER MONKEY-PATCH EM `window.open` OU `document.title`:**
   * O sandbox do Electron e a barra de título nativa gerenciam `window.open` e `document.title` via IPCs de controle de janela. Manipular seus descritores gera instabilidade e falhas em janelas auxiliares.
4. **LIMITAR ALTERAÇÕES NO BUNDLE GLASS AO CRÉDITO DO SOBRE:**
   * A janela Glass é um bundle React/Solid minificado. Use somente o backup exato da versão/commit e insira o crédito turquesa abaixo dos direitos autorais em `glass-about-dialog-window`. Não aplique outras substituições, imports do dicionário ou patches nos runtimes React.
5. **NUNCA DESTRUIR ÁRVORES DOM COM `node.textContent`:**
   * O observador DOM deve alterar exclusivamente `node.nodeValue` de nós de texto (`nodeType === 3`) ou elementos com filho único de texto. Nunca destrua filhos SVGs ou tags aninhadas.
6. **PRESERVAÇÃO DOS ORIGINAIS POR COMPILAÇÃO:**
   * Salve os arquivos originais da compilação instalada uma única vez dentro da pasta do programa Cursor em `_backups/<versão>/<commit>/`, incluindo `workbench.js` em `workbench-entry/`. Nunca grave backups brutos junto dos scripts, substitua um backup existente nem use bundles arquivados do repositório para substituir arquivos instalados.
7. **NUNCA GRAVAR BOM NO `product.json` OU `nls.messages.json`:**
   * O BOM UTF-8 (`\uFEFF`) causa quebras no `JSON.parse` do Node/Electron, travando o carregamento do Cursor. Use sempre UTF-8 sem BOM.
8. **INTEGRIDADE DE ATALHOS DE TECLADO:**
   * Nunca modifique identificadores de comandos (`cursor.composer`, `aichat.newchat`, etc.) ou atalhos padrão (`Ctrl+K`, `Ctrl+L`, `Ctrl+I`). Apenas labels visíveis, títulos e placeholders devem ser traduzidos.
9. **MANTER AS ATUALIZAÇÕES DO CURSOR ATIVAS:** Não substitua o atualizador oficial nem force `update.mode` para manual. Depois de uma atualização, execute novamente o instalador para salvar e aplicar a tradução à nova compilação.
10. **ADESÃO TERMINOLÓGICA:**
   * Cumpra rigorosamente o padrão de **Emerson Teles**: "aplicativo" (nunca "app"), "tokens" (nunca "fichas"), "ativar / desativar", "Direcionar" (Steer), "Parar Tarefa" (Stop Task).

---

## 3. Procedimentos de Verificação e Testes

1. **Teste de Inicialização do Editor:**
   Confirme que o editor inicia em menos de 2 segundos, sem tela branca, cinza ou preta. A barra lateral, menus e paleta de comandos devem exibir textos em português.
2. **Verificação do Composer & Chat:**
   Pressione `Ctrl+I` para abrir o Composer. Verifique se os botões de ação ("Aceitar", "Rejeitar", "Aplicar") e placeholders aparecem em português sem quebras de layout.
3. **Verificação de Restauração:**
   Execute `Restaurar-Original.bat` e confirme que o backup do workbench correspondente à versão instalada foi restaurado.
## Reexecução e restauração
- Ao executar novamente, o instalador reconhece uma tradução completa e informa que não precisa reaplicá-la. Se estiver parcial, recompõe a tradução a partir do backup original limpo e exato da versão.
- Se o Cursor já estiver traduzido, o instalador atualiza somente o dicionário PT-BR quando houver mudanças; não reconstrói os bundles nem substitui backups. Reinicie o Cursor para carregar as novas entradas.
- O backup original é criado uma única vez em `<pasta instalada>\_backups\<versão>` e nunca é substituído pela tradução. Se uma instalação já modificada não tiver backup confiável, o instalador interrompe e informa isso.
- Na restauração, arquivos que já correspondem ao original são identificados e não são copiados novamente. Backup ausente ou inválido gera uma mensagem clara e impede uma restauração insegura.
- O crédito de localização é exibido como `Tradução PT-BR: Emerson Teles`, na cor turquesa `#00adb5`, no local de crédito disponível na interface.
- Mantenha o dicionário atualizado com os títulos e as descrições visíveis das configurações do Cursor, incluindo as opções contribuídas por extensões como Remote - SSH e mensagens de entrada nos recursos de IA. Não traduza identificadores de configuração, IDs de comandos, nomes de protocolos nem tokens de código nas descrições.
### Mensagens do instalador e créditos
- Se já estiver traduzido, o instalador mostra uma mensagem ciano clara e não reaplica o pacote.
- Se já estiver original, a restauração avisa em ciano que não é necessária; uma restauração real termina com a confirmação verde de sucesso.
- No prompt final, S abre o aplicativo em processo independente e a janela do CMD iniciada pelo atalho fecha automaticamente; N, Enter ou Esc encerra sem abrir o aplicativo.
- Crédito: Tradução PT-BR: Emerson Teles, em turquesa #00adb5. O crédito fica no diálogo “Sobre”, abaixo dos direitos autorais.
### Estado da restauração sem backup da compilação
Se não existir backup da versão/compilação atual, o restaurador verifica os bundles em busca das marcas próprias do patch PT-BR. Sem essas marcas, ele só ajusta o `argv.json` para inglês quando necessário e informa em azul-turquesa que os bundles já estão limpos; se encontrar marcas de tradução, interrompe sem alegar que restaurou. A tradução de uma compilação nova cria o backup original antes de aplicar qualquer patch.
## Backup original ausente
Se o backup original da versão não estiver em _backups, o restaurador não consegue reconstruir os arquivos de fábrica e deve informar que a restauração não é possível. Repare ou instale a versão oficial do aplicativo por cima da instalação existente, preservando os projetos e dados do perfil do usuário; depois execute novamente o instalador ou restaurador.
