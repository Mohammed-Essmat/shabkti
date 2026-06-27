# Shabakti (شبكتي) — Project Status Report

---

## 1. عن المشروع

| | |
|---|---|
| **الاسم** | Shabakti (شبكتي) |
| **النوع** | Graduation Project — MVP/Prototype |
| **الهدف** | تطبيق موبايل لإدارة اشتراكات باقات الإنترنت |
| **الـ User** | يقدر يسجل حساب، يختار باقة، يدفع، يتابع استهلاكه، يضيف مستفيدين |

---

## 2. الـ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend API | FastAPI (Python) |
| Database | MongoDB Atlas |
| ODM | Beanie |
| Auth | JWT (access + refresh tokens) |
| Password Hashing | bcrypt |
| OTP Email | Gmail SMTP |
| OTP SMS | Twilio |
| Image Upload | Cloudinary |
| Payment | Paymob API + Manual (Vodafone Cash / Instapay) |
| Hosting | Railway.app |

---

## 3. حالة المشروع الحالية

| Phase | الحالة | التفاصيل |
|-------|--------|----------|
| Backend | ✅ خلص 100% | 28 endpoint شغالين ومتجربين |
| Design System | ✅ خلص | Light + Dark mode من Stitch.ai |
| UI Screens (Stitch) | ⏳ جاهزة | محتاج أشوفهم عشان أطبقهم |
| Flutter App | ❌ لسه | الخطوة الجاية |
| Backend Testing | ✅ خلص | كل الـ imports + logic tests ناجحة |
| Deployment Files | ✅ جاهزة | Procfile + railway.toml موجودين |

---

## 4. الـ Backend — ملخص كامل

### 4.1 البنية

```
backend/
├── app/
│   ├── main.py              — Entry point + middleware + routers
│   ├── config.py            — Environment variables
│   ├── database.py          — MongoDB connection
│   ├── models/              — MongoDB document models
│   │   ├── user.py          — User + Beneficiary
│   │   ├── package.py       — Internet packages
│   │   ├── subscription.py  — User subscriptions
│   │   ├── payment.py       — Payment records
│   │   └── otp.py           — OTP codes
│   ├── schemas/             — Request/Response validation
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── package.py
│   │   ├── subscription.py
│   │   └── beneficiary.py
│   ├── routers/             — API endpoints
│   │   ├── auth.py          — /api/auth/*
│   │   ├── users.py         — /api/users/*
│   │   ├── packages.py      — /api/packages/*
│   │   ├── subscriptions.py — /api/subscriptions/*
│   │   └── beneficiaries.py — /api/beneficiaries/*
│   ├── services/
│   │   ├── otp_service.py   — OTP generation + email/SMS
│   │   ├── storage_service.py — Cloudinary upload
│   │   ├── usage_service.py   — Simulated data usage
│   │   └── payment_service.py — Paymob integration
│   └── utils/
│       ├── security.py      — bcrypt + JWT
│       └── dependencies.py  — Auth middleware
├── seed_data.py             — 4 packages data
├── requirements.txt
├── .env / .env.example
├── Procfile
├── railway.toml
└── README.md
```

### 4.2 الـ API Endpoints (28 endpoint)

#### Auth — `/api/auth` (بدون token)

| Method | Endpoint | الوظيفة |
|--------|----------|---------|
| POST | `/register` | إرسال OTP على الإيميل والتليفون |
| POST | `/verify-otp` | التحقق من كود الـ OTP |
| POST | `/set-password` | إنشاء الحساب بعد التحقق |
| POST | `/login` | تسجيل الدخول → access + refresh token |
| POST | `/refresh` | تجديد الـ access token |

#### Users — `/api/users` (محتاج token)

| Method | Endpoint | الوظيفة |
|--------|----------|---------|
| GET | `/me` | بيانات المستخدم الحالي |
| PUT | `/me` | تحديث الاسم |
| POST | `/upload-picture` | رفع صورة شخصية |
| PUT | `/password` | تغيير كلمة السر |
| DELETE | `/me` | حذف الحساب |

#### Packages — `/api/packages` (محتاج token)

| Method | Endpoint | الوظيفة |
|--------|----------|---------|
| GET | `/` | كل الباقات المتاحة |
| GET | `/{id}` | تفاصيل باقة واحدة |

#### Subscriptions — `/api/subscriptions` (محتاج token)

