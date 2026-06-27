# Shabkti — Deployment Plan

---

## Overview

```
Production Architecture:

┌──────────────┐     HTTPS     ┌──────────────┐     TCP      ┌──────────────┐
│  Flutter App │ ─────────────►│   FastAPI     │ ───────────► │  MikroTik    │
│  (APK/iOS)   │               │  (Railway)    │              │  (Router)    │
└──────────────┘               └──────┬───────┘              └──────────────┘
                                      │
                                      ▼
                               ┌──────────────┐
                               │ MongoDB Atlas │
                               │  (Cloud DB)   │
                               └──────────────┘
```

---

## Step 1: MongoDB Atlas (Free Tier)

**ليه؟** بدل Docker على جهازك — database على السحابة 24/7.

### الخطوات:
1. سجّل على [mongodb.com/atlas](https://www.mongodb.com/cloud/atlas)
2. اعمل **Free Cluster** (M0 — مجاني)
3. اختار **Region**: أقرب حاجة لمصر (eu-west أو me-south)
4. من **Database Access** → اعمل user جديد (مثلاً: `shabkti_db` / password قوي)
5. من **Network Access** → أضف `0.0.0.0/0` (يسمح بالاتصال من أي مكان)
6. من **Connect** → **Connect your application** → انسخ الـ connection string:
   ```
   mongodb+srv://shabkti_db:PASSWORD@cluster0.xxxxx.mongodb.net/internet_packages?retryWrites=true&w=majority
   ```
7. هنستخدم الـ URL ده في Railway

---

## Step 2: Backend on Railway

**ليه؟** بدل `python -m uvicorn` على جهازك — server على الإنترنت 24/7.

### الملفات الجاهزة:
- `Procfile` ✅
- `railway.toml` ✅
- `requirements.txt` ✅

### الخطوات:
1. سجّل على [railway.app](https://railway.app)
2. **New Project** → **Deploy from GitHub repo**
3. وصّل الـ GitHub repo بتاعك (backend folder)
4. في **Settings** → **Environment Variables** حط:

| Variable | Value |
|----------|-------|
| `MONGODB_URL` | الـ Atlas connection string من Step 1 |
| `SECRET_KEY` | generate واحد جديد عشوائي |
| `ALGORITHM` | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `1440` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` |
| `SMTP_HOST` | `smtp.gmail.com` |
| `SMTP_PORT` | `587` |
| `SMTP_USER` | `info.shabakti@gmail.com` |
| `SMTP_PASSWORD` | (App Password جديد) |
| `MIKROTIK_HOST` | (Public IP بتاع الراوتر — شوف Step 4) |
| `MIKROTIK_PORT` | `8728` |
| `MIKROTIK_USER` | `shabkti_api` |
| `MIKROTIK_PASSWORD` | (الباسوورد) |
| `ADMIN_USERNAME` | (اختار username) |
| `ADMIN_PASSWORD` | (اختار password قوي) |
| `DEBUG` | `False` |

5. Railway هيعملك URL زي: `https://shabkti-api.up.railway.app`
6. شغّل الـ seed data من Railway CLI:
   ```
   railway run python seed_data.py
   ```

---

## Step 3: Flutter App Update

### غيّر الـ API URL:
```dart
// lib/core/constants.dart
static const String apiBaseUrl = 'https://shabkti-api.up.railway.app';
```

### Build APK:
```bash
cd flutter_app
flutter build apk --release
```
الـ APK هيكون في: `build/app/outputs/flutter-apk/app-release.apk`

### Build iOS (لو عندك Mac):
```bash
flutter build ios --release
```

---

## Step 4: MikroTik Public Access

**المشكلة:** Railway server على الإنترنت، بس الراوتر على شبكة محلية.

### الحل A: Port Forwarding (أبسط)
1. في الـ D-Link router: **Port Forwarding**
2. Forward port `8728` → MikroTik IP `192.168.88.1:8728`
3. اعرف الـ Public IP بتاعك من [whatismyip.com](https://whatismyip.com)
4. حط الـ Public IP في Railway environment: `MIKROTIK_HOST=YOUR_PUBLIC_IP`

**ملاحظة:** لو الـ ISP بيغيّر الـ IP → محتاج Dynamic DNS (No-IP أو DuckDNS — مجاني)

### الحل B: VPN Tunnel (أأمن)
- WireGuard أو ZeroTier بين Railway والراوتر
- أكثر أمان بس أعقد في الإعداد

### الحل C: MikroTik على VPS (الأقوى)
- لو الراوتر في مكان ثابت (مكتب/محل) → الحل A كافي
- لو محتاج reliability عالي → MikroTik CHR على VPS

---

## Step 5: Domain (اختياري)

1. اشتري domain (مثلاً `shabkti.net`) من Namecheap أو GoDaddy
2. في Railway: **Settings** → **Custom Domain** → أضف الـ domain
3. Railway هيديك DNS records تحطها في domain provider

**النتيجة:**
- API: `https://api.shabkti.net`
- Admin: `https://api.shabkti.net/admin`

---

## Step 6: Security Checklist قبل الـ Production

| # | Task | Status |
|---|------|--------|
| 1 | `.env` مش في Git | ✅ (gitignore) |
| 2 | Admin dashboard محمي بـ login | ✅ |
| 3 | MikroTik test endpoints محذوفة | ✅ |
| 4 | XSS في admin محمي | ✅ |
| 5 | CORS مظبوط | ✅ |
| 6 | File upload محدود بـ 5MB | ✅ |
| 7 | OTP cryptographically secure | ✅ |
| 8 | `DEBUG=False` في production | ⏳ (في Railway env) |
| 9 | HTTPS only | ⏳ (Railway بيعمله تلقائي) |
| 10 | SMTP password جديد | ⏳ (rotate قبل deploy) |
| 11 | SECRET_KEY جديد | ⏳ (generate قبل deploy) |

---

## Deployment Order

```
1. أنشئ MongoDB Atlas cluster + database user
   ↓
2. أنشئ GitHub repo + push الكود
   ↓
3. أنشئ Railway project + ربطه بالـ repo
   ↓
4. حط الـ environment variables في Railway
   ↓
5. شغّل seed_data.py
   ↓
6. اختبر الـ API: https://YOUR-APP.up.railway.app/health
   ↓
7. حدّث الـ Flutter API URL
   ↓
8. ظبط MikroTik port forwarding
   ↓
9. اختبر الـ full flow
   ↓
10. Build APK
   ↓
✅ Production Ready
```

---

## Cost Estimate

| Service | Cost |
|---------|------|
| MongoDB Atlas (M0) | **مجاني** (512MB storage) |
| Railway (Starter) | **$5/month** (أو مجاني مع limits) |
| Domain (اختياري) | ~$10/year |
| **Total** | **$5/month** أو مجاني |
