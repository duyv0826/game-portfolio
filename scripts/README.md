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

退出码：`0` 成功 / `2` 环境不符 / `3` 体检未通过 / `4` commit 失败 / `5` 推送失败 / `6` 推送成功但线上未生效。

## 脚本里已经固化的红线

- 改动中出现 `_backup/`、`_shots/`、`assets/_ai_backup/`、`*.backup-*` → 直接中止，不提交
- 单文件超 25MB → 中止（GitHub 单文件 100MB 硬限，Pages 也吃不下大包）
- `index.html` 找不到 `WORKS` 数据块或小于 5KB → 中止
- 推送后必须**线上正文与本地 `index.html` 逐字一致**才算成功，避免"推上去了但 Pages 还是旧版"

发布前的入库流程见仓库根目录 `README-入库与发布清单.md`。
