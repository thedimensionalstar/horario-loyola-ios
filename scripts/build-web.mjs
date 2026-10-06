// Prepara la carpeta www/: empaqueta el puente nativo y copia las fuentes para que la app funcione sin conexión.
import { build } from 'esbuild';
import { access, cp, mkdir, rm, writeFile } from 'node:fs/promises';

await build({
  entryPoints: ['src/native.js'],
  bundle: true,
  format: 'iife',
  target: ['safari15'],
  minify: true,
  outfile: 'www/native.js',
});
console.log('✓ www/native.js');

const fonts = ['bricolage-grotesque', 'figtree', 'jetbrains-mono'];
await rm('www/fonts', { recursive: true, force: true });
await mkdir('www/fonts', { recursive: true });
const imports = [];
for (const name of fonts) {
  const base = `node_modules/@fontsource-variable/${name}`;
  try {
    await access(`${base}/index.css`);
    await mkdir(`www/fonts/${name}`, { recursive: true });
    await cp(`${base}/index.css`, `www/fonts/${name}/index.css`);
    await cp(`${base}/files`, `www/fonts/${name}/files`, { recursive: true });
    imports.push(`@import url("${name}/index.css");`);
    console.log(`✓ fuente ${name}`);
  } catch {
    console.warn(`! No se encontró la fuente ${name}; la app usará la del sistema.`);
  }
}
await writeFile('www/fonts/fonts.css', imports.join('\n') + '\n');
