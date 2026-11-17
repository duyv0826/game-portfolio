# game-portfolio 一键发布（GitHub Pages，master 根目录直出，无需构建）
#
# 用法：
#   powershell -File .\scripts\deploy-portfolio.ps1 -Message "新增 NO.18 作品"
#   powershell -File .\scripts\deploy-portfolio.ps1 -Message "..." -DryRun     # 只看不改
#   powershell -File .\scripts\deploy-portfolio.ps1                            # 交互输入提交说明
#   powershell -File .\scripts\deploy-portfolio.ps1 -Message "..." -SkipVerify # 跳过线上校验
#
# 流程：检查仓库 → 列出改动 → 体积/备份目录体检 → commit → push → 轮询线上直到生效

[CmdletBinding()]
param(
    [string]$Message,
    [switch]$DryRun,
    [switch]$SkipVerify,
    [string]$RepoPath = 'D:\projects\game-portfolio',
    [string]$Branch = 'master',
    [string]$SiteUrl = 'https://duyv0826.github.io/game-portfolio/',
    [int]$VerifyTimeoutSec = 180,
    [int]$MaxFileMB = 25,
    [ValidateSet('auto', 'https', 'ssh')]
    [string]$Transport = 'auto'
)

$ErrorActionPreference = 'Stop'

function Write-Step($t) { Write-Host "`n== $t" -ForegroundColor Cyan }
function Write-Ok($t)   { Write-Host "  [OK] $t" -ForegroundColor Green }
function Write-Warn2($t){ Write-Host "  [!]  $t" -ForegroundColor Yellow }
function Write-Bad($t)  { Write-Host "  [X]  $t" -ForegroundColor Red }

# ---------- 0. 环境检查 ----------
Write-Step '0. 检查仓库'
if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) {
    Write-Bad "仓库目录不存在：$RepoPath"; exit 2
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoPath '.git') -PathType Container)) {
    Write-Bad "不是 git 仓库：$RepoPath"; exit 2
}
& git -C $RepoPath rev-parse --git-dir *> $null
if ($LASTEXITCODE -ne 0) { Write-Bad 'git 无法识别该仓库'; exit 2 }

$curBranch = (& git -C $RepoPath rev-parse --abbrev-ref HEAD).Trim()
if ($curBranch -ne $Branch) {
    Write-Bad "当前分支是 $curBranch，脚本要求 $Branch（可用 -Branch 指定）"; exit 2
}
$remoteUrl = (& git -C $RepoPath remote get-url origin 2>$null)
if (-not $remoteUrl) { Write-Bad '缺少 origin 远程'; exit 2 }
Write-Ok "$RepoPath | 分支 $curBranch | origin $remoteUrl"

if (-not (Test-Path -LiteralPath (Join-Path $RepoPath 'index.html'))) {
    Write-Bad 'index.html 不存在，这不是作品集根目录'; exit 2
}

# ---------- 1. 改动清单 ----------
Write-Step '1. 工作区改动'
$porcelain = & git -C $RepoPath -c core.quotepath=false status --porcelain
$lines = @($porcelain | Where-Object { $_ -and $_.Trim() })
if ($lines.Count -eq 0) {
    Write-Ok '没有任何改动，无需发布'
    if (-not $SkipVerify) { Write-Host "  线上地址：$SiteUrl" }
    exit 0
}
$untracked = @($lines | Where-Object { $_.StartsWith('??') } | ForEach-Object { $_.Substring(3).Trim() })
$tracked   = @($lines | Where-Object { -not $_.StartsWith('??') })

Write-Host ("  已跟踪改动 {0} 项，未跟踪新文件 {1} 项" -f $tracked.Count, $untracked.Count)
$tracked | Select-Object -First 40 | ForEach-Object { Write-Host "    $_" }
if ($tracked.Count -gt 40) { Write-Host "    ... 其余 $($tracked.Count - 40) 项省略" }
if ($untracked.Count -gt 0) {
    Write-Host '  未跟踪新文件（会被一起提交）：' -ForegroundColor Yellow
    $untracked | Select-Object -First 40 | ForEach-Object { Write-Host "    $_" }
    if ($untracked.Count -gt 40) { Write-Host "    ... 其余 $($untracked.Count - 40) 项省略" }
}

