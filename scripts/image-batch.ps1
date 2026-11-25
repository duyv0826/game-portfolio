# 批量图片规格化：统一尺寸/宽高比 + 压到目标体积（默认 1280×720，≤200KB）
#
# 用法：
#   powershell -File .\scripts\image-batch.ps1                       # 干跑，只出结果表
#   powershell -File .\scripts\image-batch.ps1 -Apply                # 输出到 assets\_out
#   powershell -File .\scripts\image-batch.ps1 -Apply -InPlace       # 覆盖原图（先自动备份）
#   powershell -File .\scripts\image-batch.ps1 -Source .\assets\work-18.jpg -Apply
#   .\scripts\image-batch.ps1 -Width 1920 -Height 1080 -MaxKB 300 -Apply
#
# 只依赖 .NET System.Drawing，不装任何包。

[CmdletBinding()]
param(
    [string]$Source,
    [string]$Output,
    [int]$Width = 1280,
    [int]$Height = 720,
    [ValidateSet('cover', 'fit', 'stretch')]
    [string]$Mode = 'cover',
    [int]$MaxKB = 200,
    [int]$Quality = 88,
    [int]$MinQuality = 40,
    [ValidateSet('jpg', 'png')]
    [string]$Format = 'jpg',
    [switch]$AllowUpscale,
    [switch]$InPlace,
    [switch]$Apply,
    [switch]$Force,
    [switch]$Recurse,
    [string]$BackupTo
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Write-Ok($t)   { Write-Host "  [OK] $t" -ForegroundColor Green }
function Write-Warn2($t){ Write-Host "  [!]  $t" -ForegroundColor Yellow }
function Write-Bad($t)  { Write-Host "  [X]  $t" -ForegroundColor Red }

# ---------- 路径 ----------
if (-not $Source) { $Source = Join-Path (Split-Path -Parent $PSScriptRoot) 'assets' }
$resolved = Resolve-Path -LiteralPath $Source -ErrorAction SilentlyContinue
if (-not $resolved) { Write-Bad "输入路径不存在：$Source"; exit 2 }
$Source = $resolved.Path

if (Test-Path -LiteralPath $Source -PathType Leaf) {
    $files = @(Get-Item -LiteralPath $Source)
    $srcDir = Split-Path -Parent $Source
} else {
    $srcDir = $Source
    $files = @(Get-ChildItem -LiteralPath $Source -File -Recurse:$Recurse |
        Where-Object { $_.Extension -match '(?i)^\.(jpg|jpeg|png|bmp|gif|tif|tiff)$' } |
        Sort-Object Name)
}
if ($files.Count -eq 0) { Write-Bad '没有可处理的图片'; exit 2 }

if ($InPlace) {
    if (-not $BackupTo) {
        $BackupTo = Join-Path (Join-Path $srcDir '_backup') ('images-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }
    $outDir = $srcDir
} else {
    if (-not $Output) { $Output = Join-Path $srcDir '_out' }
    $outDir = $Output
}
$targetExt = if ($Format -eq 'png') { '.png' } else { '.jpg' }

"输入：$Source（$($files.Count) 个文件）"
"目标：${Width}×${Height} | $Mode | $Format | ≤${MaxKB}KB"
"输出：$(if ($Apply) { $outDir } else { '干跑，不写文件' })"
if ($InPlace -and $Apply) { "备份：$BackupTo" }
''

# ---------- 编码 ----------
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }

function New-EncodedStream {
    param($bmp, [int]$quality, [string]$fmt)
    $ms = [System.IO.MemoryStream]::new()
    if ($fmt -eq 'png') {
        $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        return $ms
    }
    $ep = [System.Drawing.Imaging.EncoderParameters]::new(1)
    $ep.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, [int64]$quality)
    $bmp.Save($ms, $script:jpegCodec, $ep)
    $ep.Dispose()
    return $ms
}

# ---------- 主循环 ----------
$rows = @()
$fail = @()
$totalBefore = 0.0
$totalAfter = 0.0
$written = 0

foreach ($f in $files) {
    $before = $f.Length / 1KB
    $totalBefore += $before

    # 先按文件头判断是不是真图片：GDI+ 任何解码失败都只会报 "Out of memory"，靠它分不出原因
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $magic = if ($bytes.Length -ge 4) { -join ($bytes[0..3] | ForEach-Object { $_.ToString('X2') }) } else { '' }
    $known = $magic -match '^(FFD8FF|89504E47|47494638|424D)'
    if (-not $known) { $fail += "$($f.Name)：文件头既非 JPEG/PNG/GIF 也非 BMP"; continue }

    $ms = [System.IO.MemoryStream]::new($bytes)
    $img = $null
    try { $img = [System.Drawing.Image]::FromStream($ms) }
    catch { $fail += "$($f.Name)：解码失败（$($_.Exception.Message)）"; $ms.Dispose(); continue }

    try {
        $sw = $img.Width
        $sh = $img.Height

        # 默认不放大：源图比目标小时，把目标按比例降到源图刚好能容纳的尺寸（比例不变），
        # 宁可少像素也不拿插值伪造细节；要强行放大用 -AllowUpscale
        $dstW = $Width
        $dstH = $Height
        if (-not $AllowUpscale) {
            $fit = [math]::Min([math]::Min(1.0, $sw / $Width), [math]::Min(1.0, $sh / $Height))
            $dstW = [math]::Max([int][math]::Round($Width * $fit), 1)
            $dstH = [math]::Max([int][math]::Round($Height * $fit), 1)
        }

        if (($sw -eq $dstW) -and ($sh -eq $dstH) -and ($before -le $MaxKB) -and (-not $Force)) {
            $rows += [pscustomobject][ordered]@{
                文件 = $f.Name; 原尺寸 = "${sw}x${sh}"; 原KB = [math]::Round($before, 1)
                新尺寸 = ''; 新KB = ''; 质量 = ''; 说明 = '已合规，跳过'; 产物 = ''
            }
            $totalAfter += $before
            continue
        }

        $bmp = [System.Drawing.Bitmap]::new($dstW, $dstH, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.Clear([System.Drawing.Color]::White)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

        $dstRect = [System.Drawing.Rectangle]::new(0, 0, $dstW, $dstH)
        if ($Mode -eq 'stretch') {
            $g.DrawImage($img, $dstRect)
        } else {
            $srcAspect = $sw / $sh
            $dstAspect = $dstW / $dstH
            if ($Mode -eq 'cover') {
                if ($srcAspect -gt $dstAspect) {
                    $cropH = $sh; $cropW = [int]($sh * $dstAspect); $ox = [int](($sw - $cropW) / 2); $oy = 0
                } else {
                    $cropW = $sw; $cropH = [int]($sw / $dstAspect); $ox = 0; $oy = [int](($sh - $cropH) / 2)
                }
                $srcRect = [System.Drawing.Rectangle]::new($ox, $oy, $cropW, $cropH)
                $g.DrawImage($img, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
            } else {
                if ($srcAspect -gt $dstAspect) { $dw = $dstW; $dh = [int]($dstW / $srcAspect) }
                else { $dh = $dstH; $dw = [int]($dstH * $srcAspect) }
                $dx = [int](($dstW - $dw) / 2); $dy = [int](($dstH - $dh) / 2)
                $g.DrawImage($img, [System.Drawing.Rectangle]::new($dx, $dy, $dw, $dh))
            }
        }
        $g.Dispose()

        # 质量阶梯：从 -Quality 逐档下降，取第一个 ≤ 上限的
        $chosen = $null
        $chosenQ = 0
        $finalW = $dstW
        $finalH = $dstH
        $note = ''
        $q = $Quality
        while ($q -ge $MinQuality) {
            $enc = New-EncodedStream $bmp $q $Format
            if (($enc.Length / 1KB) -le $MaxKB) { $chosen = $enc; $chosenQ = $q; break }
            $enc.Dispose()
            $q -= 6
        }

        if (-not $chosen) {
            # 质量到底仍超标：整图缩到 90% / 81% / 73%，各试一次
            for ($i = 1; $i -le 3; $i++) {
                if ($chosen) { break }
                $nw = [int]($dstW * [math]::Pow(0.9, $i))
                $nh = [int]($dstH * [math]::Pow(0.9, $i))
                $small = [System.Drawing.Bitmap]::new($nw, $nh, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
                $g2 = [System.Drawing.Graphics]::FromImage($small)
                $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g2.DrawImage($bmp, 0, 0, $nw, $nh)
                $g2.Dispose()
                $enc = New-EncodedStream $small $MinQuality $Format
                $small.Dispose()
                if (($enc.Length / 1KB) -le $MaxKB) {
                    $chosen = $enc; $chosenQ = $MinQuality; $finalW = $nw; $finalH = $nh
                    $note = "整图缩至 ${nw}x${nh}"
                } else { $enc.Dispose() }
            }
        }
        $bmp.Dispose()

        if (-not $chosen) {
            $fail += "$($f.Name)：压到下限仍超 ${MaxKB}KB，未输出"
            $totalAfter += $before
            continue
        }

        $newKB = [math]::Round($chosen.Length / 1KB, 1)
        $dstName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) + $targetExt
        $dstPath = Join-Path $outDir $dstName

        if ($Apply) {
            if ($InPlace) {
                if (-not (Test-Path -LiteralPath $BackupTo)) { New-Item -ItemType Directory -Path $BackupTo -Force | Out-Null }
                Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $BackupTo $f.Name) -Force
            }
            if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
            [System.IO.File]::WriteAllBytes($dstPath, $chosen.ToArray())
            $written++
        }
        $chosen.Dispose()
        $totalAfter += $newKB

        $desc = if ($note) { $note }
                elseif ($before -gt $MaxKB) { '压到上限内' }
                elseif ($sw -ne $dstW -or $sh -ne $dstH) { '仅规范尺寸' }
                else { '重编码' }
        $rows += [pscustomobject][ordered]@{
            文件 = $f.Name; 原尺寸 = "${sw}x${sh}"; 原KB = [math]::Round($before, 1)
            新尺寸 = "${finalW}x${finalH}"; 新KB = $newKB; 质量 = $chosenQ; 说明 = $desc
            产物 = if ($Apply) { $dstPath } else { $dstName }
            期望W = $finalW; 期望H = $finalH
        }
    }
    finally {
        if ($img) { $img.Dispose() }
        $ms.Dispose()
    }
}

# ---------- 汇总 ----------
$rows | Format-Table '文件', '原尺寸', '原KB', '新尺寸', '新KB', '质量', '说明' -AutoSize | Out-String -Width 220 | Write-Host
"合计 {0:N1} KB → {1:N1} KB，共 {2} 个文件" -f $totalBefore, $totalAfter, $files.Count
$skipCount = @($rows | Where-Object { $_.说明 -eq '已合规，跳过' }).Count
if ($skipCount) { Write-Host "  其中 $skipCount 个已合规跳过" }
if ($fail.Count) {
    ''
    Write-Bad "失败 $($fail.Count) 个："
    $fail | ForEach-Object { Write-Host "      - $_" -ForegroundColor Red }
    if (@($rows).Count -eq 0) { exit 4 }
}

if (-not $Apply) {
    ''
    Write-Host '这是干跑。加 -Apply 才写文件；要覆盖原图再加 -InPlace（先备份到 _backup/images-<时间戳>）。' -ForegroundColor Yellow
    exit 0
}

# ---------- 产物复核 ----------
$bad = @()
foreach ($r in $rows) {
    if (-not $r.产物) { continue }
    if (-not (Test-Path -LiteralPath $r.产物)) { $bad += "$($r.文件)：产物不存在 $($r.产物)"; continue }
    $item = Get-Item -LiteralPath $r.产物
    $im = [System.Drawing.Image]::FromFile($r.产物)
    $w = $im.Width; $h = $im.Height
    $im.Dispose()
    $kb = [math]::Round($item.Length / 1KB, 1)
    if ($kb -gt $MaxKB) { $bad += "$($r.文件)：$kb KB 超过上限"; continue }
    if ($w -ne $r.期望W -or $h -ne $r.期望H) {
        $bad += "$($r.文件)：尺寸 ${w}x${h}，应为 $($r.期望W)x$($r.期望H)"
    }
}

if ($bad) {
    Write-Bad '复核未通过：'
    $bad | ForEach-Object { Write-Host "      - $_" -ForegroundColor Red }
    exit 3
}
Write-Ok "已写出 $written 张到 $outDir，体积与尺寸全部复核通过"
Write-Host "  合计 $([math]::Round($totalBefore,1)) KB → $([math]::Round($totalAfter,1)) KB" -ForegroundColor DarkGray
