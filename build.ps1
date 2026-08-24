# =============================================================
#  ระบบ AI สร้างผลผลิตอัตโนมัติ (AI Auto Output Generator) v1.0
#  วิธีรัน: ดับเบิลคลิก "สร้างผลผลิตทั้งหมด.bat" หรือรันสคริปต์นี้
#  สิ่งที่ทำ: สแกนไฟล์ในโฟลเดอร์ -> วิเคราะห์ -> สร้างผลผลิต 5 รายการ
#   1. พอร์ตโฟลิโอ.html        (เว็บพอร์ตโฟลิโอธีมเข้ม)
#   2. คอนเทนต์การตลาด.md       (LinkedIn / YouTube / TikTok / X / บล็อก)
#   3. โครงคอร์สออนไลน์.md       (โครงคอร์ส + ราคา + แพลตฟอร์ม)
#   4. รายงานวิเคราะห์_ทำเงิน.md (คะแนนทำเงิน + แผนปฏิบัติ 30/60/90)
#   5. index.html               (หน้า Hub รวมทุกผลผลิต)
# =============================================================

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$here     = $PSScriptRoot
$root     = Split-Path -Parent $here
$outDir   = Join-Path $here 'ผลผลิตอัตโนมัติ'
$utf8     = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

function Read-Utf8([string]$path) {
    if (Test-Path -LiteralPath $path) {
        return [System.IO.File]::ReadAllText($path, $utf8)
    }
    return ''
}

function Write-Utf8([string]$path, [string]$content) {
    [System.IO.File]::WriteAllText($path, $content, $utf8)
}

function Apply-Placeholders([string]$template, [hashtable]$map) {
    foreach ($key in $map.Keys) {
        $template = $template.Replace($key, [string]$map[$key])
    }
    return $template
}

Write-Host ""
Write-Host "=============================================="
Write-Host "  [AI AUTO] ระบบสร้างผลผลิตอัตโนมัติ v1.0"
Write-Host "=============================================="

# ---------------- 1) สแกนไฟล์ ----------------
Write-Host "[AI] 1/5 กำลังสแกนไฟล์ในโฟลเดอร์..."

$paths = @{
    cs      = Join-Path $root 'โค้ด\พิธีสารดีเจซินนิ่ง.cs'
    mdMain  = Join-Path $root 'สถาปัตยกรรม\แผนภาพสถาปัตยกรรม.md'
    mdFull  = Join-Path $root 'สถาปัตยกรรม\แผนภาพสถาปัตยกรรมฉบับสมบูรณ์.md'
    puml    = Join-Path $root 'สถาปัตยกรรม\แผนภาพสถาปัตยกรรม.puml'
    patent  = Join-Path $root 'สิทธิบัตร\สิทธิบัตร_ระบบปัญญาประดิษฐ์ขั้นสูง.html'
    readme  = Join-Path $root 'README_ภาพรวม.md'
    tsx     = Join-Path $root 'โค้ด\แดชบอร์ดระบบมาสเตอร์.tsx'
    omega   = Join-Path $root 'แผนภาพ\แดชบอร์ดควอนตัม.html'
}

$cs     = Read-Utf8 $paths.cs
$mdMain = Read-Utf8 $paths.mdMain
$mdFull = Read-Utf8 $paths.mdFull
$patent = Read-Utf8 $paths.patent
$readme = Read-Utf8 $paths.readme

# ---------------- 2) วิเคราะห์ข้อมูล ----------------
Write-Host "[AI] 2/5 กำลังวิเคราะห์เนื้อหา..."

# เวอร์ชันจาก C#
$version = '8.0.0'
if ($cs -match '@version\s+(\d+\.\d+\.\d+)') { $version = $Matches[1] }

# จำนวน Agent / Concurrency จาก C#
$agents = 1000
$concurrency = 128
if ($cs -match 'appCount\s*=\s*(\d+)')  { $agents = [int]$Matches[1] }
if ($cs -match 'concurrency\s*=\s*(\d+)') { $concurrency = [int]$Matches[1] }

# 4 Layer จาก C#  (LAYER x: NAME (The 'Eng' / ไทย))
$layers = @()
$layerMatches = [regex]::Matches($cs, "LAYER (\d+): (.+?)\(The '(.+?)' / ([^)]+)\)")
foreach ($m in $layerMatches) {
    $layers += [PSCustomObject]@{
        Num   = [int]$m.Groups[1].Value
        Name  = $m.Groups[2].Value.Trim()
        Eng   = $m.Groups[3].Value
        Thai  = $m.Groups[4].Value.Trim()
    }
}
$layers = @($layers | Sort-Object Num)
$layerCount = $layers.Count
if ($layerCount -eq 0) { $layerCount = 4 }

# Epochs จาก mdMain
$epochs = @()
$epochMatches = [regex]::Matches($mdMain, 'Epoch\d\["ยุคที่ \d: ([^\(]+)\(([^\)]+)\)')
foreach ($m in $epochMatches) {
    $epochs += [PSCustomObject]@{ Name = $m.Groups[1].Value.Trim(); Thai = $m.Groups[2].Value.Trim() }
}
if ($epochs.Count -eq 0) { $epochs = @(@{Name='The Collective';Thai='แบบรวมหมู่'},@{Name='The Singularity';Thai='แบบเอกภาวะ'},@{Name='The Pantheon';Thai='แบบคณะปัญญา'},@{Name='The Weaver';Thai='ผู้ถักทอ'}) }

# จำนวนสูตรจาก mdFull (ตัวเลข 1..62)
$formulaNums = @()
$formulaMatches = [regex]::Matches($mdFull, '\b(\d+)\.\s+[A-Z]')
foreach ($m in $formulaMatches) { $formulaNums += [int]$m.Groups[1].Value }
$formulaNums = @($formulaNums | Sort-Object -Unique)
$formulaTotal = 0
if ($formulaNums.Count -gt 0) { $formulaTotal = $formulaNums[-1] }
if ($formulaTotal -eq 0) { $formulaTotal = 62 }
$axiomTotal = @($formulaNums | Where-Object { $_ -ge 51 }).Count
if ($axiomTotal -eq 0 -and $formulaTotal -ge 62) { $axiomTotal = 12 }

# หมวดหมู่สูตรจาก mdFull (### 5.x ... (N สูตร))
$formulaCats = @()
$catMatches = [regex]::Matches($mdFull, '(?m)^### 5\.\d (.+?) \(\d+ สูตร\)')
foreach ($m in $catMatches) { $formulaCats += $m.Groups[1].Value.Trim() }

