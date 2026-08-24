# =============================================================
#  Run everything: regenerate outputs + prepare deploy website
#  (This is the script that Task Scheduler will run daily)
# =============================================================

$ErrorActionPreference = 'Stop'

& (Join-Path $PSScriptRoot 'build.ps1')
& (Join-Path $PSScriptRoot 'prepare-website.ps1')
