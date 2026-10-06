# Histórico de Alterações

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
