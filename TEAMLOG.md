# Registro técnico da equipe

## 2026-10-05 — Marketplace e integrações

- Incluídos no dicionário PT-BR os rótulos de categorias e as descrições completas dos cartões visíveis nas capturas, conferindo os textos truncados com as páginas públicas do Marketplace do Cursor.
- Ampliada a cobertura da tela de Habilidades com traduções exatas de 96 descrições distintas localizadas em 110 arquivos de habilidades padrão e plugins instalados. As cinco descrições do grupo de habilidades do usuário mostrado nas capturas também foram incluídas.
- Acrescentada busca exata tolerante a espaços e quebras de linha nas descrições, sem alterar os arquivos SKILL.md, os nomes das habilidades ou seus gatilhos de seleção.
- Traduzidos os filtros de escopo `Workspaces`, `Workspace`, `User` e `Default`; o rótulo dinâmico do contador agora normaliza a mistura `Mostrar 33 more` para `Mostrar mais 33`.
- As traduções ficam no observador/dicionário já usado pelo projeto; não houve alteração nos metadados remotos dos plugins.
- Marcas e nomes próprios dos produtos foram mantidos. Os trechos truncados nas capturas foram conferidos com as descrições completas das páginas públicas do Marketplace.
- Incluída tradução para a contagem variável de cartões adicionais (`Show N more`) e para `Show less`.
- A varredura estática da compilação Cursor 3.23.14 encontrou 185 strings ainda em inglês nos campos de rótulo/descrição do bundle Glass. A revisão contextual identificou a maioria como nomes de modelos, textos de demonstração/teste, diagnósticos internos e controles de desenvolvimento; foram traduzidos os poucos textos confirmados como interface de produto.
- O restaurador agora escreve `locale: "en"` em UTF-8 sem BOM e valida a leitura de volta. Uma falha em qualquer arquivo de preferência encerra a restauração com erro explícito.
- A revisão local confirmou backup e manifesto da mesma versão/commit do Cursor instalado (3.23.14), com os backups do Workbench e do carregador Glass sem o marcador do dicionário PT-BR.
- A sintaxe do restaurador foi analisada e a varredura final deixou 179 candidatos, revisados como nomes próprios/modelos, exemplos de teste/demonstração, diagnósticos ou rótulos internos de desenvolvimento; os rótulos de produto identificados foram traduzidos.
- O catálogo é remoto e pode mudar; esta atualização cobre os cartões identificáveis nas capturas e não representa tradução automática de novos itens publicados depois.

## Verificação pendente

- Reiniciar o Cursor com o patch aplicado e conferir as descrições no Marketplace em português.
- A restauração real não foi executada durante a revisão para preservar a instalação e a sessão atual; foi verificado que o backup correspondente à compilação atual existe e está limpo.
- Se o Marketplace apresentar cartões diferentes dos mostrados nas capturas, mapear as novas descrições a partir do texto completo que o catálogo fornece.
