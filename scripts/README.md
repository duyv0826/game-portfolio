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

发布前的入库流程见仓库根目录 `README-入库与发布清单.md`。
