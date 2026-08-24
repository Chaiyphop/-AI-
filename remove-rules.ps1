#Requires -RunAsAdministrator
Write-Host "Removing all Block rules..." -ForegroundColor Yellow
Get-NetFirewallRule -DisplayName "Block-*" | Remove-NetFirewallRule
Write-Host "DONE!" -ForegroundColor Green
Get-NetFirewallRule -DisplayName "Block-*" -ErrorAction SilentlyContinue
