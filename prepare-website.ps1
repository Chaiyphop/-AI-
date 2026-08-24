# =============================================================
#  Prepare deploy-ready website folder (self-contained mirror)
#  Usage: powershell -NoProfile -ExecutionPolicy Bypass -File prepare-website.ps1
#  Output: <root>\website  (upload this whole folder to GitHub Pages / Netlify)
# =============================================================

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$here   = $PSScriptRoot
$root   = Split-Path -Parent $here
$utf8   = New-Object System.Text.UTF8Encoding($false)

# Locate the auto-output folder (the subfolder that contains index.html)
$outDir = Get-ChildItem -LiteralPath $here -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'index.html') } |
    Select-Object -First 1
if (-not $outDir) { throw 'Output folder (with index.html) not found' }

$site = Join-Path $root 'website'
if (Test-Path -LiteralPath $site) { Remove-Item -LiteralPath $site -Recurse -Force }
New-Item -ItemType Directory -Path $site | Out-Null

Write-Host '[WEB] 1/4 Copying generated outputs...'
Copy-Item -Path (Join-Path $outDir.FullName '*') -Destination $site -Recurse -Force

Write-Host '[WEB] 2/4 Mirroring asset/source folders...'
# Folders that must NOT be published (fake personal data / hack-themed content)
$excluded = @('สิทธิบัตร', 'โค้ด')
$skip = @( (Join-Path $root 'temp'), (Join-Path $root 'line-bot'), $site, $here )
Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $skip -notcontains $_.FullName -and $excluded -notcontains $_.Name } |
    ForEach-Object {
        Write-Host "      + $($_.Name)"
        Copy-Item -LiteralPath $_.FullName -Destination $site -Recurse -Force
    }

Write-Host '[WEB] 3/4 Copying root documents...'
Get-ChildItem -LiteralPath $root -File | Copy-Item -Destination $site -Force

Write-Host '[WEB] 4/4 Fixing relative links + removing links to excluded folders...'
Get-ChildItem -LiteralPath $site -Recurse -Filter *.html | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $c = $c.Replace('../../', '')
    foreach ($f in $excluded) {
        $pattern = "<a[^>]*href='$f/[^']*'[^>]*>[\s\S]*?</a>"
        $c = [regex]::Replace($c, $pattern, '')
    }
    [System.IO.File]::WriteAllText($_.FullName, $c, $utf8)
}

$n = (Get-ChildItem -LiteralPath $site -Recurse -File).Count
Write-Host ''
Write-Host '=============================================='
Write-Host '  DONE! Deploy-ready website folder:'
Write-Host "  $site"
Write-Host "  ($n files)"
Write-Host '  Upload contents to GitHub Pages / Netlify.'
Write-Host '=============================================='
