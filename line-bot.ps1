$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$dir     = $PSScriptRoot
$cfgPath = Join-Path $dir 'config.json'
$cfg     = Get-Content -LiteralPath $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json

$port    = if ($cfg.PORT) { [int]$cfg.PORT } else { 3000 }
$logDir  = Join-Path $dir 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir ('chat-' + (Get-Date -Format 'yyyyMMdd') + '.txt')

function Log([string]$m) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line -Encoding UTF8
}

$hasToken  = [bool]$cfg.LINE_CHANNEL_ACCESS_TOKEN
$hasSecret = [bool]$cfg.LINE_CHANNEL_SECRET

Write-Host ''
Write-Host '==============================================' 
Write-Host '  LINE AUTO-REPLY BOT (PowerShell Edition)'
Write-Host "  Port      : $port"
Write-Host "  Token     : $(if($hasToken){'OK'}else{'MISSING'})"
Write-Host "  Secret    : $(if($hasSecret){'OK'}else{'MISSING (signature check disabled)'})"
Write-Host "  OpenAI AI : $(if($cfg.OPENAI_API_KEY){'ENABLED'}else{'off (keyword FAQ mode)'})"
Write-Host '==============================================' 
if (-not $hasToken) {
    Write-Host '  WARN: bot will receive but NOT reply.'
    Write-Host '  Put your token in config.json then restart.'
}
Write-Host ''

function Get-FaqReply([string]$text) {
    $t = $text.ToLower()
    if ($t -match 'ราคา|เท่าไหร่|ค่าเรียน|กี่บาท|แพง')   { return [string]$cfg.faqPrice }
    if ($t -match 'คอร์ส|เรียน|หลักสูตร|สอนอะไร|เนื้อหา') { return [string]$cfg.faqCourse }
    if ($t -match 'สมัคร|จ่าย|ชำระ|โอน|ช่องทาง|ติดต่อ')   { return [string]$cfg.faqSignup }
    return [string]$cfg.fallbackMessage
}

function Get-AiReply([string]$text) {
    if (-not $cfg.OPENAI_API_KEY) { return $null }
    try {
        $sys = "คุณคือผู้ช่วยตอบแชทขายคอร์ส '$($cfg.businessName)' ตอบภาษาไทย สั้น กระชับ เป็นมิตร ใช้เฉพาะข้อมูลที่ให้: หลักสูตร: $($cfg.faqCourse) ราคา: $($cfg.faqPrice) การสมัคร: $($cfg.faqSignup) ถ้าไม่รู้คำตอบจริง ให้บอกว่าจะส่งต่อทีมงาน"
        $body = @{
            model      = 'gpt-4o-mini'
            max_tokens = 300
            temperature= 0.4
            messages   = @(
                @{ role='system'; content=$sys },
                @{ role='user';   content=$text }
            )
        } | ConvertTo-Json -Depth 5
        $r = Invoke-RestMethod -Uri 'https://api.openai.com/v1/chat/completions' -Method Post `
                -Headers @{ Authorization = "Bearer $($cfg.OPENAI_API_KEY)" } `
                -ContentType 'application/json' -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 25
        return [string]$r.choices[0].message.content
    } catch {
        Log ("OpenAI error: " + $_.Exception.Message)
        return $null
    }
}

