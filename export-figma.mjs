#!/usr/bin/env node
// export-figma.mjs — ekspor SEMUA layar desain SIMWAR dari Figma ke folder lokal.
//
// Pakai:   FIGMA_TOKEN=figd_xxx node export-figma.mjs [--out figma-export] [--scale 2] [--archive] [--no-png]
// Butuh:   Node 18+ dan internet. Token: Figma > Settings > Security > Personal access tokens
//          (scope: File content = Read-only). JANGAN tempel token ke chat atau commit ke git.
//
// Hasil di --out:
//   manifest.json            daftar semua layar (id, nama, section, grup, ukuran, path png/spec/json)
//   tokens.json              warna, font, radius, shadow yang dipakai (dengan jumlah pemakaian)
//   screens/<section>/*.png  screenshot referensi tiap layar (target visual)
//   spec/<section>/*.md      outline terstruktur tiap layar (koordinat, warna, teks, font, aset)
//   json/*.json              JSON mentah Figma per layar (sumber kebenaran paling lengkap)
//   assets/icons/*.svg       ikon (SVG asli dari Figma)
//   assets/illustrations/    ilustrasi/dekorasi (SVG asli)
//   assets/images/           gambar raster (jika ada)
//   README.md                ringkasan hasil ekspor

import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';

// ---------- konfigurasi file ----------
const FILE_KEY = 'PYGhjINDLB7fWCguQ0TevK';
const SECTIONS = { '2074:2': 'keseluruhan', '2074:5': 'pemilik', '2074:13': 'penjaga' }; // halaman "Desain Berwarna"
const ARCHIVE_PAGES = { '0:1': 'arsip-varian', '2067:122': 'arsip-beranda-lama' };

// ---------- argumen ----------
const argv = process.argv.slice(2);
const flag = (n) => argv.includes(`--${n}`);
const opt = (n, d) => { const i = argv.indexOf(`--${n}`); return i >= 0 && argv[i + 1] ? argv[i + 1] : d; };
const OUT = opt('out', 'figma-export');
const SCALE = Number(opt('scale', '2'));
const TOKEN = process.env.FIGMA_TOKEN;
if (!TOKEN) {
  console.error('FIGMA_TOKEN belum di-set. Contoh: FIGMA_TOKEN=figd_xxx node export-figma.mjs');
  process.exit(1);
}

// ---------- util ----------
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const safeId = (id) => id.replace(/[:;]/g, '-');
const slug = (s) => s.toLowerCase().normalize('NFKD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 60) || 'tanpa-nama';
const chunk = (arr, n) => Array.from({ length: Math.ceil(arr.length / n) }, (_, i) => arr.slice(i * n, i * n + n));
const hex2 = (v) => Math.round(v * 255).toString(16).padStart(2, '0').toUpperCase();
const hexOf = (c) => `#${hex2(c.r)}${hex2(c.g)}${hex2(c.b)}`;

async function api(pathname, params = {}) {
  const url = new URL('https://api.figma.com' + pathname);
  for (const [k, v] of Object.entries(params)) url.searchParams.set(k, v);
  for (let attempt = 0; attempt < 8; attempt++) {
    const res = await fetch(url, { headers: { 'X-Figma-Token': TOKEN } });
    if (res.status === 429) {
      const wait = Number(res.headers.get('retry-after') || 15);
      console.log(`  rate limit, tunggu ${wait}s...`);
      await sleep(wait * 1000);
      continue;
    }
    if (!res.ok) throw new Error(`${res.status} ${url.pathname}: ${(await res.text()).slice(0, 300)}`);
    return res.json();
  }
  throw new Error('Kena rate limit terlalu lama; coba lagi nanti.');
}

async function download(url, dest) {
  for (let attempt = 0; attempt < 4; attempt++) {
    const res = await fetch(url);
    if (res.ok) {
      await mkdir(path.dirname(dest), { recursive: true });
      await writeFile(dest, Buffer.from(await res.arrayBuffer()));
      return;
    }
    await sleep(1500 * (attempt + 1));
  }
  throw new Error(`Gagal mengunduh ${url}`);
}

async function pool(items, limit, fn) {
  let i = 0;
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, async () => {
    while (i < items.length) { const idx = i++; await fn(items[idx], idx); }
  }));
}

