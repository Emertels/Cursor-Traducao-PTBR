// Compatibility entry point. UI strings are scanned in the active Cursor build.
const path = require('path');
const { spawnSync } = require('child_process');

const scanner = path.join(__dirname, 'tools', 'scan-untranslated.cjs');
const result = spawnSync(process.execPath, [scanner, ...process.argv.slice(2)], { stdio: 'inherit' });
process.exit(result.status ?? 1);
