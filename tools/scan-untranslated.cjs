const fs = require('fs');
const path = require('path');
const vm = require('vm');

const cursorDir = path.resolve(process.argv[2] || path.join(process.env.LOCALAPPDATA || '', 'Programs', 'cursor'));
const appDir = path.join(cursorDir, 'resources', 'app');
const workbenchDir = path.join(appDir, 'out', 'vs', 'workbench');
const bundlePaths = fs.existsSync(workbenchDir)
  ? fs.readdirSync(workbenchDir)
      .filter(name => /^workbench\..+\.js$/.test(name))
      .map(name => path.join(workbenchDir, name))
  : [];
const dictionaryPath = path.join(__dirname, '..', 'core', 'cursor-pt-dict.js');

if (!bundlePaths.includes(path.join(workbenchDir, 'workbench.desktop.main.js'))) {
  console.error(`Cursor main workbench bundle not found: ${path.join(workbenchDir, 'workbench.desktop.main.js')}`);
  process.exit(1);
}

const dictSource = fs.readFileSync(dictionaryPath, 'utf8');
const dictMatch = dictSource.match(/export\s+const\s+CURSOR_DICT\s*=\s*({[\s\S]*?\n});/);
if (!dictMatch) throw new Error('CURSOR_DICT object not found.');
const dictionary = vm.runInNewContext(`(${dictMatch[1]})`);
const translatedValues = new Set(Object.values(dictionary));
// Marcas e identificadores técnicos mantidos no idioma original por serem
// nomes próprios ou tokens internos, e não textos de interface traduzíveis.
const intentionalEnglish = new Set([
  'AWS Bedrock',
  'Azure OpenAI',
  'char-delete diff-range-empty',
  'char-insert diff-range-empty'
]);
const candidates = new Map();
const fields = /(?<![\w$])(?:label|title|description|placeholder|aria-label|header|buttonLabel|heading|subheading|children)\s*:\s*("(?:\\.|[^"\\]){3,240}")/g;
for (const currentBundle of bundlePaths) {
  const bundle = fs.readFileSync(currentBundle, 'utf8');
  let match;
  fields.lastIndex = 0;
  while ((match = fields.exec(bundle)) !== null) {
    let value;
    try { value = JSON.parse(match[1]).trim(); } catch { continue; }
    if (value.length < 4 || value.length > 220 || dictionary[value] || translatedValues.has(value) || intentionalEnglish.has(value)) continue;
    if (!/[A-Za-z]/.test(value) || !/\s/.test(value) || !/^[A-Za-z]/.test(value)) continue;
    if (/[áéíóúãõçàêô]/i.test(value)) continue;
    if (/^(?:https?:|file:|data:)/i.test(value) || /\b(?:Monaco|React|webpack)\s+(?:render|uniform|vertex|shader|pipeline|buffer|texture|sampler|bind group|command encoder)\b/i.test(value)) continue;
    if (/^(?:Copyright|©|\{\{|\$\{)/i.test(value)) continue;
    const sources = candidates.get(value) || new Set();
    sources.add(path.basename(currentBundle));
    candidates.set(value, sources);
  }
}

const result = [...candidates.keys()].sort((a, b) => a.localeCompare(b));
const candidateSources = Object.fromEntries(
  [...candidates].map(([value, sources]) => [value, [...sources].sort()])
);
let version = 'unknown';
let commit = 'unknown';
try {
  const pkg = JSON.parse(fs.readFileSync(path.join(appDir, 'package.json'), 'utf8'));
  version = pkg.version || version;
} catch { }
try {
  const product = JSON.parse(fs.readFileSync(path.join(appDir, 'product.json'), 'utf8'));
  commit = product.commit || commit;
} catch { }

const report = {
  cursorVersion: version,
  cursorCommit: commit,
  bundles: bundlePaths.map(file => path.basename(file)),
  bundleCount: bundlePaths.length,
  untranslatedCandidateCount: result.length,
  candidates: result,
  candidateSources
};

const outputPath = process.argv[3];
if (outputPath) {
  fs.writeFileSync(path.resolve(outputPath), JSON.stringify(report, null, 2), 'utf8');
  console.log(`Saved ${result.length} untranslated UI candidates for Cursor ${version} (${commit}) to ${path.resolve(outputPath)}`);
} else {
  console.log(`Cursor ${version} (${commit}): ${result.length} untranslated UI candidates found across ${bundlePaths.length} workbench bundles.`);
  for (const item of result) console.log(item);
}
