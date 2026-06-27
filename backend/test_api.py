import httpx
import sys

BASE = "http://localhost:8000"
client = httpx.Client(base_url=BASE)
token = None
headers = {}

def ok(label, res, expected=200):
    status = "PASS" if res.status_code == expected else "FAIL"
    print(f"  [{status}] {label}: {res.status_code} - {res.text[:120]}")
    return res.status_code == expected

print("=" * 50)
print("INTERNET PACKAGES API - FULL TEST")
print("=" * 50)

# ── 1. HEALTH ──────────────────────────────────────
print("\n[1] Health Check")
ok("GET /health", client.get("/health"))

# ── 2. REGISTER ────────────────────────────────────
print("\n[2] Registration Flow")
r = client.post("/api/auth/register", json={
    "name": "Test User", "email": "testuser@test.com", "phone": "+201099999999"
})
ok("POST /register", r)

# Get OTP from server logs — using a second register to capture
import re
otp_code = None

# Re-register to get a fresh OTP visible in response errors
r2 = client.post("/api/auth/register", json={
    "name": "Test User2", "email": "testuser2@test.com", "phone": "+201088888888"
})
ok("POST /register (user2)", r2)

# We'll use the debug endpoint approach — verify with wrong code first
r_wrong = client.post("/api/auth/verify-otp", json={"identifier": "testuser@test.com", "code": "000000"})
ok("POST /verify-otp (wrong code → fail)", r_wrong, 400)

# ── Since we can't read the OTP from server stdout here,
#    we'll create OTP directly via the DB for testing
print("\n[INFO] Fetching OTP from DB for test...")
import asyncio
import os
os.environ.setdefault("MONGODB_URL", "mongodb://localhost:27017/internet_packages")
os.environ.setdefault("SECRET_KEY", "455c915c4f365ee0a555092eaed5d42d0e6cd284b4720ace4498a523a966e150")

async def get_otp_code(email):
    from app.database import init_db
    from app.models.otp import OTP
    await init_db()
    otp = await OTP.find_one(OTP.identifier == email, OTP.verified == False)
    return otp.code if otp else None

otp_code = asyncio.run(get_otp_code("testuser@test.com"))
print(f"  [INFO] OTP for testuser@test.com: {otp_code}")

if otp_code:
    r = client.post("/api/auth/verify-otp", json={"identifier": "testuser@test.com", "code": otp_code})
    ok("POST /verify-otp (correct code)", r)

    r = client.post("/api/auth/set-password", json={
        "identifier": "testuser@test.com",
        "password": "Test1234", "confirm_password": "Test1234"
    })
    ok("POST /set-password", r, 201)
else:
    print("  [SKIP] Could not fetch OTP from DB")