| Method | Endpoint | الوظيفة |
|--------|----------|---------|
| POST | `/` | إنشاء اشتراك جديد (pending) |
| GET | `/active` | الاشتراك النشط الحالي |
| GET | `/history` | تاريخ كل الاشتراكات |
| GET | `/{id}/usage` | إحصائيات الاستهلاك |
| POST | `/{id}/upload-payment` | رفع إثبات دفع → تفعيل تلقائي |
| POST | `/{id}/add-data` | إضافة باقة إضافية |

#### Beneficiaries — `/api/beneficiaries` (محتاج token)

| Method | Endpoint | الوظيفة |
|--------|----------|---------|
| POST | `/` | إضافة مستفيد |
| GET | `/` | قائمة المستفيدين |
| PUT | `/{id}` | تعديل اسم مستفيد |
| DELETE | `/{id}` | حذف مستفيد |

### 4.3 الـ Flows الأساسية

**Registration Flow:**
```
register(name, email, phone)
  → OTP يتبعت على الإيميل والـ SMS
  → verify-otp(email, code)
  → set-password(email, password, confirm)
  → الحساب يتنشأ في database
```

**Subscription + Payment Flow:**
```
POST /subscriptions(package_id)
  → subscription بـ status=pending + payment record
  → أرقام الدفع ترجع (Vodafone Cash / Instapay)
  → المستخدم يحوّل ويرفع صورة الإيصال
POST /subscriptions/{id}/upload-payment(file)
  → الصورة ترتفع على Cloudinary
  → Payment → completed
  → Subscription → active + end_date يتحسب
```

**Beneficiary Logic:**
```
- المستفيد = User عادي بـ role="beneficiary"
- ليه إيميل وباسوورد وبيقدر يعمل login مستقل
- بيشارك نفس subscription data مع الـ owner
- الـ owner يقدر يضيفه / يعدّله / يحذفه
```

### 4.4 ملاحظات MVP

- الـ OTP في dev mode بيتطبع في الـ console (مش بيتبعت فعلاً)
- Payment بيتعمل auto-verify بعد رفع الصورة (مفيش admin review)
- استهلاك البيانات simulated (مش real network data)
- لو Cloudinary مش configured، الـ upload بيتتجاوز

---

## 5. الـ Design System

### 5.1 Light Mode

| Element | Value |
|---------|-------|
| Primary | `#004ac6` |
| Primary Container | `#2563eb` |
| Background | `#f8f9ff` |
| Surface | `#ffffff` |
| On-Surface (Text) | `#0b1c30` |
| Error | `#ba1a1a` |

### 5.2 Dark Mode

| Element | Value |
|---------|-------|
| Primary | `#adc6ff` |
| Background | `#0b1326` |
| Surface | `#171f33` |
| Surface Container | `#222a3d` |
| On-Surface (Text) | `#dae2fd` |
| Error | `#ffb4ab` |

### 5.3 Typography & Spacing

- Font: **Inter**
- Border Radius: 8px (default), 12px (cards), 16px (large containers)
- Spacing: 8px base unit (xs=4, sm=8, md=16, lg=24, xl=32)
- Button Height: 48-56px
- Touch Target: min 48x48px

---

## 6. خطة بناء الـ Flutter

### Phase A — الأساسيات (4 ملفات)

| # | الملف | الوظيفة |
|---|-------|---------|
| A1 | `pubspec.yaml` | كل الـ dependencies |
| A2 | `main.dart` | Entry point + theme + routing |
| A3 | `core/theme.dart` | Light + Dark theme |
| A4 | `core/constants.dart` | API URL, ألوان, strings |

### Phase B — الـ Models (4 ملفات)

| # | الملف | يقابله في الـ Backend |
|---|-------|---------------------|
| B1 | `models/user.dart` | UserResponse schema |
| B2 | `models/package.dart` | PackageResponse schema |
| B3 | `models/subscription.dart` | SubscriptionResponse schema |
| B4 | `models/payment.dart` | PaymentInfoResponse schema |

### Phase C — الـ Services / API Layer (7 ملفات)

| # | الملف | الوظيفة |
|---|-------|---------|
| C1 | `services/api_client.dart` | HTTP client + token في كل request |
| C2 | `services/auth_service.dart` | register, verify, login, refresh |
| C3 | `services/user_service.dart` | profile, update, upload picture |
| C4 | `services/package_service.dart` | get packages |
| C5 | `services/subscription_service.dart` | subscriptions + payment upload |
| C6 | `services/beneficiary_service.dart` | add, list, update, delete |
| C7 | `services/storage_service.dart` | SharedPreferences (token, user) |

### Phase D — State Management (5 ملفات)

