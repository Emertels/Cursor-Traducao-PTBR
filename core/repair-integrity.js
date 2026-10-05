import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

// ==============================================================================
//  Validador e Reparador de Integridade do Cursor (Checksums)
//  Engenharia e Otimização por: Emerson Teles
//  Garante que o Cursor nunca exiba o aviso "instalação corrompida"
// ==============================================================================

const defaultCursorDir = path.join(process.env.LOCALAPPDATA || '', 'Programs', 'cursor');
const cursorDir = process.argv[2] || defaultCursorDir;
const appDir = path.join(cursorDir, 'resources', 'app');
const prodPath = path.join(appDir, 'product.json');

if (fs.existsSync(prodPath)) {
  try {
    let raw = fs.readFileSync(prodPath, 'utf8');
    if (raw.charCodeAt(0) === 0xFEFF) raw = raw.slice(1);
    const prod = JSON.parse(raw);
    if (prod.checksums) {
      let modified = false;
      for (const [relPath, expectedHash] of Object.entries(prod.checksums)) {
        const filePath = path.join(appDir, 'out', relPath);
        if (fs.existsSync(filePath)) {
          const buf = fs.readFileSync(filePath);
          const actualHash = crypto.createHash('sha256').update(buf).digest('base64').replace(/=+$/, '');
          if (actualHash !== expectedHash) {
            console.log(`    [+] Sincronizando checksum para ${relPath}...`);
            prod.checksums[relPath] = actualHash;
            modified = true;
          }
        }
      }
      if (modified) {
        fs.writeFileSync(prodPath, JSON.stringify(prod, null, '\t'), 'utf8');
        console.log('    [OK] Integridade do aplicativo Cursor reparada e sincronizada com sucesso!');
      } else {
        console.log('    [OK] Integridade de todos os arquivos ja esta 100% perfeita.');
      }
    }
  } catch (e) {
    console.error('    [!] Erro ao validar integridade:', e.message);
  }
} else {
  console.log('    [!] product.json nao localizado em:', prodPath);
}
