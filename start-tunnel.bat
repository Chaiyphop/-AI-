@echo off
chcp 65001 >nul
if not exist "%~dp0cloudflared.exe" (
    echo Downloading cloudflared...
    powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile '%~dp0cloudflared.exe'"
)
echo.
echo Tunnel starting. Copy the https://xxxx.trycloudflare.com URL shown below
echo and set it as Webhook URL + /webhook in LINE Developers Console.
echo.
"%~dp0cloudflared.exe" tunnel --url http://localhost:3000
pause
