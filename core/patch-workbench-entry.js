import fs from 'node:fs';
import path from 'node:path';

const cursorDir = process.argv[2];
const backupRoot = process.argv[3];
if (!cursorDir || !backupRoot) {
  throw new Error('Uso: node patch-workbench-entry.js <Cursor> <backup da versão e compilação>');
}

const relative = path.join('out', 'vs', 'code', 'electron-sandbox', 'workbench', 'workbench.js');
const target = path.join(cursorDir, 'resources', 'app', relative);
const original = path.join(backupRoot, 'workbench-entry', 'workbench.js');
const marker = 'cursor-pt-dict.js';

if (!fs.existsSync(original)) throw new Error(`Backup original do ponto de entrada Glass não encontrado: ${original}`);
let source = fs.readFileSync(original, 'utf8');
if (source.includes(marker)) throw new Error('O backup do workbench.js já contém o marcador PT-BR; backup não é limpo.');
const anchors = [
  {
    // Estrutura usada até a série 3.24.x.
    regex: /([\w$]+)\.glass===!0&&([\w$]+)\(\),([\w$]+)\(\1\),Object\.defineProperty\(window,"vscodeWindowId"/,
    replace: m => `${m[1]}.glass===!0&&(${m[2]}(),import("../../../workbench/cursor-pt-dict.js").catch(e=>console.warn("Cursor PT-BR Glass dictionary unavailable",e))),${m[3]}(${m[1]}),Object.defineProperty(window,"vscodeWindowId"`
  },
  {
    // A 3.27.x separou o splash Glass, a inicialização local e o carregamento do host.
    regex: /([\w$]+)\.glass===!0&&([\w$]+)\(\),([\w$]+)\(\),([\w$]+)\(\1\),Object\.defineProperty\(window,"vscodeWindowId"/,
    replace: m => `${m[1]}.glass===!0&&(${m[2]}(),import("../../../workbench/cursor-pt-dict.js").catch(e=>console.warn("Cursor PT-BR Glass dictionary unavailable",e))),${m[3]}(),${m[4]}(${m[1]}),Object.defineProperty(window,"vscodeWindowId"`
  }
];
const selected = anchors.map(item => ({ ...item, match: source.match(item.regex) })).find(item => item.match);
if (!selected) throw new Error('Ponto de entrada Glass desconhecido nesta versão; nenhum arquivo foi alterado.');
source = source.replace(selected.regex, selected.replace(selected.match));
if (!source.includes('import("../../../workbench/cursor-pt-dict.js")')) throw new Error('Falha ao inserir o carregador PT-BR no Glass.');
fs.writeFileSync(target, source, 'utf8');
console.log('Ponto de entrada Glass preparado para carregar o dicionário PT-BR sem modificar o bundle Glass.');
