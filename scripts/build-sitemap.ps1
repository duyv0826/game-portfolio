$ErrorActionPreference = 'Stop'
$base = 'https://duyv0826.github.io/game-portfolio/'
$root = 'D:\projects\game-portfolio'

# 页面清单：路径 | 优先级（404 与隐私页不进 sitemap）
$pages = @(
  @('index.html', '1.0'),
  @('开发过程与设计思路.html', '0.9'),
  @('design-notes-en.html', '0.9'),
  @('thesis/index.html', '0.9'),
  @('thesis/glimmer-field.html', '0.8'),
  @('thesis/aoli-architecture.html', '0.7'),
  @('stardust-iaa.html', '0.7'),
  @('chrono-web.html', '0.7'),
  @('pulse-field.html', '0.7'),
  @('星尘捕手.html', '0.7'),
  @('sales-dashboard.html', '0.7'),
  @('commission.html', '0.3'),
  @('monogatari-map.html', '0.4')
)

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sb.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
foreach ($p in $pages) {
  $full = Join-Path $root $p[0]
  if (-not (Test-Path -LiteralPath $full)) { Write-Host "跳过（不存在）: $($p[0])"; continue }
  $lastmod = (Get-Item -LiteralPath $full).LastWriteTime.ToString('yyyy-MM-dd')
  $enc = (@($p[0] -split '/' | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/')
  [void]$sb.AppendLine('  <url>')
  [void]$sb.AppendLine("    <loc>$base$enc</loc>")
  [void]$sb.AppendLine("    <lastmod>$lastmod</lastmod>")
  [void]$sb.AppendLine('    <changefreq>monthly</changefreq>')
  [void]$sb.AppendLine("    <priority>$($p[1])</priority>")
  [void]$sb.AppendLine('  </url>')
}
[void]$sb.AppendLine('</urlset>')

$out = Join-Path $root 'sitemap.xml'
[System.IO.File]::WriteAllText($out, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Host "已写入 $out ($((Get-Item $out).Length) bytes)"
Get-Content $out | Select-Object -First 12
