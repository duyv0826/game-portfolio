# 作品集线上巡检：确认 GitHub Pages 上每一页、每张封面都能正常返回
#
# 用法：
#   pwsh -File .\scripts\portfolio-healthcheck.ps1              # 全量巡检
#   pwsh -File .\scripts\portfolio-healthcheck.ps1 -Quiet       # 只打印失败项（给定时任务用）
#   pwsh -File .\scripts\portfolio-healthcheck.ps1 -Json .\health.json
#
# 退出码：0 全部正常 / 1 有失败 / 2 参数或路径问题

[CmdletBinding()]
param(
    [string]$RepoPath = 'D:\projects\game-portfolio',
    [string]$BaseUrl = 'https://duyv0826.github.io/game-portfolio/',
    [int]$TimeoutSec = 20,
    [switch]$Quiet,
    [string]$Json
)

$ErrorActionPreference = 'Stop'

function Ok($t)  { if (-not $Quiet) { Write-Host "  [OK] $t" -ForegroundColor Green } }
function Bad($t) { Write-Host "  [X]  $t" -ForegroundColor Red }

# ---------- 1. 从仓库发现要巡检的清单 ----------
$rel = @()
if (Test-Path -LiteralPath $RepoPath) {
    # 根目录页面 + 子目录页面（排除备份目录），统一转成相对路径
    $html = @(Get-ChildItem -LiteralPath $RepoPath -Filter '*.html' -File -Recurse |
        Where-Object { $_.FullName -notmatch '\\(_backup|_shots|_ai_backup)\\' } |
        ForEach-Object { $_.FullName.Substring($RepoPath.Length).TrimStart('\', '/') -replace '\\', '/' } |
        Sort-Object)
    $rel += $html
    $rel += 'sitemap.xml'; $rel += 'robots.txt'; $rel += 'og-cover.png'; $rel += 'favicon.ico'
    $covers = @(Get-ChildItem -LiteralPath (Join-Path $RepoPath 'assets') -Filter 'work-*.jpg' -File |
        Sort-Object Name | ForEach-Object { "assets/$($_.Name)" })
    $rel += $covers
    $rel = @($rel | Where-Object { Test-Path -LiteralPath (Join-Path $RepoPath ($_ -replace '/', '\')) })
} else {
    Write-Host "本地仓库不在（$RepoPath），退化为固定清单" -ForegroundColor Yellow
    $rel = @('index.html', '开发过程与设计思路.html', 'privacy.html', 'sitemap.xml', 'robots.txt')
    $rel += 1..19 | ForEach-Object { "assets/work-$_.jpg" }
}
if ($rel.Count -eq 0) { Write-Host '没有可巡检的目标'; exit 2 }

Write-Host "巡检 $($rel.Count) 个地址 → $BaseUrl`n"

# ---------- 2. 逐个请求 ----------
$results = @()
$fail = 0
foreach ($r in $rel) {
    $segments = @($r -split '/' | ForEach-Object { [uri]::EscapeDataString($_) })
    $url = $BaseUrl.TrimEnd('/') + '/' + ($segments -join '/')
    $ok = $false; $note = ''
    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $resp = Invoke-WebRequest -Uri $url -TimeoutSec $TimeoutSec -MaximumRedirection 5 `
            -Headers @{ 'Cache-Control' = 'no-cache' }
        $sw.Stop()
        if ($resp.StatusCode -eq 200 -and $resp.RawContentLength -gt 0) {
            $ok = $true
            $note = ("{0} KB / {1} ms" -f [math]::Round($resp.RawContentLength / 1KB, 1), $sw.ElapsedMilliseconds)
        } else {
            $note = "HTTP $($resp.StatusCode)，长度 $($resp.RawContentLength)"
        }
    }
    catch {
        $code = $null
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) { $code = [int]$_.Exception.Response.StatusCode }
        $note = if ($code) { "HTTP $code" } else { $_.Exception.Message }
    }
    if ($ok) { Ok "$r  $note" } else { Bad "$r  $note"; $fail++ }
    $results += [pscustomobject][ordered]@{ 地址 = $r; 通过 = $ok; 说明 = $note; URL = $url }
}

# ---------- 3. 汇总 ----------
$summary = [pscustomobject][ordered]@{
    巡检时间 = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    站点 = $BaseUrl
    总数 = $results.Count
    失败 = $fail
    结果 = $results
}
if ($Json) {
    $summary | ConvertTo-Json -Depth 4 | Out-File -LiteralPath $Json -Encoding utf8
    if (-not $Quiet) { Write-Host "`n结果已写入 $Json" }
}

if ($fail -eq 0) {
    if (-not $Quiet) { Write-Host "`n全部 $($results.Count) 个地址正常" -ForegroundColor Green }
    exit 0
}

Write-Host "`n$fail / $($results.Count) 个地址异常：" -ForegroundColor Red
$results | Where-Object { -not $_.通过 } | ForEach-Object { Write-Host "  - $($_.地址)：$($_.说明)" -ForegroundColor Red }
exit 1