function Send-LineReply([string]$replyToken, [string]$text) {
    $payload = @{
        replyToken = $replyToken
        messages   = @(@{ type='text'; text=$text })
    } | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Uri 'https://api.line.me/v2/bot/message/reply' -Method Post `
        -Headers @{ Authorization = "Bearer $($cfg.LINE_CHANNEL_ACCESS_TOKEN)" } `
        -ContentType 'application/json; charset=utf-8' `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) | Out-Null
}

function Test-Signature([byte[]]$bodyBytes, [string]$sig) {
    if (-not $hasSecret -or -not $sig) { return $true }
    $hmac = New-Object System.Security.Cryptography.HMACSHA256 (,[System.Text.Encoding]::UTF8.GetBytes([string]$cfg.LINE_CHANNEL_SECRET))
    $calc = [Convert]::ToBase64String($hmac.ComputeHash($bodyBytes))
    return ($calc -eq $sig)
}

function Send-Http([System.Net.Sockets.NetworkStream]$s, [int]$code, [string]$reason, [string]$bodyText) {
    $b   = [System.Text.Encoding]::UTF8.GetBytes($bodyText)
    $hdr = "HTTP/1.1 $code $reason`r`nContent-Type: text/plain; charset=utf-8`r`nContent-Length: $($b.Length)`r`nConnection: close`r`n`r`n"
    $hb  = [System.Text.Encoding]::ASCII.GetBytes($hdr)
    $s.Write($hb, 0, $hb.Length)
    if ($b.Length -gt 0) { $s.Write($b, 0, $b.Length) }
    $s.Flush()
}

$seenReplyTokens = New-Object 'System.Collections.Generic.HashSet[string]'

function Handle-Webhook([string]$body, [byte[]]$bodyBytes, [string]$sig) {
    if (-not (Test-Signature $bodyBytes $sig)) { Log 'REJECTED: bad signature'; return }
    try { $json = $body | ConvertFrom-Json } catch { Log ('Bad JSON: ' + $_.Exception.Message); return }
    foreach ($ev in @($json.events)) {
        if ($ev.type -ne 'message' -or $ev.message.type -ne 'text') { continue }
        $userText  = [string]$ev.message.text
        $rToken    = [string]$ev.replyToken
        if (-not $seenReplyTokens.Add($rToken)) { Log 'DUPLICATE event ignored'; continue }
        if ($seenReplyTokens.Count -gt 500) { $seenReplyTokens.Clear() | Out-Null }
        Log ("IN : $userText")
        $answer = Get-AiReply $userText
        if (-not $answer) { $answer = Get-FaqReply $userText }
        if ($hasToken -and $rToken) {
            try   { Send-LineReply $rToken $answer; Log "OUT: $answer" }
            catch { Log ('LINE reply error: ' + $_.Exception.Message) }
        } else {
            Log ("OUT(dry): $answer")
        }
    }
}

$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $port)
$listener.Start()
Log "Listening on http://localhost:$port/  (webhook path: /webhook)"

try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $stream.ReadTimeout = 8000
            $buf = New-Object byte[] 65536
            $acc = New-Object System.Collections.Generic.List[byte]
            while ($true) {
                $n = $stream.Read($buf, 0, $buf.Length)
                if ($n -le 0) { break }
                for ($i = 0; $i -lt $n; $i++) { $acc.Add($buf[$i]) }
                $arr = $acc.ToArray()
                $headAscii = [System.Text.Encoding]::ASCII.GetString($arr)
                $idx = $headAscii.IndexOf("`r`n`r`n")
                if ($idx -ge 0) {
                    $cl = 0
                    foreach ($line in ($headAscii.Substring(0, $idx) -split "`r`n")) {
                        if ($line -match '^content-length:\s*(\d+)') { $cl = [int]$Matches[1] }
                    }
                    if (($arr.Length - $idx - 4) -ge $cl) { break }
                }
            }
            $arr = $acc.ToArray()
            $all = [System.Text.Encoding]::UTF8.GetString($arr)
            $sep = $all.IndexOf("`r`n`r`n")
            if ($sep -lt 0) { Send-Http $stream 400 'Bad Request' ''; continue }
            $headerBlock = $all.Substring(0, $sep)
            $bodyText    = $all.Substring($sep + 4)
            $reqLine     = ($headerBlock -split "`r`n")[0]
            $parts       = $reqLine -split '\s+'
            $method      = $parts[0]
            $rawPath     = if ($parts.Length -gt 1) { $parts[1] } else { '/' }
            $pathOnly    = ($rawPath -split '\?')[0].ToLower()
            $sigHeader   = $null
            foreach ($line in ($headerBlock -split "`r`n")) {
                if ($line -match '^x-line-signature:\s*(.+)$') { $sigHeader = $Matches[1].Trim() }
            }

            if ($method -eq 'GET' -and ($pathOnly -eq '/health' -or $pathOnly -eq '/')) {
                Send-Http $stream 200 'OK' 'alive'
            }
            elseif ($method -eq 'POST' -and $pathOnly -eq '/webhook') {
                $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyText)
                Send-Http $stream 200 'OK' 'OK'
                Handle-Webhook $bodyText $bodyBytes $sigHeader
            }
            else {
                Send-Http $stream 404 'Not Found' 'not found'
            }
        } catch {
            Log ('Request error: ' + $_.Exception.Message)
        } finally {
            $client.Close()
        }
    }
}
finally {
    $listener.Stop()
    Log 'Server stopped'
}
