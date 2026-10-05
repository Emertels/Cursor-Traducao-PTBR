import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ==============================================================================
//  Patches Nativos de Interface para Cursor (Ações, Menus e Diálogos de Segurança)
//  Tradução e Engenharia por: Emerson Teles
//  Padrão: Apenas literais seguros e não-colidentes; isolamento estrito contra bugs de minificação
// ==============================================================================

const defaultCursorDir = path.join(process.env.LOCALAPPDATA || '', 'Programs', 'cursor');
const cursorDir = process.argv[2] || defaultCursorDir;
const appDir = path.join(cursorDir, 'resources', 'app', 'out', 'vs', 'workbench');
const versionBackupDir = process.argv[3];

const workbenchFiles = [
  path.join(appDir, 'workbench.desktop.main.js'),
  path.join(appDir, 'workbench.glass.main.js')
];

const REPLACEMENTS = [
  // Export Transcript
  { search: 'label:"Export Transcript"', replace: 'label:"Exportar Transcrição"' },
  { search: 'title:{value:"Export Transcript",original:"Export Transcript"}', replace: 'title:{value:"Exportar Transcrição",original:"Export Transcript"}' },
  { search: 'title:"Export Transcript"', replace: 'title:"Exportar Transcrição"' },
  { search: 'saveLabel:"Export",title:"Export Transcript"', replace: 'saveLabel:"Exportar",title:"Exportar Transcrição"' },

  // Share Transcript
  { search: 'label:"Share Transcript"', replace: 'label:"Compartilhar Transcrição"' },
  { search: 'title:{value:"Share Transcript",original:"Share Transcript"}', replace: 'title:{value:"Compartilhar Transcrição",original:"Share Transcript"}' },
  { search: 'title:"Share Transcript"', replace: 'title:"Compartilhar Transcrição"' },

  // Copy Request ID
  { search: 'title:{value:"Copy Request ID",original:"Copy Request ID"}', replace: 'title:{value:"Copiar ID da Solicitação",original:"Copy Request ID"}' },
  { search: 'title:"Copy Request ID"', replace: 'title:"Copiar ID da Solicitação"' },
  { search: 'label:"Copy Request ID"', replace: 'label:"Copiar ID da Solicitação"' },
  { search: '<span>Copy Request ID: ', replace: '<span>Copiar ID da Solicitação: ' },
  { search: '.LABEL="Copy Request ID"', replace: '.LABEL="Copiar ID da Solicitação"' },

  // Agent Settings
  { search: 'title:{value:"Agent Settings",original:"Agent Settings"}', replace: 'title:{value:"Configurações do Agente",original:"Agent Settings"}' },
  { search: 'title:"Agent Settings"', replace: 'title:"Configurações do Agente"' },

  // Give Feedback
  { search: 'label:"Give Feedback"', replace: 'label:"Enviar Feedback"' },
  { search: 'title:{value:"Give Feedback",original:"Give Feedback"}', replace: 'title:{value:"Enviar Feedback",original:"Give Feedback"}' },
  { search: 'title:"Give Feedback"', replace: 'title:"Enviar Feedback"' },
  { search: '.LABEL="Give Feedback"', replace: '.LABEL="Enviar Feedback"' },

  // Feedback menu items
  { search: '{label:"Report Good"}', replace: '{label:"Relatar como Bom"}' },
  { search: '{label:"Report Bad"}', replace: '{label:"Relatar como Ruim"}' },
  { search: '{label:"Report with Comment"}', replace: '{label:"Relatar com Comentário"}' },
  { search: 'placeholder="Type your comment here..."', replace: 'placeholder="Digite seu comentário aqui..."' },
  { search: 'placeholder="Choose an action"', replace: 'placeholder="Escolher uma ação"' },
  { search: 'description:u?"Disabled in privacy mode":void 0', replace: 'description:u?"Desativado no modo de privacidade":void 0' },
  { search: '{label:"Open in Prompt Quality"}', replace: '{label:"Abrir no Prompt Quality"}' },

  // Other QuickPick actions
  { search: '"Refresh Github Authentication"', replace: '"Atualizar Autenticação do GitHub"' },
  { search: '"Copy Branch Name"', replace: '"Copiar Nome da Ramificação"' },
  { search: '"Copy Agent ID"', replace: '"Copiar ID do Agente"' },
  { search: '"No request ID found"', replace: '"Nenhum ID de solicitação encontrado"' },

  // Agents Sidebar dynamic toggle template literals
  { search: '`Toggle Agents Side Bar (${l})`:"Toggle Agents Side Bar"', replace: '`Alternar Barra Lateral de Agentes (${l})`:"Alternar Barra Lateral de Agentes"' },
  { search: '`Toggle Agents Side Bar (${c})`:"Toggle Agents Side Bar"', replace: '`Alternar Barra Lateral de Agentes (${c})`:"Alternar Barra Lateral de Agentes"' },

  // Run Everything Dialog
  { search: 'title:"Enable Run Everything?"', replace: 'title:"Ativar Executar Tudo?"' },
  { search: 'label:"Enable Run Everything"', replace: 'label:"Ativar Executar Tudo"' },
  { search: 'label:i?"Use Sandbox instead":"Use Allowlist instead"', replace: 'label:i?"Usar Sandbox em vez disso":"Usar Lista de Permissões em vez disso"' },
  {
    search: 'SANDBOX_MODE:"Commands run in a protected sandbox that limits access to your files, network, and git. You can allowlist specific commands to run with full access when needed. Be cautious of potential prompt injection risks."',
    replace: 'SANDBOX_MODE:"Os comandos são executados em uma sandbox protegida que limita o acesso aos seus arquivos, rede e git. Você pode colocar comandos específicos na lista de permissões para executar com acesso total quando necessário. Tenha cuidado com possíveis riscos de injeção de prompt."'
  },
  {
    search: 'ALLOWLIST_MODE:"Only commands you\'ve added to your allowlist will run automatically. Other commands will require user approval. Be cautious of potential prompt injection risks."',
    replace: 'ALLOWLIST_MODE:"Apenas os comandos adicionados à sua lista de permissões serão executados automaticamente. Outros comandos exigirão aprovação do usuário. Tenha cuidado com possíveis riscos de injeção de prompt."'
  },
  {
    search: 'RUN_EVERYTHING_SANDBOX_AVAILABLE:"This allows the agent to execute any tool or shell command without approval. A prompt injection or a malicious tool could delete files or exfiltrate secrets from your machine. We recommend using Sandbox."',
    replace: 'RUN_EVERYTHING_SANDBOX_AVAILABLE:"Isso permite que o agente execute qualquer ferramenta ou comando de shell sem aprovação. Uma injeção de prompt ou uma ferramenta maliciosa pode excluir arquivos ou extrair segredos da sua máquina. Recomendamos o uso do Sandbox."'
  },
  {
    search: 'RUN_EVERYTHING_SANDBOX_UNAVAILABLE:"This allows the agent to execute any tool or shell command without approval. A prompt injection or a malicious tool could delete files or exfiltrate secrets from your machine. We recommend using Allowlist."',
    replace: 'RUN_EVERYTHING_SANDBOX_UNAVAILABLE:"Isso permite que o agente execute qualquer ferramenta ou comando de shell sem aprovação. Uma injeção de prompt ou uma ferramenta maliciosa pode excluir arquivos ou extrair segredos da sua máquina. Recomendamos o uso da Lista de Permissões."'
  },

  // Menus de Contexto, Terminal, Favoritos e Diagnóstico (Emerson Teles)
  { search: 'label:"Mark as Unread"', replace: 'label:"Marcar como Não Lido"' },
  { search: 'tooltip:"Mark chat as unread"', replace: 'tooltip:"Marcar chat como não lido"' },
  { search: 'title:"Bookmark This Page"', replace: 'title:"Adicionar Esta Página aos Favoritos"' },
  { search: 'title:"Remove Bookmark"', replace: 'title:"Remover dos Favoritos"' },
  { search: '"aria-label":ft?"Remove Bookmark":"Bookmark This Page"', replace: '"aria-label":ft?"Remover dos Favoritos":"Adicionar Esta Página aos Favoritos"' },
  { search: 'label:"Close Terminal"', replace: 'label:"Fechar Terminal"' },
  { search: 'title:"Close Terminal?"', replace: 'title:"Fechar Terminal?"' },
  { search: 'ee=p?"Kill Terminal":"Close Terminal"', replace: 'ee=p?"Encerrar Terminal":"Fechar Terminal"' },
  { search: 'title:"Delete Cloud-Agent Cache"', replace: 'title:"Excluir Cache do Agente em Nuvem"' },
  { search: 'title:"GC Agent KV Blobs"', replace: 'title:"Coletar Lixo de Blobs KV do Agente"' },
  { search: 'title:{value:"GC Agent KV Blobs",original:"GC Agent KV Blobs"}', replace: 'title:{value:"Coletar Lixo de Blobs KV do Agente",original:"GC Agent KV Blobs"}' },
  { search: 'title:"Workspace Diagnostics"', replace: 'title:"Diagnóstico do Espaço de Trabalho"' },
  { search: 'title:"Display Workspace Metadata"', replace: 'title:"Exibir Metadados do Espaço de Trabalho"' },
  { search: 'title:"Display Explorer Orchestrator Cache"', replace: 'title:"Exibir Cache do Orquestrador do Explorer"' },
  { search: 'messagePrefix:"GC Agent KV Blobs"', replace: 'messagePrefix:"Coletar Lixo de Blobs KV do Agente"' },
  { search: '"GC Agent KV Blobs: starting..."', replace: '"Coletar Lixo de Blobs KV do Agente: iniciando..."' },
  { search: 'label:"New Output View"', replace: 'label:"Nova Visualização de Saída"' },
  { search: 'label:"Hide Sidebar"', replace: 'label:"Ocultar Barra Lateral"' },
  { search: 'label:"Hide Apps Panel"', replace: 'label:"Ocultar Painel de Aplicativos"' },

  // Diálogo Sobre (About) e Atualizações (Emerson Teles)
  { search: 'aboutDialog.copyVersionInfo","Copy version info"', replace: 'aboutDialog.copyVersionInfo","Copiar informações de versão"' },
  { search: 'aboutDialog.copyVersion","Copy version"', replace: 'aboutDialog.copyVersion","Copiar versão"' },
  { search: 'aboutDialog.copyBuildDate","Copy build date"', replace: 'aboutDialog.copyBuildDate","Copiar data de compilação"' },
  // Crédito na janela Sobre nativa (janela auxiliar, fora do DOM principal).
  {
    search: 'p6(No,{as:"div",color:"tertiary",size:"xs",className:"glass-1ghz6dp glass-euugli glass-1717udv glass-2b8uid",children:i.copyright})',
    replace: 'p6(No,{as:"div",color:"tertiary",size:"xs",className:"glass-1ghz6dp glass-euugli glass-1717udv glass-2b8uid",children:i.copyright}),p6(No,{as:"div",color:"tertiary",size:"xs",style:{color:"#00adb5",fontWeight:400,marginTop:6},children:"Tradução PT-BR: Emerson Teles"})'
  },
  { search: 'Ee(11435,"Check for Updates...")', replace: 'Ee(11435,"Verificar Atualizações...")' },
  { search: 'Ee(11436,"Checking for Updates...")', replace: 'Ee(11436,"Verificando Atualizações...")' },
  { search: 'Ee(11437,"Download Update")', replace: 'Ee(11437,"Baixar Atualização")' },
  { search: 'Ee(11438,"Downloading Update...")', replace: 'Ee(11438,"Baixando Atualização...")' },
  { search: 'Ee(11439,"Install Update")', replace: 'Ee(11439,"Instalar Atualização")' },
  { search: 'Ee(11440,"Installing Update...")', replace: 'Ee(11440,"Instalando Atualização...")' },
  { search: 'M6y="No updates available"', replace: 'M6y="Nenhuma atualização disponível"' },
  { search: 'P6y="Updates unavailable"', replace: 'P6y="Atualizações indisponíveis"' },

  // Neutralizar alerta de instalação corrompida (IntegrityService)
  { search: 'async _compute(){const{isPure:e}=await this.isPure();if(e||await this._isExplainedByPendingUpdate())return;', replace: 'async _compute(){return;' },
  { search: 't?.dontShowPrompt&&t.commit===this.productService.commit||this._showNotification()', replace: 'false&&this._showNotification()' },
  { search: 'async _isPure(){const e=this.productService.checksums||{};', replace: 'async _isPure(){return{isPure:!0,proof:[]};const e=this.productService.checksums||{};' },

  // Correção de Encoding / Mojibake
  { search: 'label:"PadrÃ£o"', replace: 'label:"Padrão"' },
  { search: '"PadrÃ£o"', replace: '"Padrão"' },
  { search: 'label:"Ãšltimas Janelas Utilizadas"', replace: 'label:"Últimas Janelas Utilizadas"' },
  { search: '"Ãšltimas Janelas Utilizadas"', replace: '"Últimas Janelas Utilizadas"' },

  // Diálogos de Configurações e Avisos
  { search: 'KSy=\'Reset "Don\\u2019t Ask Again" Dialogs\'', replace: 'KSy=\'Redefinir Diálogos "Não Perguntar Novamente"\'' },
  { search: 'description:"See warnings and tips that you\\u2019ve hidden"', replace: 'description:"Veja avisos e dicas que você ocultou"' },
  { search: 'label:"About Allowlist"', replace: 'label:"Sobre a Lista de Permissões"' },
  { search: 'label:"Run Everything Mode Warning"', replace: 'label:"Aviso do Modo Executar Tudo"' }
];