# ---------- 2. 体检 ----------
Write-Step '2. 发布体检'
$blockers = @()

# 备份目录绝不上线
$stageCandidates = @($tracked | ForEach-Object { $_.Substring(3).Trim() }) + $untracked
$badDirs = $stageCandidates | Where-Object { $_ -match '^(?i)(_backup|_shots|assets/_ai_backup)/|\.backup-' }
if ($badDirs) {
    $blockers += '改动里含备份目录/备份文件（_backup、_shots、assets/_ai_backup、*.backup-*）：' + ($badDirs -join ', ')
}

# 单文件体积
$bigFiles = @()
foreach ($f in $untracked) {
    $full = Join-Path $RepoPath $f
    if (Test-Path -LiteralPath $full -PathType Leaf) {
        $mb = [math]::Round((Get-Item -LiteralPath $full).Length / 1MB, 2)
        if ($mb -gt $MaxFileMB) { $bigFiles += "$f ($mb MB)" }
    }
}
if ($bigFiles) { $blockers += "单文件超过 ${MaxFileMB} MB：$($bigFiles -join ', ')" }

# index.html 结构没有明显崩坏
$idxText = [IO.File]::ReadAllText((Join-Path $RepoPath 'index.html'), (New-Object Text.UTF8Encoding $false))
$worksCount = ([regex]::Matches($idxText, '(?m)^\s{0,4}(?:no|id)\s*:\s*[''"]')).Count
if ($idxText -notmatch 'WORKS') { $blockers += 'index.html 里找不到 WORKS 数据块' }
if ($idxText.Length -lt 5000) { $blockers += 'index.html 体积异常（小于 5KB）' }
Write-Ok ("index.html {0:N0} 字符，检测到 {1} 条作品条目" -f $idxText.Length, $worksCount)

# .gitignore 覆盖
$ignore = if (Test-Path -LiteralPath (Join-Path $RepoPath '.gitignore')) { [IO.File]::ReadAllText((Join-Path $RepoPath '.gitignore')) } else { '' }
foreach ($need in @('_backup/', 'assets/_ai_backup/')) {
    if ($ignore -notmatch [regex]::Escape($need)) { Write-Warn2 "'.gitignore' 未包含 $need" }
}

if ($blockers) {
    Write-Bad '体检未通过，已中止：'
    $blockers | ForEach-Object { Write-Host "      - $_" -ForegroundColor Red }
    exit 3
}
Write-Ok '体检通过'

# ---------- 3. 提交说明 ----------
Write-Step '3. 提交说明'
if (-not $Message) {
    if ($DryRun) { $Message = '(dry-run)' }
    else {
        $Message = Read-Host '  输入本次提交说明（留空则用时间戳）'
        if (-not $Message) { $Message = 'update portfolio {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm') }
    }
}
Write-Ok "commit message: $Message"

if ($DryRun) {
    Write-Step 'DRY RUN 结束，未做任何改动'
    Write-Host "  将执行：git add -A → git commit → 推送（$Transport）→ 校验 $SiteUrl"
    exit 0
}

# ---------- 4. 提交并推送 ----------
Write-Step '4. 提交'
& git -C $RepoPath add -A
if ($LASTEXITCODE -ne 0) { Write-Bad 'git add 失败'; exit 4 }
& git -C $RepoPath commit -m $Message --quiet
if ($LASTEXITCODE -ne 0) { Write-Bad 'git commit 失败（可能是钩子或钩子缺省配置）'; exit 4 }
$sha = (& git -C $RepoPath rev-parse --short HEAD).Trim()
Write-Ok "已提交 $sha"

Write-Step "5. 推送 $Branch"

# HTTPS 通道在本机常被 RST（github.com 主站连接重置），SSH 通常可用，故 auto 模式两条都试
$sshUrl = $null
if ($remoteUrl -match '^(?i)https?://[^/]+/(.+)$') {
    $sshUrl = 'git@github.com:' + $Matches[1]
} elseif ($remoteUrl -match '^(?i)git@[^:]+:(.+)$') {
    $sshUrl = $remoteUrl
}