function walk(node, visit, parent = null) {
  if (visit(node, parent) === false) return;
  for (const c of node.children || []) walk(c, visit, node);
}

const VECTOR_TYPES = new Set(['VECTOR', 'BOOLEAN_OPERATION', 'ELLIPSE', 'RECTANGLE', 'LINE', 'STAR', 'REGULAR_POLYGON', 'POLYGON']);
const solidFills = (n) => (n.fills || []).filter((f) => f.visible !== false && f.type === 'SOLID');
const colorOf = (f) => {
  const a = (f.opacity ?? 1) * (f.color.a ?? 1);
  return hexOf(f.color) + (a < 0.995 ? `@${a.toFixed(2)}` : '');
};

// ---------- deteksi aset ----------
const isIconName = (n) => /^(ikon|icon)\b/i.test(n.name) || /^status bar ikon/i.test(n.name);
const isIllustrationName = (n) => /^(dekorasi|ilustrasi)/i.test(n.name);
const onlyVectors = (n) => {
  let ok = true;
  walk(n, (x) => { if (x !== n && !VECTOR_TYPES.has(x.type) && !['FRAME', 'GROUP'].includes(x.type)) ok = false; });
  return ok;
};
const firstColor = (n) => {
  let c = '';
  walk(n, (x) => {
    if (c) return false;
    for (const f of [...(x.strokes || []), ...(x.fills || [])]) {
      if (f.visible !== false && f.type === 'SOLID') { c = hexOf(f.color); return false; }
    }
  });
  return c;
};

// ---------- outline per layar ----------
function outline(root, assetByNode) {
  const rb = root.absoluteBoundingBox || { x: 0, y: 0 };
  const lines = [];
  const rel = (n) => {
    const b = n.absoluteBoundingBox;
    return b ? `${Math.round(b.x - rb.x)},${Math.round(b.y - rb.y)} ${Math.round(b.width)}x${Math.round(b.height)}` : '';
  };
  const go = (n, d) => {
    if (n.visible === false) return;
    const pad = '  '.repeat(d);
    const asset = assetByNode.get(n.id);
    let s = `${pad}- [${n.type}] ${n.name} @ ${rel(n)}`;
    const f = solidFills(n)[0];
    if (f) s += ` fill ${colorOf(f)}`;
    else if ((n.fills || []).some((x) => x.visible !== false && x.type?.startsWith('GRADIENT'))) s += ' fill gradient';
    if ((n.fills || []).some((x) => x.visible !== false && x.type === 'IMAGE')) s += ' fill IMAGE';
    const st = (n.strokes || []).find((x) => x.visible !== false && x.type === 'SOLID');
    if (st) s += ` stroke ${colorOf(st)} ${n.strokeWeight ?? ''}`.trimEnd();
    if (n.rectangleCornerRadii) s += ` radius ${n.rectangleCornerRadii.join('/')}`;
    else if (n.cornerRadius) s += ` radius ${n.cornerRadius}`;
    const sh = (n.effects || []).find((e) => e.visible !== false && e.type === 'DROP_SHADOW');
    if (sh) s += ` shadow ${sh.offset?.x ?? 0},${sh.offset?.y ?? 0} blur ${sh.radius} ${hexOf(sh.color)}@${(sh.color.a ?? 1).toFixed(2)}`;
    if (n.opacity != null && n.opacity < 1) s += ` opacity ${n.opacity.toFixed(2)}`;
    if (n.type === 'TEXT') {
      const t = n.style || {};
      s += ` "${(n.characters || '').replace(/\n/g, '⏎')}" font ${t.fontFamily ?? '?'} w${t.fontWeight ?? '?'}${t.italic ? ' italic' : ''} ${t.fontSize ?? '?'}px`;
      if (t.letterSpacing) s += ` ls ${Math.round(t.letterSpacing * 100) / 100}`;
      if (t.lineHeightPx) s += ` lh ${Math.round(t.lineHeightPx)}`;
      if (t.textAlignHorizontal && t.textAlignHorizontal !== 'LEFT') s += ` align ${t.textAlignHorizontal.toLowerCase()}`;
    }
    if (asset) s += `  => ASET ${asset}`;
    lines.push(s);
    if (asset) return; // anak aset (vektor) tidak perlu diuraikan
    for (const c of n.children || []) go(c, d + 1);
  };
  go(root, 0);
  return lines.join('\n') + '\n';
}

