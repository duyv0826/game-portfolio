// 从 index.html 的 WORKS 数组生成静态作品卡，写入 WORKS_STATIC 标记区。
// 用途：JS 失效 / 被禁 / 搜索引擎抓取时，作品列表仍然存在（不再是空壳）。
// 用法：node scripts/build-works-static.js          （写入 index.html）
//       node scripts/build-works-static.js --check  （只校验是否同步，不回写）

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const FILE = path.join(ROOT, 'index.html');
const BEGIN = '<!-- WORKS_STATIC:BEGIN -->';
const END = '<!-- WORKS_STATIC:END -->';

const html = fs.readFileSync(FILE, 'utf8');

const start = html.indexOf('const WORKS = [');
if (start < 0) { console.error('找不到 WORKS 数组'); process.exit(1); }
const arrStart = html.indexOf('[', start);
let depth = 0, i = arrStart, end = -1;
let inStr = null, isEsc = false;
for (; i < html.length; i++) {
  const ch = html[i];
  if (inStr) {
    if (isEsc) { isEsc = false; continue; }
    if (ch === '\\') { isEsc = true; continue; }
    if (ch === inStr) { inStr = null; }
    continue;
  }
  if (ch === '"' || ch === "'" || ch === '`') { inStr = ch; continue; }
  if (ch === '[') depth++;
  else if (ch === ']') { depth--; if (depth === 0) { end = i; break; } }
}
if (end < 0) { console.error('WORKS 数组括号不闭合'); process.exit(1); }

const literal = html.slice(arrStart, end + 1);
let WORKS;
try {
  WORKS = eval('(' + literal + ')');
} catch (e) {
  console.error('WORKS 数组无法求值：' + e.message);
  process.exit(1);
}

const esc = s => String(s == null ? '' : s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;');

function card(w) {
  const tags = (w.tags || []).map(t => `<span class="tag">${esc(t)}</span>`).join('');
  return [
    `        <article class="work-card rv" data-type="${esc(w.type)}">`,
    `          <div class="work-cover">`,
    `            <img src="${esc(w.cover)}" alt="${esc(w.title)} 封面" loading="lazy" width="1280" height="720">`,
    `            <span class="work-no">${esc(w.no)}</span>`,
    `            <span class="work-status${w.link ? ' playable' : ''}">${esc(w.status)}</span>`,
    `          </div>`,
    `          <div class="work-body">`,
    `            <p class="work-type">${esc(w.type)}</p>`,
    `            <h3 class="work-title">${esc(w.title)}</h3>`,
    `            <p class="work-desc">${esc(w.desc)}</p>`,
    `            <div class="work-tags">${tags}</div>`,
    `          </div>`,
    `        </article>`
  ].join('\n');
}

const block = [
  BEGIN,
  '      <!-- 本区块由 scripts/build-works-static.js 自动生成，勿手改；改完 WORKS 后重跑脚本 -->',
  '      <div class="works-grid" id="worksGrid">',
  WORKS.map(card).join('\n'),
  '      </div>',
  END
].join('\n');

const bIdx = html.indexOf(BEGIN);
const eIdx = html.indexOf(END);
if (bIdx < 0 || eIdx < bIdx) { console.error('找不到 WORKS_STATIC 标记'); process.exit(1); }

const next = html.slice(0, bIdx) + block + html.slice(eIdx + END.length);

if (process.argv.includes('--check')) {
  const synced = html.slice(bIdx, eIdx + END.length) === block;
  console.log(synced ? '静态作品卡与 WORKS 同步' : '静态作品卡与 WORKS 不同步，请重跑 node scripts/build-works-static.js');
  process.exit(synced ? 0 : 2);
}

fs.writeFileSync(FILE, next, 'utf8');
console.log(`已写入 ${WORKS.length} 张静态作品卡`);