$targets = @()
if ($Transport -ne 'ssh') { $targets += @{ Label = 'origin（HTTPS）'; Target = 'origin' } }
if ($Transport -ne 'https' -and $sshUrl -and ($sshUrl -ne $remoteUrl)) {
    $targets += @{ Label = "SSH（$sshUrl）"; Target = $sshUrl }
}
if ($targets.Count -eq 0) { Write-Bad '没有可用的推送通道'; exit 5 }

$pushed = $false
foreach ($t in $targets) {
    Write-Host "  尝试 $($t.Label) ..."
    & git -C $RepoPath push $t.Target $Branch 2>&1 | ForEach-Object { Write-Host "    $_" }
    if ($LASTEXITCODE -eq 0) {
        $pushed = $true
        Write-Ok "推送完成（$($t.Label)）"
        if ($t.Target -ne 'origin') {
            Write-Host "  提示：可执行 git -C `"$RepoPath`" remote set-url origin $sshUrl 让后续都用 SSH" -ForegroundColor DarkGray
        }
        break
    }
    Write-Warn2 "$($t.Label) 失败，换下一条通道"
}

if (-not $pushed) {
    Write-Bad '所有通道都失败，提交已安全保存在本地，未丢失'
    Write-Host "  先用 SSH 重试：git -C `"$RepoPath`" push $(if ($sshUrl) { $sshUrl } else { 'origin' }) $Branch"
    exit 5
}

if ($SkipVerify) {
    Write-Host "`n已完成。线上地址：$SiteUrl（已跳过校验）"
    exit 0
}

# ---------- 6. 线上校验 ----------
Write-Step '6. 线上校验（Pages 生效通常 30–90 秒）'
$localText = ($idxText -replace "`r`n", "`n").TrimEnd()
$deadline = (Get-Date).AddSeconds($VerifyTimeoutSec)
$verified = $false
$attempt = 0
while ((Get-Date) -lt $deadline) {
    $attempt++
    Start-Sleep -Seconds 10
    $bust = '?v=' + [guid]::NewGuid().ToString('N').Substring(0, 8)
    try {
        $resp = Invoke-WebRequest -Uri ($SiteUrl + $bust) -TimeoutSec 25 -MaximumRedirection 5 `
            -Headers @{ 'Cache-Control' = 'no-cache'; 'Pragma' = 'no-cache' }
        if ($resp.StatusCode -ne 200) { Write-Host "  第 $attempt 次：HTTP $($resp.StatusCode)"; continue }
        $remoteText = ($resp.Content -replace "`r`n", "`n").TrimEnd()
        if ($remoteText -eq $localText) {
            Write-Ok "线上内容已与本地 index.html 完全一致（第 $attempt 次轮询，HTTP 200）"
            $verified = $true; break
        }
        $diff = [math]::Abs($remoteText.Length - $localText.Length)
        Write-Host ("  第 {0} 次：HTTP 200，但内容不一致（长度差 {1:N0} 字符），继续等 Pages 构建" -f $attempt, $diff)
    }
    catch {
        Write-Host "  第 $attempt 次：$($_.Exception.Message)"
    }
}

if (-not $verified) {
    Write-Bad "已推送 $sha，但 $VerifyTimeoutSec 秒内线上未变成新内容"
    Write-Host "  多半是 Pages 队列还没跑完，稍后手动刷新确认：$SiteUrl" -ForegroundColor Yellow
    exit 6
}

# 附册与独立页抽查
foreach ($extra in @('开发过程与设计思路.html', 'sitemap.xml', 'robots.txt')) {
    $full = Join-Path $RepoPath $extra
    if (-not (Test-Path -LiteralPath $full)) { continue }
    try {
        $r2 = Invoke-WebRequest -Uri ($SiteUrl + [uri]::EscapeDataString($extra)) -Method Head -TimeoutSec 20
        Write-Ok "$extra HTTP $($r2.StatusCode)"
    }
    catch {
        # 静态托管对 HEAD 支持不一致，退回 GET
        try {
            $r3 = Invoke-WebRequest -Uri ($SiteUrl + [uri]::EscapeDataString($extra)) -TimeoutSec 20
            Write-Ok "$extra HTTP $($r3.StatusCode)（GET）"
        }
        catch { Write-Warn2 "$extra 校验失败：$($_.Exception.Message)" }
    }
}

Write-Host "`n发布完成：$sha → $SiteUrl" -ForegroundColor Green