// ---------- token ----------
function collectTokens(frames) {
  const colors = new Map(), fonts = new Map(), radii = new Map(), shadows = new Map(), strokes = new Map();
  const bump = (m, k) => m.set(k, (m.get(k) || 0) + 1);
  for (const fr of frames) {
    walk(fr.doc, (n) => {
      if (n.visible === false) return false;
      for (const f of solidFills(n)) bump(colors, colorOf(f));
      for (const f of (n.strokes || []).filter((x) => x.visible !== false && x.type === 'SOLID')) bump(strokes, `${colorOf(f)} w${n.strokeWeight ?? 1}`);
      if (n.type === 'TEXT' && n.style) {
        const t = n.style;
        bump(fonts, `${t.fontFamily} w${t.fontWeight}${t.italic ? ' italic' : ''} ${t.fontSize}px lh${Math.round(t.lineHeightPx || 0)} ls${Math.round((t.letterSpacing || 0) * 100) / 100}`);
      }
      if (n.rectangleCornerRadii) bump(radii, n.rectangleCornerRadii.join('/'));
      else if (n.cornerRadius) bump(radii, String(n.cornerRadius));
      for (const e of n.effects || []) {
        if (e.visible !== false && e.type === 'DROP_SHADOW') bump(shadows, `${e.offset?.x ?? 0},${e.offset?.y ?? 0} blur${e.radius} ${hexOf(e.color)}@${(e.color.a ?? 1).toFixed(2)}`);
      }
    });
  }
  const sorted = (m) => [...m.entries()].sort((a, b) => b[1] - a[1]).map(([value, count]) => ({ value, count }));
  return { colors: sorted(colors), strokes: sorted(strokes), fonts: sorted(fonts), radii: sorted(radii), shadows: sorted(shadows) };
}

