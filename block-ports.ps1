#Requires -RunAsAdministrator
# Block External Ports - Personal Computer (No Exceptions)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   BLOCK ALL EXTERNAL PORTS" -ForegroundColor Red
Write-Host "   Personal Computer Mode" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

$ports = @(
    @{Name="Block-RPC-135"; Port=135; Protocol="TCP"},
    @{Name="Block-SMB-445"; Port=445; Protocol="TCP"},
    @{Name="Block-UPnP-5040"; Port=5040; Protocol="TCP"},
    @{Name="Block-WSDAPI-5357"; Port=5357; Protocol="TCP"},
    @{Name="Block-DO-7680"; Port=7680; Protocol="TCP"},
    @{Name="Block-RPC-Dynamic"; Port="49664-49674"; Protocol="TCP"},
    @{Name="Block-All-Inbound"; Port=1; Protocol="TCP"}
)

$rulesCreated = 0

foreach ($port in $ports) {
    $ruleName = $port.Name
    
    # Remove existing
    $existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if ($existing) {
        Remove-NetFirewallRule -DisplayName $ruleName
        Write-Host "[RESET] $ruleName" -ForegroundColor Yellow
    }
    
    # Create block rule
    if ($port.Port -eq 1) {
        # Block ALL inbound TCP
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Inbound `
            -Action Block `
            -Protocol TCP `
            -Enabled True `
            -Description "Block ALL inbound TCP connections" | Out-Null
        Write-Host "[BLOCKED] ALL INBOUND TCP" -ForegroundColor Red
    } else {
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Inbound `
            -Action Block `
            -Protocol $port.Protocol `
            -LocalPort $port.Port `
            -RemoteAddress Any `
            -Enabled True `
            -Description "Block port $($port.Port)" | Out-Null
        Write-Host "[BLOCKED] $($port.Name) - Port $($port.Port)" -ForegroundColor Green
    }
    $rulesCreated++
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   COMPLETE!" -ForegroundColor Green
Write-Host "   $rulesCreated rules created" -ForegroundColor Green
Write-Host "   ALL inbound blocked" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