# ── 3. LOGIN ───────────────────────────────────────
print("\n[3] Login")
r = client.post("/api/auth/login", json={"email": "testuser@test.com", "password": "Test1234"})
if ok("POST /login", r):
    data = r.json()
    token = data["access_token"]
    refresh = data["refresh_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print(f"  [INFO] Token: {token[:30]}...")

# Test refresh token
r = client.post("/api/auth/refresh", json={"refresh_token": refresh})
ok("POST /refresh", r)

# ── 4. PROFILE ─────────────────────────────────────
print("\n[4] User Profile")
r = client.get("/api/users/me", headers=headers)
ok("GET /users/me", r)
if r.status_code == 200:
    u = r.json()
    print(f"  [INFO] User: {u['name']} | {u['email']} | role={u['role']}")

r = client.put("/api/users/me", json={"name": "Updated Name"}, headers=headers)
ok("PUT /users/me (update name)", r)

r = client.put("/api/users/password", json={
    "current_password": "Test1234", "new_password": "NewPass456", "confirm_password": "NewPass456"
}, headers=headers)
ok("PUT /users/password", r)

# Re-login with new password
r = client.post("/api/auth/login", json={"email": "testuser@test.com", "password": "NewPass456"})
ok("POST /login (new password)", r)
if r.status_code == 200:
    token = r.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

# ── 5. PACKAGES ────────────────────────────────────
print("\n[5] Packages")
r = client.get("/api/packages", headers=headers)
ok("GET /packages", r)
packages = []
if r.status_code == 200:
    packages = r.json()
    for p in packages:
        print(f"  [INFO] {p['type']:12} | {p['name']} | {p['price']} EGP | {p['data_amount_gb']}GB")
    r2 = client.get(f"/api/packages/{packages[0]['id']}", headers=headers)
    ok(f"GET /packages/{packages[0]['id'][:8]}...", r2)

# ── 6. SUBSCRIPTION ────────────────────────────────
print("\n[6] Subscriptions")
weekly = next((p for p in packages if p["type"] == "weekly"), packages[0] if packages else None)
sub_id = None

if weekly:
    r = client.post("/api/subscriptions", json={"package_id": weekly["id"]}, headers=headers)
    ok("POST /subscriptions (create)", r, 201)
    if r.status_code == 201:
        pay_info = r.json()
        sub_id = pay_info["subscription_id"]
        print(f"  [INFO] Sub ID: {sub_id}")
        print(f"  [INFO] Pay to Vodafone Cash: {pay_info['vodafone_cash_number']}")
        print(f"  [INFO] Pay to Instapay: {pay_info['instapay_address']}")

# Upload payment proof (1x1 white JPEG)
if sub_id:
    fake_img = bytes([
        0xFF,0xD8,0xFF,0xE0,0x00,0x10,0x4A,0x46,0x49,0x46,0x00,0x01,
        0x01,0x00,0x00,0x01,0x00,0x01,0x00,0x00,0xFF,0xDB,0x00,0x43,
        0x00,0x08,0x06,0x06,0x07,0x06,0x05,0x08,0x07,0x07,0x07,0x09,
        0x09,0x08,0x0A,0x0C,0x14,0x0D,0x0C,0x0B,0x0B,0x0C,0x19,0x12,
        0x13,0x0F,0x14,0x1D,0x1A,0x1F,0x1E,0x1D,0x1A,0x1C,0x1C,0x20,
        0x24,0x2E,0x27,0x20,0x22,0x2C,0x23,0x1C,0x1C,0x28,0x37,0x29,
        0x2C,0x30,0x31,0x34,0x34,0x34,0x1F,0x27,0x39,0x3D,0x38,0x32,
        0x3C,0x2E,0x33,0x34,0x32,0xFF,0xC0,0x00,0x0B,0x08,0x00,0x01,
        0x00,0x01,0x01,0x01,0x11,0x00,0xFF,0xC4,0x00,0x1F,0x00,0x00,
        0x01,0x05,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,
        0x09,0x0A,0x0B,0xFF,0xC4,0x00,0xB5,0x10,0x00,0x02,0x01,0x03,
        0x03,0x02,0x04,0x03,0x05,0x05,0x04,0x04,0x00,0x00,0x01,0x7D,
        0xFF,0xDA,0x00,0x08,0x01,0x01,0x00,0x00,0x3F,0x00,0xFB,0xD7,
        0xFF,0xD9
    ])
    r = client.post(
        f"/api/subscriptions/{sub_id}/upload-payment?payment_method=vodafone_cash",
        headers=headers,
        files={"file": ("proof.jpg", fake_img, "image/jpeg")}
    )
    ok("POST /upload-payment (activate)", r)
    if r.status_code == 200:
        print(f"  [INFO] {r.json()['message']}")

# Get active subscription
r = client.get("/api/subscriptions/active", headers=headers)
ok("GET /subscriptions/active", r)
if r.status_code == 200:
    s = r.json()
    print(f"  [INFO] status={s['status']} | {s['total_data_gb']}GB | ends={s.get('end_date','N/A')[:10] if s.get('end_date') else 'N/A'}")

# Get usage
if sub_id:
    r = client.get(f"/api/subscriptions/{sub_id}/usage", headers=headers)
    ok("GET /subscriptions/{id}/usage", r)
    if r.status_code == 200:
        u = r.json()
        print(f"  [INFO] total={u['total_gb']}GB | used={u['used_gb']}GB | remaining={u['remaining_gb']}GB | {u['percentage_used']}%")

# History
r = client.get("/api/subscriptions/history", headers=headers)
ok("GET /subscriptions/history", r)
if r.status_code == 200:
    print(f"  [INFO] {len(r.json())} subscription(s) in history")

# ── 7. BENEFICIARIES ───────────────────────────────
print("\n[7] Beneficiaries")
ben_id = None
r = client.post("/api/beneficiaries", json={
    "name": "Sara Ben", "email": "sara.ben@test.com",
    "phone": "+201022222222", "password": "Sara1234"
}, headers=headers)
ok("POST /beneficiaries (add)", r, 201)
if r.status_code == 201:
    ben_id = r.json()["id"]
    print(f"  [INFO] Beneficiary ID: {ben_id}")

r = client.get("/api/beneficiaries", headers=headers)
ok("GET /beneficiaries (list)", r)
if r.status_code == 200:
    print(f"  [INFO] {len(r.json())} beneficiary/ies")

if ben_id:
    r = client.put(f"/api/beneficiaries/{ben_id}", json={"name": "Sara Updated"}, headers=headers)
    ok("PUT /beneficiaries/{id} (update)", r)

# Beneficiary login
r = client.post("/api/auth/login", json={"email": "sara.ben@test.com", "password": "Sara1234"})
ok("POST /login (beneficiary)", r)

if ben_id:
    r = client.delete(f"/api/beneficiaries/{ben_id}", headers=headers)
    ok("DELETE /beneficiaries/{id}", r)

# ── SUMMARY ────────────────────────────────────────
print("\n" + "=" * 50)
print("TEST COMPLETE")
print("=" * 50)
print(f"\nSwagger UI: {BASE}/docs")
print(f"ReDoc:       {BASE}/redoc")
