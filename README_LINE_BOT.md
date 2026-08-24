# LINE Auto-Reply Bot — คู่มือใช้งาน (PowerShell Edition)

Bot ตอบแชทลูกค้าอัตโนมัติ 24 ชม. บนเครื่องของคุณ — ไม่ต้องติดตั้ง Node/Python อะไรเลย

## โครงสร้างไฟล์

```
line-bot/
├── config.json          ← ใส่ token + ข้อความ FAQ (แก้ไฟล์นี้)
├── line-bot.ps1         ← ตัวเซิร์ฟเวอร์ webhook
├── start-line-bot.bat   ← ★ ดับเบิลคลิก = เปิด bot
├── start-tunnel.bat     ← ★ ดับเบิลคลิก = เปิดช่องทาง internet → เครื่องคุณ
└── logs/                ← บันทึกแชททุกข้อความ
```

## ขั้นตอนตั้งค่าครั้งแรก (~15 นาที)

### 1) สร้าง LINE Official Account + ขอ Token
1. สมัครฟรีที่ https://www.lycbiz.com/th/ (หรือ managers.line.biz) → สร้าง Official Account
2. เข้า https://developers.line.biz/console → สร้าง **Messaging API channel**
3. ที่แท็บ **Messaging API** กด **Issue** เพื่อ copy 2 ค่า:
   - `Channel access token` → วางใน `config.json` ช่อง `LINE_CHANNEL_ACCESS_TOKEN`
   - `Channel secret` (แท็บ Basic settings) → วางในช่อง `LINE_CHANNEL_SECRET`
4. ปิดการตอบอัตโนมัติข้อความสำเร็จของ LINE OA (ใน LINE Official Account Manager → การตั้งค่าการตอบ)

### 2) เปิด Bot
- ดับเบิลคลิก `start-line-bot.bat` → เห็น "Listening on http://localhost:3000" = พร้อม

### 3) เปิด Tunnel (ให้ LINE ติดต่อเข้าเครื่องคุณได้)
- ดับเบิลคลิก `start-tunnel.bat` (ดาวน์โหลด cloudflared อัตโนมัติครั้งแรก)
- Copy URL ที่ขึ้น เช่น `https://aaaa-bbbb.trycloudflare.com`

### 4) ผูก Webhook
1. กลับที่ LINE Developers Console → Messaging API → **Webhook settings**
2. Webhook URL = `https://aaaa-bbbb.trycloudflare.com/webhook`
3. เปิดสวิตช์ **Use webhook** แล้วกด **Verify** → ต้องขึ้น Success

### 5) ทดสอบ
- เพิ่มเพื่อน Official Account ของคุณ แล้วส่งข้อความ "ราคา" → bot ต้องตอบแพ็กเกจทันที

## โหมดการตอบ

| โหมด | เงื่อนไข | ค่าใช้จ่าย |
|---|---|---|
| Keyword FAQ | default | **ฟรี** (reply API ไม่มีค่าใช้จ่าย) |
| AI ตอบอัจฉริยะ | ใส่ `OPENAI_API_KEY` ใน config.json | ~0.5–1 ฿/ข้อความ |

**แก้คำตอบ FAQ:** แก้ข้อความใน `config.json` (`faqPrice`, `faqCourse`, `faqSignup`, `fallbackMessage`) แล้ว restart bot

### เปิดรับชำระเงินตามแพ็กเกจ

ใส่ลิงก์ชำระเงินจริงของแต่ละแพ็กเกจใน `checkoutLinks` แล้ว restart bot:

```json
"checkoutLinks": {
   "Early Bird": "https://your-payment-link.example/early-bird",
   "มาตรฐาน": "https://your-payment-link.example/standard",
   "VIP": "https://your-payment-link.example/vip"
}
```

เมื่อผู้สนใจพิมพ์ `สนใจ VIP`, `จอง` หรือ `สมัคร` บอทจะเลือกแพ็กเกจ, ส่งลิงก์ชำระเงิน และบันทึก lead ลงไฟล์ `logs/chat-YYYYMMDD.txt`

## ⚠️ ข้อควรรู้

1. **Quick tunnel URL เปลี่ยนทุกครั้งที่รัน `start-tunnel.bat` ใหม่** → ต้องไปแก้ Webhook URL ใหม่ด้วย ถ้าอยากได้ domain ถาวร สมัคร Cloudflare (ฟรี) แล้วใช้ named tunnel — บอกผมได้ จะเขียนขั้นตอนเพิ่ม
2. เครื่องต้องเปิดค้างไว้ 2 หน้าต่าง (bot + tunnel) ถึงจะตอบได้ 24 ชม.
3. `config.json` มี token = **รหัสผ่าน** ห้ามส่งให้ใคร / ห้ามอัปขึ้นเว็บ
4. แชททุกข้อความถูกบันทึกใน `logs/` — ใช้ทบทวนลูกค้าได้

## Troubleshooting

| อาการ | แก้ |
|---|---|
| Verify webhook ไม่ผ่าน | เช็คว่า URL ลงท้าย `/webhook` + bot window ยังเปิดอยู่ |
| รับแต่ไม่ตอบ | `LINE_CHANNEL_ACCESS_TOKEN` ว่าง หรือ token หมดอายุ (Issue ใหม่) |
| Signature error ใน log | `LINE_CHANNEL_SECRET` ไม่ตรงกับ channel |
