const fs = require('fs');
const path = require('path');

// 1. Caminho da extensão SSH do Cursor
const sshExtPath = path.join(process.env.USERPROFILE, '.cursor', 'extensions', 'anysphere.remote-ssh-1.1.16', 'dist', 'main.js');

if (fs.existsSync(sshExtPath)) {
  let content = fs.readFileSync(sshExtPath, 'utf8');
  let count = 0;

  const t1_src = 'r.title="Select configured SSH host or enter an SSH destination"';
  const t1_dst = 'r.title="Selecione o host SSH configurado ou insira um destino SSH"';

  const t2_src = 'r.placeholder="e.g. ubuntu@ec2-3-106-99.amazonaws.com, ssh -i key user@host, or named host below"';
  const t2_dst = 'r.placeholder="ex.: ubuntu@ec2-3-106-99.amazonaws.com, ssh -i chave usuario@host ou host nomeado abaixo"';

  const t3_src = 'g="$(add) Add New SSH Host..."';
  const t3_dst = 'g="$(add) Adicionar Novo Host SSH..."';

  const t4_src = 'p="Configure SSH Hosts..."';
  const t4_dst = 'p="Configurar Hosts SSH..."';

  if (content.includes(t1_src)) { content = content.replace(t1_src, t1_dst); count++; }
  if (content.includes(t2_src)) { content = content.replace(t2_src, t2_dst); count++; }
  if (content.includes(t3_src)) { content = content.replace(t3_src, t3_dst); count++; }
  if (content.includes(t4_src)) { content = content.replace(t4_src, t4_dst); count++; }

  if (count > 0) {
    fs.writeFileSync(sshExtPath, content, 'utf8');
    console.log(`[+] Cursor Remote-SSH corrigido com sucesso! (${count} alterações aplicadas)`);
  } else {
    console.log('[-] Cursor Remote-SSH já está traduzido.');
  }
} else {
  console.log('[!] Extensão anysphere.remote-ssh não encontrada em:', sshExtPath);
}