| # | الملف | الوظيفة |
|---|-------|---------|
| D1 | `providers/auth_provider.dart` | حالة الـ login/logout |
| D2 | `providers/user_provider.dart` | بيانات المستخدم |
| D3 | `providers/package_provider.dart` | قائمة الباقات |
| D4 | `providers/subscription_provider.dart` | الاشتراك + usage |
| D5 | `providers/theme_provider.dart` | Dark/Light mode toggle |

### Phase E — Widgets المشتركة (6 ملفات)

| # | الملف | الوظيفة |
|---|-------|---------|
| E1 | `widgets/custom_button.dart` | Primary + Secondary buttons |
| E2 | `widgets/custom_text_field.dart` | Input fields |
| E3 | `widgets/package_card.dart` | كارت الباقة |
| E4 | `widgets/loading_widget.dart` | Loading indicator |
| E5 | `widgets/usage_chart.dart` | Circular progress للاستهلاك |
| E6 | `widgets/bottom_nav_bar.dart` | Bottom navigation |

### Phase F — الـ Screens (19 شاشة)

| # | الملف | الشاشة |
|---|-------|--------|
| F1 | `screens/splash_screen.dart` | Splash |
| F2 | `screens/login_screen.dart` | تسجيل الدخول |
| F3 | `screens/register/step1_screen.dart` | التسجيل — بيانات شخصية |
| F4 | `screens/register/step2_otp_screen.dart` | التسجيل — OTP |
| F5 | `screens/register/step3_password_screen.dart` | التسجيل — كلمة السر |
| F6 | `screens/home_screen.dart` | Main wrapper + bottom nav |
| F7 | `screens/home/dashboard_screen.dart` | الصفحة الرئيسية |
| F8 | `screens/home/package_details_screen.dart` | تفاصيل الباقة |
| F9 | `screens/payment/payment_screen.dart` | اختيار طريقة الدفع |
| F10 | `screens/payment/payment_upload_screen.dart` | رفع إثبات الدفع |
| F11 | `screens/payment/payment_success_screen.dart` | نجاح الدفع |
| F12 | `screens/usage/usage_dashboard_screen.dart` | متابعة الاستهلاك |
| F13 | `screens/usage/empty_state_screen.dart` | مفيش اشتراك |
| F14 | `screens/profile/profile_screen.dart` | الملف الشخصي |
| F15 | `screens/profile/edit_profile_screen.dart` | تعديل البيانات |
| F16 | `screens/profile/change_password_screen.dart` | تغيير كلمة السر |
| F17 | `screens/beneficiaries/beneficiaries_screen.dart` | إدارة المستفيدين |
| F18 | `screens/beneficiaries/add_beneficiary_sheet.dart` | إضافة مستفيد |
| F19 | `screens/history/subscription_history_screen.dart` | سجل الاشتراكات |

### Phase G — اللمسات الأخيرة

| # | المهمة |
|---|--------|
| G1 | RTL setup + Arabic strings |
| G2 | ربط Dark/Light mode toggle |
| G3 | Error handling + loading states |
| G4 | تجربة كاملة مع الـ Backend |

---

## 7. المطلوب منك قبل ما نبدأ Flutter

| # | المطلوب | السبب |
|---|---------|-------|
| 1 | **صور الـ screens من Stitch** | عشان أبني كل screen مطابق للـ design |
| 2 | **لوجو Shabakti** (PNG) | Splash + Login + assets |
| 3 | **شغّل `flutter --version`** | أتأكد إن Flutter SDK مثبت |
| 4 | **هتجرب على Emulator ولا موبايل؟** | يفرق في الـ setup |
| 5 | **تفضيل State Management** | Provider (أبسط) ولا Riverpod ولا GetX |
| 6 | **الـ Backend على localhost ولا Railway؟** | عشان أحدد الـ API URL |

---

## 8. ترتيب الشغل المتبقي

```
[الخطوة الحالية] ← أنت هنا
    │
    ▼
1. ترد على الأسئلة في القسم 7
    │
    ▼
2. نبدأ Flutter — Phase A (أساسيات + theme)
    │
    ▼
3. Phase B+C (Models + API Services)
    │
    ▼
4. Phase D (State Management)
    │
    ▼
5. Phase E (Widgets مشتركة)
    │
    ▼
6. Phase F (الشاشات واحدة واحدة)
    │
    ▼
7. Phase G (تجربة + RTL + Dark mode)
    │
    ▼
8. Deploy Backend على Railway
    │
    ▼
9. Build APK للموبايل
    │
    ▼
[✅ المشروع خلص]
```