# ข้อถือสิทธิจากสิทธิบัตร
$claims = @([regex]::Matches($patent, '<li>')).Count
$sinnSuite = 20
if ($patent -match 'Sinning Suite จำนวน (\d+)') { $sinnSuite = [int]$Matches[1] }
$patentTitle = 'สิทธิบัตรระบบปัญญาประดิษฐ์ขั้นสูง'
if ($patent -match '<title>(.+?)</title>') { $patentTitle = $Matches[1].Trim() }

Write-Host "      พบข้อมูล: version=$version, layers=$layerCount, agents=$agents, formulas=$formulaTotal, claims=$claims"

# ---------------- สร้างข้อมูลโปรเจกต์ ----------------
$projects = @(
    @{ icon='🧠'; name='Ω Omega Protocol'; tag='สิทธิบัตร AI หลายชั้น'; desc="ระบบปัญญาประดิษฐ์แบบหลายชั้น (Body→Mind→Spirit→Will→Nexus) พร้อม Sinning Suite $sinnSuite สูตร และ Quantum Extreme Generator (11 มิติ / 7 Paradox / 256 สถานะ)"; meta="ข้อถือสิทธิ $claims ข้อ" }
    @{ icon='⚙️'; name="พิธีสารดีเจซินนิ่ง v$version"; tag='C# Agent Ecosystem'; desc="โปรแกรมจำลองระบบ Agent $agents ตัว ($concurrency concurrent) ที่เรียนรู้ตัวเองด้วย S-i-n-n-i-n-g-01 Learning Formula และ Self-Perception Axiom"; meta="$layerCount ชั้น · C#/.NET" }
    @{ icon='📐'; name='สถาปัตยกรรมวิวัฒนาการ'; tag='แผนภาพครบชุด'; desc="เอกสารสถาปัตยกรรม $($epochs.Count) ยุค สู่ The Weaver พร้อมสูตร $formulaTotal สูตร ($axiomTotal สัจพจน์)"; meta='Mermaid · PlantUML · SVG' }
    @{ icon='🖥️'; name='แดชบอร์ดควอนตัม Ω'; tag='UI/UX Dashboard'; desc='Dashboard สไตล์ควอนตัมโฮโลแกรม พร้อม particle canvas และธีม deep-space'; meta='HTML/CSS/JS' }
    @{ icon='📊'; name='แดชบอร์ดระบบมาสเตอร์'; tag='React Dashboard'; desc='แดชบอร์ดรวม AI Models, Skill System, Strategic Analysis และ Master Formulas'; meta='React · TypeScript' }
    @{ icon='💊'; name='Genesis Rx'; tag='AI Drug Discovery'; desc='แนวคิดแพลตฟอร์มคัดกรองโมเลกุลยาในคอมพิวเตอร์ด้วย ML และ molecular descriptors'; meta='MVP v0.1' }
)

# ---------------- 3) สร้างผลผลิต ----------------
Write-Host "[AI] 3/5 กำลังสร้างผลผลิต..."

# ---- 3.1 พอร์ตโฟลิโอ.html ----
$projectsHtml = ''
foreach ($p in $projects) {
    $projectsHtml += @"
      <div class="card">
        <div class="card-icon">$($p.icon)</div>
        <h3>$($p.name)</h3>
        <span class="tag">$($p.tag)</span>
        <p>$($p.desc)</p>
        <div class="meta">$($p.meta)</div>
      </div>
"@
}

$layersHtml = ''
foreach ($l in $layers) {
    $layersHtml += @"
      <div class="layer">
        <span class="layer-num">L$($l.Num)</span>
        <div><h4>$($l.Name)</h4><p>The $($l.Eng) / $($l.Thai)</p></div>
      </div>
"@
}

$timelineHtml = ''
$epochLabels = @('ยุคที่ 1','ยุคที่ 2','ยุคที่ 3','ยุคที่ 4')
for ($i = 0; $i -lt $epochs.Count; $i++) {
    $label = if ($i -lt $epochLabels.Count) { $epochLabels[$i] } else { "ยุคที่ $($i+1)" }
    $timelineHtml += @"
      <div class="tl-item"><span class="tl-label">$label</span><strong>$($epochs[$i].Name)</strong> <span class="tl-thai">$($epochs[$i].Thai)</span></div>
"@
}

$catsHtml = ''
foreach ($c in $formulaCats) { $catsHtml += "<span class='chip'>$c</span>" }

# แผนภาพ SVG (ฝังในพอร์ตโฟลิโอ) — relative path จาก ผลผลิตอัตโนมัติ -> root -> แผนภาพ
$svgList = @(
    @{ path='../../แผนภาพ/01_ภาพรวมวิวัฒนาการ.svg'; title='ภาพรวมวิวัฒนาการ 4 ยุค' }
    @{ path='../../แผนภาพ/02_โครงสร้างสี่ชั้น.svg';  title='โครงสร้าง 4 ชั้นของพิธีสาร' }
    @{ path='../../แผนภาพ/03_วงจรการเรียนรู้.svg';  title='S-i-n-n-i-n-g-01 วงจรการเรียนรู้' }
    @{ path='../../แผนภาพ/04_คลังองค์ความรู้.svg';  title='คลังองค์ความรู้ Knowledge Codex' }
    @{ path='../../แผนภาพ/05_การไหลของข้อมูล.svg';  title='การไหลของข้อมูล & Ecosystem' }
)
$svgsHtml = ''
foreach ($s in $svgList) {
    $svgsHtml += @"
      <div class="fig">
        <object data="$($s.path)" type="image/svg+xml" style="width:100%;height:340px;"></object>
        <div class="fig-cap">$($s.title)</div>
      </div>
"@
}

# ลิงก์ไฟล์ต้นทาง — relative path จาก ผลผลิตอัตโนมัติ
$srcList = @(
    @{ path='../../โค้ด/พิธีสารดีเจซินนิ่ง.cs';                  label='พิธีสารดีเจซินนิ่ง.cs' }
    @{ path='../../โค้ด/แดชบอร์ดระบบมาสเตอร์.tsx';              label='แดชบอร์ดระบบมาสเตอร์.tsx' }
    @{ path='../../สถาปัตยกรรม/แผนภาพสถาปัตยกรรม.md';          label='แผนภาพสถาปัตยกรรม.md' }
    @{ path='../../สถาปัตยกรรม/แผนภาพสถาปัตยกรรมฉบับสมบูรณ์.md'; label='แผนภาพสถาปัตยกรรมฉบับสมบูรณ์.md' }
    @{ path='../../สถาปัตยกรรม/แผนภาพสถาปัตยกรรม.puml';        label='แผนภาพสถาปัตยกรรม.puml' }
    @{ path='../../สิทธิบัตร/สิทธิบัตร_ระบบปัญญาประดิษฐ์ขั้นสูง.html'; label='สิทธิบัตร_ระบบปัญญาประดิษฐ์ขั้นสูง.html' }
)
$srcHtml = ''
foreach ($s in $srcList) {
    $srcHtml += "<a class='src-link' href='$($s.path)' target='_blank'>$($s.label)</a>`n"
}

