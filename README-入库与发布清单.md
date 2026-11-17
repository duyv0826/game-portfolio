# 作品集 · 入库与发布清单

适用范围：给 `D:\projects\game-portfolio` 新增作品、或改动已有作品后发布前自查。
本文件是操作手册，不是项目介绍（项目介绍见 `README.md`）。

---

## 0. 当前基线（每次动手前先核对，不匹配就先停下）

| 项 | 值 |
|---|---|
| 数据源 | `index.html` 内 `const WORKS = [...]`（约第 823 行起，唯一数据源） |
| 作品条数 | 19 条，`no` 为 `00`–`18` |
| 封面 | `assets/work-1.jpg` – `assets/work-19.jpg`（19 张） |
| 附册 | `开发过程与设计思路.html`（每作品 概述 / 开发过程 / 设计思路 / 复盘 四段），锚点 `DOC_ANCHORS w01–w17` 对应 `NO.02–NO.18` |
| 链接字段 | 有 `link`（试玩/在线页）：00、01、08、10、11、12、13、15；有 `github`：14、15、16、17；**两者皆无：02、03、04、05、06、07、09、18 共 8 条**。这 8 条在卡片正面有一枚「附册全文 · 开发过程与设计思路 ↗」入口（`DOC_ANCHORS` 锚点，2026-11-17 加），点它不会触发弹窗（`onclick="event.stopPropagation()"`） |
| `story` 段数 | 3 段为多数；2 段：05、07、16；4 段：18 |
| 备份目录 | `_backup/`，命名 `index-v<NN>-<YYYYMMDD>.html`，当前到 `v28` |
| 主部署 | GitHub Pages，`master` 根目录 → https://duyv0826.github.io/game-portfolio/ |
| 仓库 | `duyv0826/game-portfolio`（public） |
| 归档部署 | 豆包妙搭 `app_17dzfrpfs2x`（保留不动，不再作为主部署） |

**两条容易踩的偏移**

1. 封面号与作品号不是同一套序列：`assets/work-N.jpg` 里的 N 是历史累积顺序，`no` 是作品编号，两者当前错开一位。**不要按 `no` 推算封面文件名**，去 `assets/` 里数实际文件。
2. 编号与附册锚点是绑死的：改 `no` 会打断 `DOC_ANCHORS` 跳转。

---

## A. 新作品入库（10 步）

### 1. 定编号
取 `WORKS` 里当前最大的 `no` + 1（现在最大 `18`，下一个 `19`）。
**禁止为置顶而重排编号**；要置顶就调整数组展示顺序，编号保持稳定。

### 2. 截封面
- Edge headless，1280×720；作品有演示态就用 `?demo=…` 的真实界面态，不用开发中界面。
- PIL 转 JPEG，存为 `assets/work-<下一个N>.jpg`，体积 ≤200KB。
- 不允许出现平台水印；`assets/_ai_backup/` 或 `_backup/` 里的图不得上线。

### 3. 写 `desc`（首屏那一句）
- 长度 55–86 字（80 字以上只容忍少数几条）。
- 结构固定：**约束 → 取舍 → 证据**。
- 证据必须能被追问到出处（测试数量、仿真局数、实测毫秒数）。没有样本量的百分比一律不写。

### 4. 写 `detail` 与 `story`
- `detail`：补口径与边界。写明哪些数字来自仿真/bot、哪些来自真人，不许混写。
- `story`：新作品统一写 3 段 —— ①这是什么 ②为什么这样做 ③凭什么说它成立。现状是 2–4 段不等，见第 0 节，不要照抄残缺条目。
- 其他字段保持同一形状：`no / title / type / status / tags / cover / desc / detail / story / link`，有仓库的加 `github`，有操作说明的加 `hint`。

### 5. 附册同步
在 `开发过程与设计思路.html` 新增该作品一节，四段齐全（概述 / 开发过程 / 设计思路 / 复盘），并补对应 `DOC_ANCHORS` 条目。缺一段视为未完成。

### 6. 先备份再改
把 `index.html` 复制为 `_backup/index-v28-YYYYMMDD.html`（附册改动同样备份 `thesis-*.html` 版）。备份必须在编辑之前完成。

### 7. 本地校验（必须跑）
在项目根目录执行：

