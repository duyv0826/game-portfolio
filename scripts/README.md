# scripts

## deploy-portfolio.ps1 — 一键发布

静态站，无构建步骤。改动 `index.html` / `assets/` / 附册后，一条命令完成 commit → push → 等 Pages 生效。

```powershell
# 正常发布
powershell -File .\scripts\deploy-portfolio.ps1 -Message "新增 NO.19 作品"

# 只看会做什么，不改动仓库
powershell -File .\scripts\deploy-portfolio.ps1 -DryRun

# 不传 Message 时交互输入
powershell -File .\scripts\deploy-portfolio.ps1
```

参数：

| 参数 | 默认 | 说明 |
|---|---|---|
| `-RepoPath` | `D:\projects\game-portfolio` | 仓库根目录 |
| `-Branch` | `master` | 推送分支，与 Pages 源一致 |
| `-SiteUrl` | `https://duyv0826.github.io/game-portfolio/` | 校验地址 |
| `-Message` | 交互输入 | 提交说明 |
| `-DryRun` | 关 | 只检查不提交 |
| `-SkipVerify` | 关 | 跳过线上轮询 |
| `-VerifyTimeoutSec` | 180 | 等 Pages 的上限 |
| `-MaxFileMB` | 25 | 单文件体积上限 |
| `-Transport` | `auto` | 推送通道：`auto` 先 HTTPS 再 SSH / `https` / `ssh` |

退出码：`0` 成功 / `2` 环境不符 / `3` 体检未通过 / `4` commit 失败 / `5` 推送失败 / `6` 推送成功但线上未生效。

## 推送通道（本机实测）

本机到 github.com 的 HTTPS 会稳定被 `Recv failure: Connection was reset` 打断，SSH 正常（`ssh -T git@github.com` 返回 `Hi duyv0826!`）。所以 `auto` 模式先走 origin 的 HTTPS，失败后自动把 `https://github.com/OWNER/REPO.git` 换算成 `git@github.com:OWNER/REPO.git` 再推一次，两条都失败才报错退出（此时提交已安全留在本地）。

想省掉每次那 10 秒的失败尝试：

```powershell
git -C D:\projects\game-portfolio remote set-url origin git@github.com:duyv0826/game-portfolio.git
```

之后固定用 `-Transport ssh` 或保持 `auto` 均可。

## 脚本里已经固化的红线

- 改动中出现 `_backup/`、`_shots/`、`assets/_ai_backup/`、`*.backup-*` → 直接中止，不提交
- 单文件超 25MB → 中止（GitHub 单文件 100MB 硬限，Pages 也吃不下大包）
- `index.html` 找不到 `WORKS` 数据块或小于 5KB → 中止
- 推送后必须**线上正文与本地 `index.html` 逐字一致**才算成功，避免"推上去了但 Pages 还是旧版"

## 一个已知的缓存坑：换图片要等 10 分钟

`index.html` 每次推送都会变，校验能立刻对上；但 `assets/` 下的图片走 GitHub Pages CDN，响应头是 `Cache-Control: max-age=600`，**换封面后线上最长 10 分钟内还是旧图**，加 `?cb=` 查询串也绕不过（CDN 的缓存键不含查询串）。

判断方法：仓库里已经是新文件（`git cat-file -s HEAD:assets/work-18.jpg`）但线上 `Content-Length` 还是旧值，且响应头 `X-Cache: HIT`、`Age` 很小 —— 就是 CDN 缓存，等它过期即可，不用重新推送。要立刻生效只能改文件名（例如 `work-18-v2.jpg`）并同步改 `index.html` 里的引用。

发布前的入库流程见仓库根目录 `README-入库与发布清单.md`。

---

## image-batch.ps1 — 批量图片规格化

把任意尺寸的截图统一成封面规格（默认 1280×720 / JPEG / ≤200KB），带透明通道的 PNG 会拍平到白底，EXIF 等元数据一并丢弃。

```powershell
# 干跑：只出结果表，报告哪些合规、哪些要改、改成多大
powershell -File .\scripts\image-batch.ps1

# 真正输出到 assets\_out（不动原图）
powershell -File .\scripts\image-batch.ps1 -Apply

# 覆盖原图（先自动备份到 assets\_backup\images-<时间戳>\）
powershell -File .\scripts\image-batch.ps1 -Apply -InPlace

# 只修某一张不合规的
powershell -File .\scripts\image-batch.ps1 -Source .\assets\work-18.jpg -Apply -InPlace

# 换成别的规格给别的用途
.\scripts\image-batch.ps1 -Width 1920 -Height 1080 -MaxKB 300 -Source .\shots -Apply
```

| 参数 | 默认 | 说明 |
|---|---|---|
| `-Source` | `<仓库>\assets` | 目录或单个文件 |
| `-Output` | `<Source>\_out` | 非 `-InPlace` 时的输出目录 |
| `-Width` / `-Height` | 1280 / 720 | 目标像素 |
| `-Mode` | `cover` | `cover` 居中裁切铺满 / `fit` 等比缩放留白 / `stretch` 拉伸 |
| `-MaxKB` | 200 | 体积上限 |
| `-Quality` / `-MinQuality` | 88 / 40 | JPEG 质量起点与下限，每档降 6 逐级试 |
| `-Format` | `jpg` | `jpg` / `png` |
| `-InPlace` | 关 | 覆盖原图，自动先备份 |
| `-Apply` | 关 | 不加就是干跑，不写任何文件 |
| `-Force` | 关 | 已合规的也重做 |
| `-Recurse` | 关 | 递归子目录 |
| `-AllowUpscale` | 关 | 源图比目标小时是否放大。默认不放大：把目标尺寸按比例降到源图能容纳的最大值（保持比例），宁可少像素也不用插值伪造细节 |

压缩策略：先按 `-Quality` 起调，逐档降到 `-MinQuality` 找第一个达标值；到底仍超标就把整图缩到 90%/81%/73% 各试一次。**对已经合规的图片不动**，所以可以整个目录反复跑，不会二次劣化。

**不放大是默认行为**：源图 1024×576 目标 1280×720 时，实际输出 1024×576（比例一致、体积更小、不糊）。压缩比目标小的情况也按同样逻辑——要强制补足像素才用 `-AllowUpscale`。

判定"合规"看的是**目标尺寸 + 体积**，不是固定 1280×720：只要比例对、体积够小，1024×576 也算合规，不会被反复重压。

写完后脚本会**重新打开产物复核**尺寸与体积，不合规直接报错退出，不会留下"看起来成功实际超标"的文件。

退出码：`0` 成功 / `2` 路径不存在 / `3` 产物复核未通过 / `4` 全部失败。