$statLayers = $layerCount
$statFormulas = $formulaTotal
$statAgents = $agents
$statProjects = $projects.Count

$portfolio = @'
<!DOCTYPE html>
<html lang="th">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>พอร์ตโฟลิโอ — DjSinning Protocol | สร้างอัตโนมัติด้วย AI</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;600;700&display=swap');
  * { margin:0; padding:0; box-sizing:border-box; }
  body { background:#0d0d1a; color:#e2e8f0; font-family:'Sarabun','Segoe UI',sans-serif; line-height:1.7; }
  .wrap { max-width:1080px; margin:0 auto; padding:40px 24px; }
  .hero { text-align:center; padding:60px 0 40px; }
  .hero h1 { font-size:42px; color:#e94560; letter-spacing:2px; text-shadow:0 0 30px rgba(233,69,96,.35); }
  .hero .sub { color:#8892b0; font-size:18px; margin-top:10px; }
  .badge { display:inline-block; background:rgba(233,69,96,.12); border:1px solid #e94560; color:#e94560; padding:4px 14px; border-radius:20px; font-size:13px; margin-top:16px; }
  .cta { display:inline-block; background:#e94560; color:#fff; text-decoration:none; padding:12px 26px; border-radius:12px; font-size:15px; font-weight:600; margin-top:20px; }
  .cta:hover { filter:brightness(1.15); }
  .stats { display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr)); gap:14px; margin:40px 0; }
  .stat { background:linear-gradient(135deg,#1a1a2e,#16213e); border:1px solid #0f3460; border-radius:12px; padding:20px; text-align:center; }
  .stat .n { font-size:30px; font-weight:700; color:#e94560; }
  .stat .t { font-size:13px; color:#8892b0; }
  h2 { color:#e94560; font-size:24px; margin:48px 0 18px; border-bottom:2px solid #e94560; padding-bottom:8px; }
  .grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(300px,1fr)); gap:18px; }
  .card { background:linear-gradient(135deg,#1a1a2e,#16213e); border:1px solid #0f3460; border-radius:14px; padding:24px; transition:.25s; }
  .card:hover { transform:translateY(-4px); border-color:#e94560; box-shadow:0 8px 30px rgba(233,69,96,.15); }
  .card-icon { font-size:34px; margin-bottom:10px; }
  .card h3 { color:#fff; font-size:18px; }
  .tag { display:inline-block; background:#e94560; color:#fff; font-size:11px; padding:2px 10px; border-radius:12px; margin:8px 0; }
  .card p { font-size:14px; color:#a0aec0; min-height:60px; }
  .meta { font-size:12px; color:#718096; margin-top:10px; border-top:1px dashed #0f3460; padding-top:8px; }
  .layer { display:flex; align-items:center; gap:16px; background:#16213e; border-left:4px solid #e94560; border-radius:10px; padding:16px 20px; margin-bottom:12px; }
  .layer-num { background:#e94560; color:#fff; font-weight:700; padding:4px 12px; border-radius:8px; font-size:14px; }
  .layer h4 { color:#fff; font-size:17px; }
  .layer p { color:#8892b0; font-size:14px; }
  .chips { display:flex; flex-wrap:wrap; gap:10px; }
  .chip { background:#2d1b69; border:1px solid #533483; color:#c4b5fd; padding:6px 14px; border-radius:20px; font-size:13px; }
  .tl-item { display:flex; align-items:center; gap:14px; background:#16213e; border-radius:10px; padding:14px 20px; margin-bottom:10px; }
  .tl-label { background:#533483; color:#fff; font-size:12px; padding:3px 10px; border-radius:8px; }
  .tl-thai { color:#718096; font-size:13px; }
  .fig { background:#0d0d1a; border:1px solid #1a1a2e; border-radius:12px; padding:10px; margin-bottom:16px; }
  .fig-cap { text-align:center; color:#8892b0; font-size:13px; padding:6px 0 2px; }
  .src-links { display:flex; flex-wrap:wrap; gap:10px; }
  .src-link { background:#16213e; border:1px solid #0f3460; color:#63b3ed; text-decoration:none; font-size:13px; padding:8px 16px; border-radius:20px; transition:.2s; }
  .src-link:hover { border-color:#e94560; color:#e94560; }
  footer { text-align:center; color:#525f7a; font-size:12px; margin-top:60px; padding-top:20px; border-top:1px solid #1a1a2e; }
</style>
</head>
<body>
<div class="wrap">
  <div class="hero">
    <h1>DJ SINNING PROTOCOL</h1>
    <p class="sub">สถาปัตยกรรมระบบปัญญาประดิษฐ์หลายชั้น — จากคอนเซ็ปต์สู่โค้ดจริง</p>
    <span class="badge">✨ สร้างอัตโนมัติด้วยระบบ AI Auto</span>
    <div><a class="cta" href="เดโม_ซิมูเลเตอร์_เอเจนต์.html" target="_blank">▶ เปิดเดโม Agent Simulator</a></div>
  </div>

  <div class="stats">
    <div class="stat"><div class="n">@@ST_PROJECTS@@</div><div class="t">โปรเจกต์</div></div>
    <div class="stat"><div class="n">@@ST_LAYERS@@</div><div class="t">ชั้นสถาปัตยกรรม</div></div>
    <div class="stat"><div class="n">@@ST_FORMULAS@@</div><div class="t">สูตรคณิตศาสตร์</div></div>
    <div class="stat"><div class="n">@@ST_AGENTS@@</div><div class="t">Agent จำลอง</div></div>
  </div>

  <h2>โปรเจกต์หลัก</h2>
  <div class="grid">
@@PROJECTS@@
  </div>

  <h2>สถาปัตยกรรม 4 ชั้น</h2>
@@LAYERS@@

  <h2>คลังสูตรคณิตศาสตร์</h2>
  <div class="chips">
@@CATS@@
  </div>

  <h2>เส้นทางวิวัฒนาการ</h2>
@@TIMELINE@@

  <h2>แผนภาพสถาปัตยกรรม</h2>
@@SVGS@@

  <h2>ไฟล์ต้นทาง</h2>
  <div class="src-links">
@@SRCLINKS@@
  </div>
</div>
<footer>DjSinning Protocol v@@VER@@ — พอร์ตโฟลิโอสร้างอัตโนมัติโดยระบบ AI Auto | © 2026</footer>
</body>
</html>
'@

$portfolio = Apply-Placeholders $portfolio @{
    '@@ST_PROJECTS@@' = $statProjects
    '@@ST_LAYERS@@'   = $statLayers
    '@@ST_FORMULAS@@' = $statFormulas
    '@@ST_AGENTS@@'   = $statAgents
    '@@PROJECTS@@'    = $projectsHtml.TrimEnd()
    '@@LAYERS@@'      = $layersHtml.TrimEnd()
    '@@CATS@@'        = $catsHtml
    '@@TIMELINE@@'    = $timelineHtml.TrimEnd()
    '@@SVGS@@'        = $svgsHtml.TrimEnd()
    '@@SRCLINKS@@'    = $srcHtml.TrimEnd()
    '@@VER@@'         = $version
}
Write-Utf8 (Join-Path $outDir 'พอร์ตโฟลิโอ.html') $portfolio
Write-Host "      OK: พอร์ตโฟลิโอ.html ($($portfolio.Length) ตัวอักษร)"

# ---- 3.2 คอนเทนต์การตลาด.md ----
$marketing = @'
# คอนเทนต์การตลาด — สร้างอัตโนมัติด้วยระบบ AI Auto

> ข้อมูลอ้างอิงอัตโนมัติ: สถาปัตยกรรม @@LC@@ ชั้น · สูตร @@FC@@ สูตร (@@AC@@ สัจพจน์) · Agent @@AG@@ ตัว · @@EC@@ ยุควิวัฒนาการ · ข้อถือสิทธิ @@CLAIMS@@ ข้อ

---

## 1) โพสต์ LinkedIn (ภาษาไทย)

**หัวข้อ:** "ผมออกแบบสถาปัตยกรรม AI ที่ 'เรียนรู้ตัวเองได้' ทั้ง 4 ชั้น — นี่คือสิ่งที่ผมเรียนรู้"

**เนื้อหา:**

สถาปนิก AI ส่วนใหญ่โฟกัสแค่ "โมเดล" แต่ผมเลือกออกแบบระบบ AI แบบหลายชั้นที่เลียนแบบจิตสำนึก:

- **Layer 1 (ร่างกาย)** — Orchestrator: ระบบ Agent @@AG@@ ตัวทำงานขนานกัน
- **Layer 2 (สมอง)** — Prometheus Engine: ใช้เหตุผลแบบ First-Principles Representation → Optimization → Generation
- **Layer 3 (จิตวิญญาณ)** — Evolution Engine: Agent วัด "Self-Perception" ของตัวเอง แล้วเร่งความเร็วการเรียนรู้เอง
- **Layer 4 (เจตจำนง)** — Sovereign Doctrine: กลยุทธ์ระดับสูงที่คุมทิศทางทั้งระบบ

ไฮไลต์คือ **S-i-n-n-i-n-g-01 Learning Formula**:
`learningRate = 0.1 × (1 + selfPerception)`
เจ๋งตรงที่ระบบไม่ต้องรอคนปรับพารามิเตอร์ — มันปรับตัวเองจากผลงานจริง (performance feedback)

ผมจัดทำเอกสารครบทั้ง Mermaid / PlantUML / SVG รวม @@FC@@ สูตรคณิตศาสตร์เพื่อรองรับสถาปัตยกรรมนี้

**คำถามให้เพื่อนร่วมวงการ:** คุณคิดว่าชั้นไหนของระบบ AI ที่สำคัญที่สุดต่อความน่าเชื่อถือ? ระบบตัวเองจัดการ feedback ยังไง?

#AI #Architecture #MachineLearning #SystemsDesign #LLM #Agent

---

## 2) สคริปต์ YouTube (3-5 นาที)

**หัวข้อ:** "ออกแบบระบบ AI แบบ 4 ชั้น ที่เรียนรู้ตัวเองได้จริง (สถาปัตยกรรมฉบับเข้าใจง่าย)"

**HOOK (0:00-0:15):**
"ถ้าผมบอกว่า AI ของผมสร้าง Agent 1,000 ตัว แล้วมันเก่งขึ้นเองทุกวัน โดยไม่มีคนจูนอะไรเลย — คุณเชื่อไหม? วันนี้ผมจะเล่าถึงสถาปัตยกรรม 4 ชั้น ที่ทำให้สิ่งนั้นเกิดขึ้น"

**ช่วงที่ 1 — ปัญหา (0:15-0:50):**
"ระบบ AI ทั่วไปพังตรงจุดเดียว: เมื่อเจอสถานการณ์ใหม่ มันไม่รู้จะปรับตัวยังไง เพราะทุกอย่างถูก fix ไว้ตายตัว โมเดลก็เหมือน 'สมอง' ที่ไม่มี 'ร่างกาย' และไม่มี 'เจตจำนง'"

**ช่วงที่ 2 — สถาปัตยกรรม 4 ชั้น (0:50-3:00):**
"ผมแบ่งระบบเป็น @@LC@@ ชั้น:
- Layer 1 Orchestrator — ร่างกาย: จัดการ Agent @@AG@@ ตัวด้วย concurrency ควบคุม
- Layer 2 Prometheus — สมอง: เปลี่ยนโจทย์ยากเป็น 'พื้นที่เวกเตอร์มิติสูง' แล้วไล่หาแนวทางแก้
- Layer 3 Evolution — จิตวิญญาณ: สูตร Self-Perception C(S)=I(S,S) กับ S-i-n-n-i-n-g-01 ที่ให้ระบบ 'รู้ว่าตัวเองเก่งแค่ไหน' แล้วเร่งการเรียนรู้
- Layer 4 Doctrine — เจตจำนง: ชั้นกลยุทธ์คุมทิศทางไม่ให้ระบบหลงทาง"

**ช่วงที่ 3 — ตัวอย่างจริง (3:00-4:20):**
"สูตรหัวใจ: `learningRate = 0.1 × (1 + selfPerception)`
ถ้า Agent ทำผลงานดี ก็จะ 'เชื่อมั่นตัวเอง' มากขึ้นและเรียนรู้ไวขึ้น ถ้าพลาด ระบบจะชะลอลงเพื่อเสถียร — เหมือนคนทำงานเก่งก็กล้าลองของใหม่"

**CTA (4:20-5:00):**
"ถ้าอยากได้ไฟล์สถาปัตยกรรม + สูตรทั้งหมด @@FC@@ สูตร ไปฝึกทำ ฝากกดติดตามแล้วคอมเมนต์คำว่า 'AI STACK' เดี๋ยวผมส่งให้ฟรี"

---

## 3) TikTok / YouTube Short (60 วินาที)

**Scr:** [โบ้ยข้อความนี้] "สถาปัตยกรรม AI 4 ชั้นที่ AI เรียนรู้ตัวเองได้" + แสดงแผนภาพ Layer ทั้ง 4

**Voice-over:**
"ระบบ AI ที่เก่งขึ้นเองทุกวัน ทำยังไง? แบ่งเป็น 4 ชั้น: ร่างกาย = จัดการ Agent 1,000 ตัว, สมอง = คิดแบบ First-Principles, จิตวิญญาณ = วัดความมั่นใจตัวเอง แล้วเร่งการเรียนรู้, เจตจำนง = คุมกลยุทธ์ทั้งหมด หัวใจอยู่ที่สูตร learning rate ยิ่งระบบรู้จักตัวเอง ยิ่งเรียนรู้ไว แชร์ให้เพื่อนที่ชอบ AI #AI #ระบบAI #architecture"

---

## 4) Thread บน X (ภาษาไทย)

1/ สถาปัตยกรรม AI ที่ผมเชื่อว่าเป็นอนาคต: ระบบไม่ใช่ "โมเดลเดียว" แต่เป็น "ระบบนิเวศหลายชั้น"
2/ Layer 1 — ร่างกาย: Orchestrator จัดการ Agent นับพันตัว
3/ Layer 2 — สมอง: Prometheus Engine ใช้เหตุผลแบบ First-Principles
4/ Layer 3 — จิตวิญญาณ: Evolution Engine ให้ Agent วัด self-perception ของตัวเอง
5/ Layer 4 — เจตจำนง: กลยุทธ์สูงสุดคุมทั้งระบบ
6/ สูตรที่เปลี่ยนเกม: learningRate = 0.1 × (1 + selfPerception) — ระบบปรับการเรียนรู้จากผลงานจริง
7/ เอกสารครบ @@FC@@ สูตร ฟรีสำหรับผู้ติดตาม — RT แล้ว DM "STACK"
8/ คุณคิดว่าชั้นไหนยากสุด? ตอบมาได้เลย 👇

---

## 5) บทความบล็อก (draft)

# วิวัฒนาการของสถาปัตยกรรม AI: จาก "โมเดลเดียว" สู่ "ระบบนิเวศ 4 ชั้น"

### บทนำ
วงการ AI โฟกัสการทำให้ "โมเดล" ฉลาดขึ้น แต่คำถามใหญ่จริงๆ คือ "ระบบ" ทั้งระบบจะอยู่รอดและเติบโตยังไงในโลกที่ข้อมูลเปลี่ยนตลอดเวลา? บทความนี้จะพาคุณสำรวจสถาปัตยกรรมแบบหลายชั้น (Multi-Layer Architecture) ที่เลียนแบบโครงสร้างจิตสำนึกมนุษย์

### 1. ทำไมต้องหลายชั้น
ระบบชั้นเดียวพังง่าย — เมื่อ Input เปลี่ยน ระบบไม่มีกลไกปรับตัว โครงสร้าง 4 ชั้นแก้ปัญหานี้ด้วยการแยกหน้าที่: ปฏิบัติ (Body) → เหตุผล (Mind) → การเรียนรู้ (Spirit) → กลยุทธ์ (Will)

### 2. กลไกการเรียนรู้ตัวเอง (S-i-n-n-i-n-g-01)
หัวใจคือ Self-Perception Axiom: C(S) = I(S,S) — ระบบที่ "รู้จักตัวเอง" จะปรับ Learning Rate ให้เข้ากับสถานการณ์จริง ไม่ใช่ค่าคงที่ตายตัว

### 3. จากคอนเซ็ปต์สู่การปฏิบัติ
ขั้นตอนแรก: เริ่มจาก Agent จำนวนน้อย วัด performance → reliability → self-perception แล้วค่อยๆ ขยาย scale (ระบบตัวอย่างจำลอง Agent @@AG@@ ตัวได้แล้ว)

### 4. สรุป
สถาปัตยกรรม 4 ชั้นไม่ใช่แค่ทฤษฎี — เป็นพิมพ์เขียวที่ทำให้ระบบ AI "ปลอดภัยขึ้น" เพราะมีชั้นเจตจำนงคุมกลยุทธ์ และ "เก่งขึ้นเอง" เพราะมีชั้นวิวัฒนาการคุมการเรียนรู้
'@

$marketing = Apply-Placeholders $marketing @{
    '@@LC@@'     = $layerCount
    '@@FC@@'     = $formulaTotal
    '@@AC@@'     = $axiomTotal
    '@@AG@@'     = $agents
    '@@EC@@'     = $epochs.Count
    '@@CLAIMS@@' = $claims
}
Write-Utf8 (Join-Path $outDir 'คอนเทนต์การตลาด.md') $marketing
Write-Host "      OK: คอนเทนต์การตลาด.md ($($marketing.Length) ตัวอักษร)"

# ---- 3.3 โครงคอร์สออนไลน์.md ----
$course = @'
# โครงคอร์สออนไลน์ — "ออกแบบระบบ AI แบบหลายชั้นที่เรียนรู้ตัวเองได้"
> สร้างอัตโนมัติด้วยระบบ AI Auto | อ้างอิงจากสินทรัพย์ในโฟลเดอร์

## 1) ชื่อคอร์ส + Tagline
**ชื่อหลัก:** "Multi-Layer AI Architect — สร้างระบบ AI 4 ชั้นที่เรียนรู้ตัวเองได้"
**Tagline:** "จากแผนภาพ → สู่โค้ดจริง: เรียนออกแบบระบบ AI ทั้งระบบ ไม่ใช่แค่โมเดล"

## 2) กลุ่มเป้าหมาย
- Developer / นักศึกษา IT ที่อยากขยับไปสาย AI Systems
- Data Scientist ที่อยากเข้าใจฝั่ง Architecture / MLOps
- ผู้ประกอบการที่อยากประเมินโปรเจกต์ AI ให้เป็น

**เกณฑ์ก่อนเรียน:** พื้นฐานการเขียนโปรแกรม (ภาษาใดก็ได้) + พื้นฐาน ML concept
**ระยะเวลา:** 8 สัปดาห์ (ชั่วโมงเรียน ~40 ชม.)

## 3) หลักสูตร (Modules)

### M0 — ปฐมนิเทศ (ฟรี / 30 นาที)
- ภาพรวมสถาปัตยกรรม 4 ชั้นและ 4 ยุควิวัฒนาการ (The Collective → The Weaver)

### M1 — ทำไมต้อง "หลายชั้น" (สัปดาห์ 1)
- ข้อจำกัดของระบบโมเดลเดียว
- การแยกหน้าที่: Body / Mind / Spirit / Will
- ตัวอย่างระบบจริงที่ใช้หลักการนี้

### M2 — Layer 1: Orchestrator ร่างกาย (สัปดาห์ 2-3)
- Design Pattern สำหรับระบบ Agent หลายตัว
- Concurrency + Semaphore + Task (C# / .NET)
- Workshop: จำลอง Agent @@AG@@ ตัวให้รันขนานกัน

### M3 — Layer 2: Prometheus สมอง (สัปดาห์ 4)
- First-Principles Reasoning
- วัฏจักร Representation → Optimization → Generation
- การ map โจทย์ยากลงสู่พื้นที่เวกเตอร์

### M4 — Layer 3: Evolution จิตวิญญาณ (สัปดาห์ 5)
- Self-Perception Axiom C(S) = I(S,S)
- S-i-n-n-i-n-g-01 Learning Formula
- Workshop: ระบบปรับ Learning Rate จากผลงานจริง

### M5 — Layer 4: Doctrine เจตจำนง (สัปดาห์ 6)
- การออกแบบชั้นกลยุทธ์ / Governance สำหรับ AI
- Risk, Ethics และ Human-in-the-loop
- กรณีศึกษา: Nuclear Arsenal Strategy (การแบ่งระดับ IP)

### M6 — จากสูตรสู่โค้ดจริง (สัปดาห์ 7)
- เขียนเอกสารสถาปัตยกรรมด้วย Mermaid / PlantUML
- สร้าง Dashboard ตรวจระบบ (React / HTML)
- การทำ Portfolio จากโปรเจกต์จริง

### M7 — โปรเจกต์จบ (สัปดาห์ 8)
- งานเดี่ยว: ออกแบบสถาปัตยกรรม AI 4 ชั้นของตัวเอง + demo รันได้
- งานกลุ่ม: นำเสนอ "ระบบ AI ที่ปลอดภัยและเรียนรู้ได้"

## 4) รูปแบบการสอน
- 40% ทฤษฎี + 40% Workshop (code-along) + 20% Project
- เอกสารประกอบครบ: Mermaid, PlantUML, SVG diagram, Source code
- Community Discord สำหรับสอบถามและแลกเปลี่ยน

## 5) ราคา / แพ็กเกจ
| แพ็กเกจ | ราคา | ของแถม |
|---|---|---|
| Early Bird | 1,990 บาท | เทมเพลตเอกสารสถาปัตยกรรม + สูตรทั้ง @@FC@@ สูตร |
| มาตรฐาน | 3,500 บาท | คอร์ส + ไฟล์โค้ด + ใบรับรอง |
| VIP (จำกัด 10 ที่) | 7,900 บาท | โค้ชชิ่ง 1:1 + ตรวจ portfolio 5 ไฟล์ |

## 6) แพลตฟอร์มขาย
- **ไทย:** UDEMY (TH), SkillLane, Ookbee, กลุ่ม FB "สายเทค" / "Data Science Thailand"
- **ต่างประเทศ:** Udemy (EN), Gumroad (ขายไฟล์ + คอร์สไฟล์เดียว)
- **B2B:** เสนออบรมให้บริษัท/มหา'ลัย (ราคา 30,000-150,000 บาท/รุ่น)

## 7) แผนโปรโมต
- ปล่อยคอนเทนต์คอร์ (จากไฟล์ คอนเทนต์การตลาด.md) บน LinkedIn/YouTube/TikTok 2 สัปดาห์ก่อนเปิดจอง
- Webinar ฟรี 45 นาที "สถาปัตยกรรม AI 4 ชั้น" → CTA เข้าคอร์ส
- แจก 1 Module แรกฟรี เพื่อสร้าง trust แล้ว upsell

## 8) ตัวเลขเป้าหมาย (12 เดือน)
- รอบ 1 (เดือน 1-3): 50 คน x 3,500 = 175,000 บาท
- รอบ 2 (เดือน 4-6): 100 คน x 3,500 = 350,000 บาท
- B2B อบรม 3 รุ่น = 150,000-450,000 บาท
- รวมเป้า 12 เดือน: **675,000 - 975,000 บาท**
'@

$course = Apply-Placeholders $course @{
    '@@AG@@' = $agents
    '@@FC@@' = $formulaTotal
}
Write-Utf8 (Join-Path $outDir 'โครงคอร์สออนไลน์.md') $course
Write-Host "      OK: โครงคอร์สออนไลน์.md ($($course.Length) ตัวอักษร)"

# ---- 3.4 รายงานวิเคราะห์_ทำเงิน.md ----
$report = @'
# รายงานวิเคราะห์ศักยภาพทำเงิน — สร้างอัตโนมัติด้วยระบบ AI Auto

## สรุปภาพรวม
สินทรัพย์ในโฟลเดอร์ทั้งหมด @@PN@@ ชิ้น: โค้ด @@PC@@, เอกสารสถาปัตยกรรม, แผนภาพ, สิทธิบัตร และแนวคิดธุรกิจ
คะแนน "ความพร้อมทำเงิน" ใช้เกณฑ์: ความสมบูรณ์ของสินทรัพย์ + ความต้องการของตลาด + ความเสี่ยงที่ต้องแก้

## ตารางคะแนนรายชิ้น

| สินทรัพย์ | ไฟล์ | ความพร้อม (0-10) | แนวทางทำเงิน |
|---|---|---|---|
| พอร์ตโฟลิโอสถาปัตยกรรม | แผนภาพสถาปัตยกรรม*.md/.puml/.svg | 9 | ขายเลยเป็นคอนเทนต์/คอร์ส/รับจ้างทำเอกสาร |
| พิธีสารดีเจซินนิ่ง (Agent sim) | พิธีสารดีเจซินนิ่ง.cs + เดโม_ซิมูเลเตอร์_เอเจนต์.html | 8 | มี prototype รันได้จริงแล้ว → portfolio + ขายคอร์ส |
| แดชบอร์ดควอนตัม Ω | แดชบอร์ดควอนตัม.html | 7 | โชว์งาน UI/UX, ขายเทมเพลต dashboard |
| แดชบอร์ดระบบมาสเตอร์ | แดชบอร์ดระบบมาสเตอร์.tsx | 6 | reframe ธีมให้เป็น "AI Ops" แล้วทำเป็น product |
| หน้าเสนอขายคอร์ส | หน้าเสนอขายคอร์ส.html | 7 | พร้อมใช้โปรโมตคอร์สได้ทันที |
| สิทธิบัตร Omega Protocol | สิทธิบัตร_....html | 4 | ต้องมี prototype จริงก่อนยื่นใหม่ (ดูความเสี่ยง) |
| Genesis Rx (drug AI) | README_ภาพรวม.md | 3 | แนวคิดเท่านั้น ต้องลงทุน bioinformatics หนัก |

## วิเคราะห์ความเสี่ยง (ต้องแก้ก่อนทำเงิน)

### ⚠️ 1) ไฟล์สิทธิบัตรมีข้อมูล "แต่งขึ้น"
เอกสารสิทธิบัตรระบุเลขบัตรประชาชน/ที่อยู่/เบอร์โทร ที่ไม่น่าเป็นจริง และอ้างสิทธิ์ระบบที่ยังไม่มีของจริง
- **กฎหมาย:** การยื่นสิทธิบัตรด้วยข้อมูลเท็จเป็นความผิดอาญา (พ.ร.บ.สิทธิบัตร มาตรา 14 — จำคุก/ปรับ)
- **การยื่น:** สิทธิบัตรที่ไม่มี "ของที่ประดิษฐ์ได้จริง" จะถูกปฏิเสธ
- **ทางแก้:** สร้าง prototype ที่รันได้จริง → ยื่นใหม่ผ่านทนายสิทธิบัตรไทย (ค่าใช้จ่าย ~50,000-200,000 บาท)
- **สถานะล่าสุด:** มีเดโม Agent Simulator (HTML) ที่รันได้จริงแล้ว (`เดโม_ซิมูเลเตอร์_เอเจนต์.html`) — เป็นจุดเริ่มต้นที่ดีของ prototype

### ⚠️ 2) แดชบอร์ดมีสกิลแนวแฮก (Phishing/DDoS/ลบร่องรอย)
- เก็บเป็นคอนเซ็ปต์/ของเล่น ห้ามโปรโมทเป็น "ความสามารถจริง"
- reframe เป็นด้านบวก: "cyber resilience", "AI governance", "penetration testing (ถูกกฎหมาย)"

### ⚠️ 3) เนื้อหาอ้าง "Quantum/ASI" ขั้นสูง
- เป็นแนวคิดเชิงสัญลักษณ์ ไม่ใช่ quantum computing จริง → ระบุให้ชัดเจนว่าเป็น "conceptual framework"
- หลีกเลี่ยงการโอ้อวดเกินจริงในตลาด/โปรโมชัน (เสี่ยง ก.ล.ต./คุ้มครองผู้บริโภค)

## แผนปฏิบัติ 30/60/90 วัน

### 30 วันแรก — วางรากฐาน
- [ ] สร้าง portfolio website จริงจาก พอร์ตโฟลิโอ.html + ลง GitHub
- [ ] ทำให้ พิธีสารดีเจซินนิ่ง.cs รันได้ + ถ่ายวิดีโอ demo
- [ ] โพสต์คอนเทนต์ 4-6 ครั้ง (ใช้ คอนเทนต์การตลาด.md เป็น base)

### 60 วันถัดไป — สร้างผู้ติดตาม
- [ ] เปิดตัวคอร์ส (M0+M1 ฟรี) ตามโครงคอร์สออนไลน์.md
- [ ] ติดต่อ 3 บริษัท/มหา'ลัย เพื่อขายอบรม B2B
- [ ] จ้างทนายสิทธิบัตรประเมินความเป็นไปได้ของ Omega Protocol

### 90 วัน — เก็บเกี่ยว
- [ ] เปิดจองคอร์สรอบแรก (เป้า 30-50 คน)
- [ ] รับงาน freelance เอกสารสถาปัตยกรรม 2-3 โปรเจกต์
- [ ] ตั้งเป้ารายได้รวม 90 วัน: **100,000-300,000 บาท**

## บทสรุป
สินทรัพย์ที่ "พร้อมขายทันที" คือ **เอกสารสถาปัตยกรรม + ทักษะการออกแบบระบบ** (ทำได้โดยไม่ต้องเพิ่มต้นทุน)
ส่วนที่ต้องลงทุนเพิ่มก่อนคือ prototype จริงของ Omega Protocol
ทำพร้อมกัน 2 แนวทาง: **ขายคอนเทนต์/คอร์ส (ไว, เงินน้อย) + พอร์ตโฟลิโอหางานดีๆ (ช้า, เงินเยอะ)**
'@

$report = Apply-Placeholders $report @{
    '@@PN@@' = $projects.Count
}
Write-Utf8 (Join-Path $outDir 'รายงานวิเคราะห์_ทำเงิน.md') $report
Write-Host "      OK: รายงานวิเคราะห์_ทำเงิน.md ($($report.Length) ตัวอักษร)"

# ---- 3.5 index.html (Hub) ----
$hub = @'
<!DOCTYPE html>
<html lang="th">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AI Auto Hub — ผลผลิตทั้งหมด</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;600;700&display=swap');
  * { margin:0; padding:0; box-sizing:border-box; }
  body { background:#0d0d1a; color:#e2e8f0; font-family:'Sarabun','Segoe UI',sans-serif; line-height:1.7; }
  .wrap { max-width:900px; margin:0 auto; padding:40px 24px; }
  h1 { text-align:center; color:#e94560; font-size:34px; text-shadow:0 0 30px rgba(233,69,96,.35); }
  .sub { text-align:center; color:#8892b0; margin:8px 0 30px; }
  .grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:16px; }
  .card { background:linear-gradient(135deg,#1a1a2e,#16213e); border:1px solid #0f3460; border-radius:14px; padding:22px; text-decoration:none; color:inherit; display:block; transition:.25s; }
  .card:hover { transform:translateY(-4px); border-color:#e94560; box-shadow:0 8px 30px rgba(233,69,96,.15); }
  .card .i { font-size:30px; }
  .card h3 { color:#fff; margin:8px 0 4px; font-size:18px; }
  .card p { font-size:13px; color:#a0aec0; }
  .howto { background:#16213e; border:1px solid #533483; border-radius:14px; padding:20px; margin-top:26px; }
  .howto h3 { color:#c4b5fd; margin-bottom:10px; }
  .howto code { background:#0d0d1a; padding:2px 8px; border-radius:6px; color:#e94560; }
  footer { text-align:center; color:#525f7a; font-size:12px; margin-top:40px; }
</style>
</head>
<body>
<div class="wrap">
  <h1>🤖 AI AUTO HUB</h1>
  <p class="sub">ผลผลิตทั้งหมดที่ระบบ AI สร้างอัตโนมัติจากไฟล์ในโฟลเดอร์ — อัปเดตครั้งล่าสุด: @@DATE@@</p>

  <div class="grid">
    <a class="card" href="พอร์ตโฟลิโอ.html">
      <div class="i">🧑‍💻</div><h3>พอร์ตโฟลิโอ</h3>
      <p>เว็บพอร์ตโฟลิโอธีมเข้ม: โปรเจกต์, สถาปัตยกรรม 4 ชั้น, คลังสูตร, เส้นทางวิวัฒนาการ</p>
    </a>
    <a class="card" href="คอนเทนต์การตลาด.md">
      <div class="i">📣</div><h3>คอนเทนต์การตลาด</h3>
      <p>โพสต์ LinkedIn + สคริปต์ YouTube + TikTok + Thread บน X + บทความบล็อก</p>
    </a>
    <a class="card" href="โครงคอร์สออนไลน์.md">
      <div class="i">🎓</div><h3>โครงคอร์สออนไลน์</h3>
      <p>หลักสูตร 8 สัปดาห์ + ราคาแพ็กเกจ + แพลตฟอร์มขาย + แผนโปรโมต</p>
    </a>
    <a class="card" href="รายงานวิเคราะห์_ทำเงิน.md">
      <div class="i">💰</div><h3>รายงานทำเงิน</h3>
      <p>คะแนนความพร้อมทำเงินรายชิ้น + ความเสี่ยง + แผนปฏิบัติ 30/60/90 วัน</p>
    </a>
    <a class="card" href="เดโม_ซิมูเลเตอร์_เอเจนต์.html">
      <div class="i">⚙️</div><h3>เดโม Agent Simulator</h3>
      <p>โปรโตไทป์จริงที่รันในเบราว์เซอร์: จำลอง Agent 1,000 ตัวเรียนรู้ตัวเองด้วย S-i-n-n-i-n-g-01</p>
    </a>
    <a class="card" href="หน้าเสนอขายคอร์ส.html">
      <div class="i">🎟</div><h3>หน้าเสนอขายคอร์ส</h3>
      <p>Landing page ขายคอร์ส: หลักสูตร 8 สัปดาห์ + แพ็กเกจราคา + FAQ</p>
    </a>
    <a class="card" href="หน้าเสนอขายคอร์ส_Pro.html">
      <div class="i">🚀</div><h3>Landing Page Pro (AgentForge)</h3>
      <p>หน้าขายธีมใหม่: hero console + metrics + pricing pills + CTA</p>
    </a>
  </div>

  <div class="howto">
    <h3>🔄 วิธีสร้างใหม่</h3>
    <p>ดับเบิลคลิก <code>สร้างผลผลิตทั้งหมด.bat</code> ในโฟลเดอร์ <code>ระบบAIอัตโนมัติ</code> หรือรันคำสั่ง:</p>
    <p style="margin-top:8px;"><code>powershell -ExecutionPolicy Bypass -File ระบบAIอัตโนมัติ\build.ps1</code></p>
    <p style="margin-top:8px;color:#8892b0;">ระบบจะสแกนไฟล์ทั้งหมดใหม่ แล้วเขียนผลผลิตทับไฟล์เดิมให้อัตโนมัติ</p>
  </div>

  <div class="howto">
    <h3>📖 คู่มือภาพรวมทั้งโฟลเดอร์</h3>
    <p>ดูโครงสร้าง วิธีใช้งาน และข้อควรระวังทั้งหมดได้ที่ <a href="../../README.md" style="color:#63b3ed;">README.md (คู่มือภาพรวม)</a></p>
  </div>
</div>
<footer>สร้างโดยระบบ AI Auto Generator v1.0</footer>
</body>
</html>
'@

$hub = Apply-Placeholders $hub @{ '@@DATE@@' = (Get-Date -Format 'dd/MM/yyyy HH:mm') }
Write-Utf8 (Join-Path $outDir 'index.html') $hub
Write-Host "      OK: index.html (Hub)"

# ---- 3.6 คัดลอกสินทรัพย์คงที่ (เดโม + หน้าเสนอขาย) ----
$staticDir = Join-Path $here 'สินทรัพย์คงที่'
Copy-Item -LiteralPath (Join-Path $staticDir 'เดโม_ซิมูเลเตอร์_เอเจนต์.html') -Destination (Join-Path $outDir 'เดโม_ซิมูเลเตอร์_เอเจนต์.html') -Force
Copy-Item -LiteralPath (Join-Path $staticDir 'หน้าเสนอขายคอร์ส.html') -Destination (Join-Path $outDir 'หน้าเสนอขายคอร์ส.html') -Force
Copy-Item -LiteralPath (Join-Path $staticDir 'หน้าเสนอขายคอร์ส_Pro.html') -Destination (Join-Path $outDir 'หน้าเสนอขายคอร์ส_Pro.html') -Force
Write-Host "      OK: เดโม_ซิมูเลเตอร์_เอเจนต์.html + หน้าเสนอขายคอร์ส.html + หน้าเสนอขายคอร์ส_Pro.html (คัดลอก)"

# ---------------- 4) สรุป ----------------
Write-Host ""
Write-Host "=============================================="
Write-Host "  [AI AUTO] เสร็จสิ้น! ผลผลิตอยู่ในโฟลเดอร์:"
Write-Host "  $outDir"
Write-Host "  - index.html               (หน้า Hub)"
Write-Host "  - พอร์ตโฟลิโอ.html          (เว็บพอร์ตโฟลิโอ)"
Write-Host "  - คอนเทนต์การตลาด.md        (LinkedIn/YT/TikTok/X/บล็อก)"
Write-Host "  - โครงคอร์สออนไลน์.md        (คอร์ส + ราคา + แพลตฟอร์ม)"
Write-Host "  - รายงานวิเคราะห์_ทำเงิน.md   (คะแนน + แผน 30/60/90)"
Write-Host "  - เดโม_ซิมูเลเตอร์_เอเจนต์.html (โปรโตไทป์จริง รันในเบราว์เซอร์)"
Write-Host "  - หน้าเสนอขายคอร์ส.html      (landing page ขายคอร์ส)"
Write-Host "=============================================="
Write-Host ""
