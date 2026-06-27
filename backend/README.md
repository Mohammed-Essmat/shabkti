# Internet Packages Backend API

نظام إدارة اشتراكات باقات الإنترنت — Graduation Project MVP

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | FastAPI (Python 3.11+) |
| Database | MongoDB Atlas (Free Tier) |
| ODM | Beanie (async MongoDB ODM) |
| Auth | JWT (access + refresh tokens) |
| Password Hashing | bcrypt |
| OTP Email | Gmail SMTP |
| OTP SMS | Twilio |
| Image Storage | Cloudinary |
| Payment | Paymob API + Manual (Vodafone Cash / Instapay) |
| Hosting | Railway.app |

---

## Project Structure

```
backend/
├── app/
│   ├── main.py              # Entry point — FastAPI app + middleware + routers
│   ├── config.py            # Environment variables (pydantic-settings)
│   ├── database.py          # MongoDB connection + Beanie init
│   ├── models/              # MongoDB document models
│   │   ├── user.py          # User + Beneficiary
│   │   ├── package.py       # Internet packages (daily/weekly/monthly/additional)
│   │   ├── subscription.py  # User subscriptions
│   │   ├── payment.py       # Payment records
│   │   └── otp.py           # OTP codes (auto-expire TTL index)
│   ├── schemas/             # Request/Response Pydantic models
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── package.py
│   │   ├── subscription.py
│   │   └── beneficiary.py
│   ├── routers/             # API endpoints
│   │   ├── auth.py          # /api/auth/*
│   │   ├── users.py         # /api/users/*
│   │   ├── packages.py      # /api/packages/*
│   │   ├── subscriptions.py # /api/subscriptions/*
│   │   └── beneficiaries.py # /api/beneficiaries/*
│   ├── services/
│   │   ├── otp_service.py   # OTP generation, email/SMS sending
│   │   ├── storage_service.py # Cloudinary image upload
│   │   ├── usage_service.py   # Simulated data usage stats
│   │   └── payment_service.py # Paymob API integration
│   └── utils/
│       ├── security.py      # bcrypt hashing + JWT encode/decode
│       └── dependencies.py  # FastAPI auth dependencies
├── seed_data.py             # Populate DB with 4 packages
├── requirements.txt
├── .env.example
├── Procfile                 # Railway deployment
└── railway.toml             # Railway config
```

---

## Setup & Installation

### 1. Clone & Install

```bash
cd wifi_world/backend
pip install -r requirements.txt
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

```env
MONGODB_URL=mongodb+srv://USERNAME:PASSWORD@cluster.mongodb.net/internet_packages?retryWrites=true&w=majority
SECRET_KEY=your-very-long-random-secret-key-here
```

> **Minimum required**: `MONGODB_URL` and `SECRET_KEY`. All other keys are optional for local development — the app runs in dev mode and prints OTPs to the console instead of sending them.

### 3. Seed Database

```bash
python seed_data.py
```

This creates the 4 default packages in MongoDB.

### 4. Run

```bash
uvicorn app.main:app --reload
```

API is available at: `http://localhost:8000`
Swagger docs at: `http://localhost:8000/docs`

---

## API Endpoints

### Auth `/api/auth`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/register` | Step 1: Send OTP to email+phone | No |
| POST | `/verify-otp` | Step 2: Verify OTP code | No |
| POST | `/set-password` | Step 3: Create account with password | No |
| POST | `/login` | Login → get tokens | No |
| POST | `/refresh` | Refresh access token | No |

### Users `/api/users`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/me` | Get current user profile | Yes |
| PUT | `/me` | Update name | Yes |
| POST | `/upload-picture` | Upload profile picture | Yes |
| PUT | `/password` | Change password | Yes |
| DELETE | `/me` | Delete account | Yes |

### Packages `/api/packages`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/` | List all active packages | Yes |
| GET | `/{id}` | Get package by ID | Yes |

### Subscriptions `/api/subscriptions`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/` | Create subscription (returns payment info) | Yes |
| GET | `/active` | Get current active subscription | Yes |
| GET | `/history` | Get all subscriptions history | Yes |
| GET | `/{id}/usage` | Get usage stats | Yes |
| POST | `/{id}/upload-payment` | Upload payment proof → auto-activate | Yes |
| POST | `/{id}/add-data` | Add additional data package | Yes |

### Beneficiaries `/api/beneficiaries`

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/` | Add beneficiary to active subscription | Yes |
| GET | `/` | List all beneficiaries | Yes |
| PUT | `/{id}` | Update beneficiary name | Yes |
| DELETE | `/{id}` | Remove beneficiary | Yes |

---

## Auth Flow

```
POST /api/auth/register      { name, email, phone }
         ↓ OTP sent to email + SMS
POST /api/auth/verify-otp    { identifier: email, code: "123456" }
         ↓ OTP verified
POST /api/auth/set-password  { identifier: email, password, confirm_password }
         ↓ Account created
POST /api/auth/login         { email, password }
         ↓ Returns access_token + refresh_token
```

---

## Payment Flow

```
POST /api/subscriptions              { package_id }
         ↓ Returns payment info (Vodafone Cash / Instapay numbers)
         ↓ User transfers money manually
POST /api/subscriptions/{id}/upload-payment  (multipart: file + payment_method)
         ↓ Proof uploaded to Cloudinary
         ↓ Payment auto-verified (MVP)
         ↓ Subscription activated
```

**Manual Payment Numbers:**
- Vodafone Cash: `01234567890`
- Instapay: `internet.packages@instapay`

---

## Data Models

### User
```
_id, name, email (unique), phone (unique), password_hash,
profile_picture_url, role ("user"|"beneficiary"),
parent_subscription_id, is_verified, created_at, updated_at
```

### Package
```
_id, name, type ("daily"|"weekly"|"monthly"|"additional"),
data_amount_gb, price (EGP), validity_days,
description, features[], is_active
```

### Subscription
```
_id, user_id, package_id, start_date, end_date,
total_data_gb, used_data_gb, remaining_data_gb,
status ("pending"|"active"|"expired"|"cancelled"),
beneficiary_ids[], created_at
```

### Payment
```
_id, subscription_id, user_id, amount, payment_method,
payment_proof_url, paymob_transaction_id,
status ("pending"|"verified"|"completed"|"rejected"),
verified_at, created_at
```

### OTP
```
_id, identifier (email), code (6 digits), type, purpose,
expires_at (TTL 10 min), verified, temp_user_data, created_at
```

---

## Deployment on Railway

1. Push code to GitHub
2. Create new project on [Railway.app](https://railway.app)
3. Connect GitHub repo
4. Add environment variables from `.env.example`
5. Railway auto-detects `Procfile` and deploys

Health check endpoint: `GET /health`

---

## Development Notes

- **OTP in dev mode**: If `SMTP_USER` or `TWILIO_ACCOUNT_SID` not set, OTP codes are printed to the console
- **Image upload in dev mode**: If `CLOUDINARY_CLOUD_NAME` not set, upload is skipped (returns `null` URL)
- **Payment auto-verify**: In MVP, payment is verified immediately after uploading proof — no admin review
- **Usage simulation**: `UsageService.simulate_usage()` adds random 0.1–2.0 GB to simulate consumption