for (const file of workbenchFiles) {
  if (!fs.existsSync(file)) continue;
  const shortName = path.basename(file);
  
  // Patchar somente a cópia limpa salva da instalação e versão exatas.
  const candidateBackups = [
    versionBackupDir && path.join(versionBackupDir, 'workbench', shortName)
  ];
  let baseFile = null;
  for (const cb of candidateBackups) {
    if (cb && fs.existsSync(cb)) {
      baseFile = cb;
      break;
    }
  }

  if (!baseFile) {
    throw new Error(`Base original da versão instalada não encontrada: ${shortName}. A instalação foi interrompida para proteger o Cursor.`);
  }

  let content = fs.readFileSync(baseFile, 'utf8');
  let count = 0;

  if (shortName === 'workbench.desktop.main.js') {
    for (const item of REPLACEMENTS) {
      if (content.includes(item.search)) {
        content = content.replaceAll(item.search, item.replace);
        count++;
      }
    }
  }

  // O diálogo Sobre existe nos dois renderizadores. Altere somente o copyright
  // dentro do componente Glass About, usando a cópia limpa desta compilação.
  const aboutCredit = 'Tradução PT-BR: Emerson Teles';
  const aboutStart = content.indexOf('"data-component":"glass-about-dialog-window"');
  if (aboutStart < 0) {
    throw new Error(`Componente Glass About não encontrado em ${shortName}; o crédito não foi aplicado.`);
  }
  const aboutEnd = content.indexOf('async function', aboutStart);
  const regionEnd = aboutEnd < 0 ? content.length : aboutEnd;
  let aboutRegion = content.slice(aboutStart, regionEnd);
  if (!aboutRegion.includes(aboutCredit)) {
    const copyrightNode = /([A-Za-z_$][\w$]*)\(([A-Za-z_$][\w$]*),\{as:"div",color:"tertiary",size:"xs",className:"[^"]+",children:([A-Za-z_$][\w$]*\.copyright)\}\)/;
    if (!copyrightNode.test(aboutRegion)) {
      throw new Error(`Campo de direitos autorais do Glass About não localizado em ${shortName}; o crédito não foi aplicado.`);
    }
    aboutRegion = aboutRegion.replace(copyrightNode, (full, createElement, component) =>
      `${full},${createElement}(${component},{as:"div",color:"tertiary",size:"xs",style:{color:"#00adb5",fontWeight:400,marginTop:6},children:"${aboutCredit}"})`
    );
    content = content.slice(0, aboutStart) + aboutRegion + content.slice(regionEnd);
    count++;
  }
  console.log(`    -> Crédito "${aboutCredit}" inserido/verificado no Glass About de ${shortName} (turquesa).`);

  // O dicionário fica ao lado do bundle principal e não interfere no Glass nem no runtime React.
  if (shortName === 'workbench.desktop.main.js' && !content.includes('import "./cursor-pt-dict.js";')) {
    content += '\nimport "./cursor-pt-dict.js";\n';
    count++;
  }

  fs.writeFileSync(file, content, 'utf8');
  console.log(`    [+] ${shortName}: ${count} padrões aplicados a partir do backup original da versão ${path.basename(versionBackupDir)}.`);
}