```js
// check-works.js —— node check-works.js
const fs = require('fs');
const src = fs.readFileSync('index.html', 'utf8');
const m = src.match(/const WORKS = (\[[\s\S]*?\n\];)/);
if (!m) { console.error('找不到 WORKS 数组'); process.exit(1); }
const WORKS = new Function('return ' + m[1].replace(/;$/, ''))();

const need = ['no','title','type','status','tags','cover','desc','detail','story'];
let bad = 0;
for (const w of WORKS) {
  const miss = need.filter(k => w[k] === undefined || w[k] === '');
  if (miss.length) { console.log('缺字段', w.no, miss); bad++; }
  if (!w.link && !w.github) { console.log('无入口(link/github 皆空)', w.no); bad++; }
  if (!Array.isArray(w.story) || w.story.length < 3) { console.log('story 不足3段', w.no, (w.story||[]).length); }
  if (!fs.existsSync(w.cover)) { console.log('封面不存在', w.no, w.cover); bad++; }
  if (w.desc && w.desc.length > 86) { console.log('desc 偏长', w.no, w.desc.length); bad++; }
}
const nos = WORKS.map(w => w.no);
const sorted = [...nos].sort();
if (new Set(nos).size !== nos.length) { console.log('编号重复'); bad++; }
console.log(`条数 ${WORKS.length}，问题 ${bad} 处`);
db = WORKS.filter(w => w.desc && w.desc.length > 80).map(w => w.no + ':' + w.desc.length);
console.log('超过80字的条目：', db.join(', ') || '无');
process.exit(bad ? 1 : 0);
```

校验通过标准：条数正确、字段无缺、**每个作品至少有 `link` 或 `github` 之一**、每张 `cover` 文件存在、编号无重复。`story` 段数与 `desc` 超长只做提示，不拦截。

> 实测现状（2026-11-16）：条数 19，但 `无入口` 报 9 条（02/03/04/05/06/07/09/11/18），`story 不足3段` 报 3 条（05/07/16），`desc` 超 80 字 3 条（00:83、06:82、09:86）。这些是既有欠账，不是本次改动引入的。

### 8. 部署
```
git add -A
git commit -m "作品：新增 NO.<xx> <标题>（封面 work-<N>.jpg）"
git push origin master
```
Pages 自动构建。**部署完成后必须抓线上地址复验**（主页 + 附册），本地截图不算证据。

### 9. 更新 README
在 `README.md` 的「部署状态」段**追加一行**（日期 / 新增第几号 / 封面来源 / 校验结果），并同步正文里的作品数、`og:description` 里的数字。

### 10. 收尾
- 新作品带独立页面（如 `thesis/xxx.html`）→ 加进 `sitemap.xml`。
- 若改动涉及隐私或外部链接 → 顺手看一眼 `privacy.html` 是否仍准确。

---

## B. 发布前检查（逐条勾，全绿才推）

- [ ] 1280×720 与 390 宽手机两种视口下，卡片首屏不溢出、`desc` 不超过 5 行
- [ ] 每个作品至少一个可点入口（`link` 或 `github`）；历史有 9 条两者皆无，新增作品不得再出现
- [ ] 所有 `link` / `github` 逐个打开返回 200，含 `thesis/` 子页
- [ ] `no` 连续无重复，`cover` 与作品没有错配
- [ ] 附册每作品四段齐全，`DOC_ANCHORS` 跳转可用
- [ ] 封面无平台水印、无旧占位图
- [ ] 模态框 `story` 三段完整；按钮文案与链接类型匹配（仓库链接不得显示成「试玩」）
- [ ] 联系区为 GitHub + itch.io，均为 `duyv0826`
- [ ] 文案边界：任何位置都没有把 bot 仿真结果写成「玩家接住了引导」
- [ ] `robots.txt` / `sitemap.xml` / `og-cover.png` / `favicon*` 未被改坏
- [ ] 线上抓取结果与本地一致（主页 + 附册），编号与条数都对得上

---

## C. 已知不一致（待修，不影响上线但会误导后来的人）

1. `README.md` 「部署状态（2026-09-23 更新）」开头仍写「已部署至豆包妙搭…17 个作品、编号连续 01–17」，与现状不符。现状是：主部署 GitHub Pages，19 条作品 `00`–`18`，妙搭仅作归档。
2. 封面号与作品号的错位没有在 `README.md`「文件结构」段说明，建议补一行。
3. 《澳里·光景》真人被试那半尚未产生，是唯一允许保留的开口；在任何位置都不得用仿真数字替代，也不得代拟结论。
4. 9 个作品卡片没有可点入口（02/03/04/05/06/07/09/11/18 的 `link` 与 `github` 皆空）。卡片能看、点不进去，是「有作品但没交付物」的观感来源，建议逐个判断：能补 Demo 的补，不能补的至少补源码或视频。
5. `story` 段数不齐：05、07、16 缺第 3 段「凭什么说它成立」，18 有 4 段。缺的那段通常正好是证据段（05 的碰撞检测与音效整合、07 的 <200ms/30FPS 实测、16 的生成式音频时延），补上收益最高。
6. `desc` 超 80 字 3 条：00（83）、06（82）、09（86）。不算错，但手机视口下会压成 5 行，压缩时优先动这三条。
