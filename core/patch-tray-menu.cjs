const fs = require('node:fs');
const path = require('node:path');

const [cursorDir, versionBackupDir] = process.argv.slice(2);
if (!cursorDir || !versionBackupDir) {
  console.error('Uso: node patch-tray-menu.cjs <pasta-do-Cursor> <backup-da-versão>');
  process.exit(2);
}

const livePath = path.join(cursorDir, 'resources', 'app', 'out', 'main.js');
const backupPath = path.join(versionBackupDir, 'electron-main', 'main.js');
if (!fs.existsSync(backupPath)) throw new Error(`Backup original do menu nativo não encontrado: ${backupPath}`);
if (!fs.existsSync(livePath)) throw new Error(`Arquivo do menu nativo não encontrado: ${livePath}`);

let source = fs.readFileSync(backupPath, 'utf8');
const replacements = [
  ['label:"Clear All Notifications"', 'label:"Limpar todas as notificações"'],
  ['label:"Open Cursor"', 'label:"Abrir o Cursor"'],
  ['label:"Settings"', 'label:"Configurações"'],
  ['label:"Quit"', 'label:"Sair"']
];
for (const [before, after] of replacements) {
  if (source.includes(after)) continue;
  const count = source.split(before).length - 1;
  if (count !== 1) throw new Error(`A opção nativa mudou ou não é única (${before}); nenhum arquivo foi gravado.`);
  source = source.replace(before, after);
}

const current = fs.readFileSync(livePath, 'utf8');
if (current === source) {
  console.log('    [i] Menu nativo da bandeja do Cursor já está atualizado.');
  process.exit(0);
}
const tempPath = `${livePath}.ptbr-${process.pid}.tmp`;
fs.writeFileSync(tempPath, source, 'utf8');
if (fs.readFileSync(tempPath, 'utf8') !== source) {
  fs.rmSync(tempPath, { force: true });
  throw new Error('A cópia temporária do menu nativo não passou na verificação.');
}
fs.renameSync(tempPath, livePath);
console.log('    [OK] Menu nativo da bandeja do Cursor traduzido.');