// ---------- main ----------
async function main() {
  await mkdir(OUT, { recursive: true });
  const targets = { ...SECTIONS, ...(flag('archive') ? ARCHIVE_PAGES : {}) };

  // 1. daftar anak langsung tiap section/halaman
  console.log('1/6 Membaca daftar layar...');
  const listing = await api(`/v1/files/${FILE_KEY}/nodes`, { ids: Object.keys(targets).join(','), depth: 1 });
  const screens = []; // {id,name,section,box}
  const labels = {};  // section -> [{text,x,y,w}]
  const notes = {};   // section -> [{text,x,y}]
  for (const [secId, secName] of Object.entries(targets)) {
    const doc = listing.nodes?.[secId]?.document;
    if (!doc) { console.warn(`  ! node ${secId} (${secName}) tidak ditemukan`); continue; }
    labels[secName] = []; notes[secName] = [];
    for (const c of doc.children || []) {
      const b = c.absoluteBoundingBox || { x: 0, y: 0, width: 0, height: 0 };
      if (['FRAME', 'COMPONENT', 'INSTANCE'].includes(c.type)) {
        screens.push({ id: c.id, name: c.name, section: secName, box: b });
      } else if (c.type === 'TEXT') {
        const rec = { text: c.characters ?? c.name, name: c.name, x: b.x, y: b.y, w: b.width };
        (/^label grup/i.test(c.name) ? labels[secName] : notes[secName]).push(rec);
      }
    }
  }
  console.log(`  ${screens.length} layar ditemukan.`);

  // 2. ambil JSON penuh tiap layar (batch kecil)
  console.log('2/6 Mengunduh JSON layar...');
  const frames = [];
  const batches = chunk(screens, 6);
  let done = 0;
  await pool(batches, 3, async (batch) => {
    const res = await api(`/v1/files/${FILE_KEY}/nodes`, { ids: batch.map((s) => s.id).join(',') });
    for (const s of batch) {
      const doc = res.nodes?.[s.id]?.document;
      if (!doc) { console.warn(`  ! JSON ${s.id} kosong`); continue; }
      frames.push({ ...s, doc });
      await mkdir(path.join(OUT, 'json'), { recursive: true });
      await writeFile(path.join(OUT, 'json', `${safeId(s.id)}.json`), JSON.stringify(doc, null, 1));
    }
    done += batch.length;
    process.stdout.write(`  ${done}/${screens.length}\r`);
  });
  console.log('');
  frames.sort((a, b) => screens.findIndex((s) => s.id === a.id) - screens.findIndex((s) => s.id === b.id));

  // 3. deteksi aset
  console.log('3/6 Mendeteksi aset...');
  const assetByNode = new Map();   // nodeId -> relative path
  const iconKeys = new Map();      // key -> {id,file}
  const illusKeys = new Map();
  const imageRefs = new Set();
  const toSvg = [];                // {id,file}
  for (const fr of frames) {
    walk(fr.doc, (n) => {
      if (n.visible === false) return false;
      for (const f of n.fills || []) if (f.type === 'IMAGE' && f.imageRef && f.visible !== false) imageRefs.add(f.imageRef);
      const container = ['FRAME', 'GROUP', 'COMPONENT', 'INSTANCE'].includes(n.type);
      if (container && isIconName(n) && onlyVectors(n)) {
        const b = n.absoluteBoundingBox || { width: 0, height: 0 };
        const key = `${slug(n.name)}-${Math.round(b.width)}x${Math.round(b.height)}-${firstColor(n).replace('#', '') || 'x'}`;
        if (!iconKeys.has(key)) { iconKeys.set(key, { id: n.id, file: `assets/icons/${key}.svg` }); toSvg.push(iconKeys.get(key)); }
        assetByNode.set(n.id, iconKeys.get(key).file);
        return false;
      }
      if (container && isIllustrationName(n)) {
        const b = n.absoluteBoundingBox || { width: 0, height: 0 };
        const key = `${slug(n.name)}-${Math.round(b.width)}x${Math.round(b.height)}-${safeId(n.id)}`;
        if (!illusKeys.has(key)) { illusKeys.set(key, { id: n.id, file: `assets/illustrations/${key}.svg` }); toSvg.push(illusKeys.get(key)); }
        assetByNode.set(n.id, illusKeys.get(key).file);
        return false;
      }
    });
  }
  console.log(`  ${iconKeys.size} ikon unik, ${illusKeys.size} ilustrasi, ${imageRefs.size} gambar raster.`);

  // 4. ekspor SVG aset + gambar raster
  console.log('4/6 Mengekspor SVG aset...');
  for (const b of chunk(toSvg, 30)) {
    const r = await api(`/v1/images/${FILE_KEY}`, { ids: b.map((x) => x.id).join(','), format: 'svg', svg_include_id: 'false', svg_simplify_stroke: 'true' });
    await pool(b, 4, async (a) => {
      const url = r.images?.[a.id];
      if (url) await download(url, path.join(OUT, a.file)); else console.warn(`  ! SVG ${a.id} gagal`);
    });
  }
  if (imageRefs.size) {
    const r = await api(`/v1/files/${FILE_KEY}/images`);
    await pool([...imageRefs], 4, async (ref) => {
      const url = r.meta?.images?.[ref];
      if (url) await download(url, path.join(OUT, 'assets', 'images', `${ref}.png`));
    });
  }

  // 5. screenshot PNG
  const manifest = [];
  const labelFor = (s) => {
    const cands = (labels[s.section] || []).filter((l) => l.x <= s.box.x + 1 && s.box.x < l.x + l.w + 1 && l.y <= s.box.y + 1);
    cands.sort((a, b) => b.y - a.y);
    return cands[0]?.text?.replace(/^Label grup · /, '') ?? null;
  };
  const pngPath = (s) => `screens/${s.section}/${safeId(s.id)}__${slug(s.name)}.png`;
  if (!flag('no-png')) {
    console.log('5/6 Mengekspor screenshot PNG...');
    let n = 0;
    for (const b of chunk(frames, 10)) {
      const r = await api(`/v1/images/${FILE_KEY}`, { ids: b.map((x) => x.id).join(','), format: 'png', scale: SCALE });
      await pool(b, 4, async (s) => {
        const url = r.images?.[s.id];
        if (url) await download(url, path.join(OUT, pngPath(s))); else console.warn(`  ! PNG ${s.id} gagal`);
      });
      n += b.length; process.stdout.write(`  ${n}/${frames.length}\r`);
    }
    console.log('');
  } else console.log('5/6 PNG dilewati (--no-png).');

  // 6. spec, manifest, token
  console.log('6/6 Menulis spec, manifest, tokens...');
  for (const s of frames) {
    const specFile = `spec/${s.section}/${safeId(s.id)}__${slug(s.name)}.md`;
    const head = `# ${s.name}\n\n- Figma node: \`${s.id}\` (file \`${FILE_KEY}\`)\n- Section: ${s.section}\n- Grup: ${labelFor(s) ?? '-'}\n- Ukuran: ${Math.round(s.box.width)}x${Math.round(s.box.height)}\n- Screenshot: \`${pngPath(s)}\`\n\nKoordinat relatif ke pojok kiri-atas layar. Teks ditulis persis seperti di desain.\n\n`;
    await mkdir(path.join(OUT, path.dirname(specFile)), { recursive: true });
    await writeFile(path.join(OUT, specFile), head + outline(s.doc, assetByNode));
    manifest.push({ id: s.id, name: s.name, section: s.section, group: labelFor(s), width: Math.round(s.box.width), height: Math.round(s.box.height), x: Math.round(s.box.x), y: Math.round(s.box.y), png: pngPath(s), spec: specFile, json: `json/${safeId(s.id)}.json` });
  }
  await writeFile(path.join(OUT, 'manifest.json'), JSON.stringify({ fileKey: FILE_KEY, exportedAt: new Date().toISOString(), annotations: notes, groups: labels, screens: manifest }, null, 2));
  await writeFile(path.join(OUT, 'tokens.json'), JSON.stringify(collectTokens(frames), null, 2));

  const bySection = {};
  for (const m of manifest) (bySection[m.section] ??= []).push(m);
  let readme = `# Ekspor Figma SIMWAR\n\nDiekspor: ${new Date().toISOString()}\nFile: https://www.figma.com/design/${FILE_KEY}\n\n- ${manifest.length} layar, ${iconKeys.size} ikon, ${illusKeys.size} ilustrasi, ${imageRefs.size} gambar raster\n- Mulai dari \`manifest.json\` dan \`tokens.json\`; tiap layar punya screenshot (\`screens/\`), outline (\`spec/\`), dan JSON mentah (\`json/\`).\n\n`;
  for (const [sec, list] of Object.entries(bySection)) {
    readme += `## ${sec} (${list.length})\n\n`;
    let g = Symbol();
    for (const m of list) {
      if (m.group !== g) { g = m.group; readme += `\n**${g ?? 'Tanpa grup'}**\n\n`; }
      readme += `- ${m.name} — \`${m.id}\` — [spec](${m.spec})\n`;
    }
    readme += '\n';
  }
  await writeFile(path.join(OUT, 'README.md'), readme);
  console.log(`Selesai. Buka ${path.join(OUT, 'README.md')}`);
}

main().catch((e) => { console.error(e); process.exit(1); });
