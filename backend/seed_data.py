import asyncio
from app.database import init_db
from app.models.package import Package

PACKAGES = [
    # ── يومية (1 يوم) ──
    {"name": "يومية 10 جيجا",  "type": "daily", "data_amount_gb": 10,  "price": 30,   "validity_days": 1,  "description": "باقة يومية 10 جيجابايت",  "features": ["10 جيجابايت", "24 ساعة", "سرعة 30 ميجا"]},
    {"name": "يومية 20 جيجا",  "type": "daily", "data_amount_gb": 20,  "price": 60,   "validity_days": 1,  "description": "باقة يومية 20 جيجابايت",  "features": ["20 جيجابايت", "24 ساعة", "سرعة 30 ميجا"]},
    {"name": "يومية 30 جيجا",  "type": "daily", "data_amount_gb": 30,  "price": 90,   "validity_days": 1,  "description": "باقة يومية 30 جيجابايت",  "features": ["30 جيجابايت", "24 ساعة", "سرعة 30 ميجا"]},
    {"name": "يومية 40 جيجا",  "type": "daily", "data_amount_gb": 40,  "price": 120,  "validity_days": 1,  "description": "باقة يومية 40 جيجابايت",  "features": ["40 جيجابايت", "24 ساعة", "سرعة 30 ميجا"]},
    {"name": "يومية 50 جيجا",  "type": "daily", "data_amount_gb": 50,  "price": 150,  "validity_days": 1,  "description": "باقة يومية 50 جيجابايت",  "features": ["50 جيجابايت", "24 ساعة", "سرعة 30 ميجا"]},

    # ── أسبوعية (7 أيام) ──
    {"name": "أسبوعية 50 جيجا",   "type": "weekly", "data_amount_gb": 50,   "price": 145,  "validity_days": 7,  "description": "باقة أسبوعية 50 جيجابايت",   "features": ["50 جيجابايت", "7 أيام", "سرعة 30 ميجا"]},
    {"name": "أسبوعية 100 جيجا",  "type": "weekly", "data_amount_gb": 100,  "price": 290,  "validity_days": 7,  "description": "باقة أسبوعية 100 جيجابايت",  "features": ["100 جيجابايت", "7 أيام", "سرعة 30 ميجا"]},
    {"name": "أسبوعية 150 جيجا",  "type": "weekly", "data_amount_gb": 150,  "price": 435,  "validity_days": 7,  "description": "باقة أسبوعية 150 جيجابايت",  "features": ["150 جيجابايت", "7 أيام", "سرعة 30 ميجا"]},
    {"name": "أسبوعية 200 جيجا",  "type": "weekly", "data_amount_gb": 200,  "price": 580,  "validity_days": 7,  "description": "باقة أسبوعية 200 جيجابايت",  "features": ["200 جيجابايت", "7 أيام", "سرعة 30 ميجا"]},
    {"name": "أسبوعية 250 جيجا",  "type": "weekly", "data_amount_gb": 250,  "price": 725,  "validity_days": 7,  "description": "باقة أسبوعية 250 جيجابايت",  "features": ["250 جيجابايت", "7 أيام", "سرعة 30 ميجا"]},

    # ── شهرية (30 يوم) ──
    {"name": "شهرية 100 جيجا",  "type": "monthly", "data_amount_gb": 100,  "price": 270,   "validity_days": 30, "description": "باقة شهرية 100 جيجابايت",  "features": ["100 جيجابايت", "30 يوم", "سرعة 30 ميجا", "إمكانية إضافة باقات"]},
    {"name": "شهرية 200 جيجا",  "type": "monthly", "data_amount_gb": 200,  "price": 540,   "validity_days": 30, "description": "باقة شهرية 200 جيجابايت",  "features": ["200 جيجابايت", "30 يوم", "سرعة 30 ميجا", "إمكانية إضافة باقات"]},
    {"name": "شهرية 300 جيجا",  "type": "monthly", "data_amount_gb": 300,  "price": 810,   "validity_days": 30, "description": "باقة شهرية 300 جيجابايت",  "features": ["300 جيجابايت", "30 يوم", "سرعة 30 ميجا", "إمكانية إضافة باقات"]},
    {"name": "شهرية 400 جيجا",  "type": "monthly", "data_amount_gb": 400,  "price": 1080,  "validity_days": 30, "description": "باقة شهرية 400 جيجابايت",  "features": ["400 جيجابايت", "30 يوم", "سرعة 30 ميجا", "إمكانية إضافة باقات"]},
    {"name": "شهرية 500 جيجا",  "type": "monthly", "data_amount_gb": 500,  "price": 1350,  "validity_days": 30, "description": "باقة شهرية 500 جيجابايت",  "features": ["500 جيجابايت", "30 يوم", "سرعة 30 ميجا", "إمكانية إضافة باقات"]},

    # ── إضافية (للمشتركين الشهريين فقط — المدة = المتبقي من الشهر) ──
    {"name": "إضافية 100 جيجا",  "type": "additional", "data_amount_gb": 100,  "price": 300,  "validity_days": 0, "description": "100 جيجا إضافية على باقتك الشهرية",  "features": ["100 جيجابايت إضافية", "تُضاف فوراً", "للمشتركين الشهريين فقط"]},
    {"name": "إضافية 150 جيجا",  "type": "additional", "data_amount_gb": 150,  "price": 450,  "validity_days": 0, "description": "150 جيجا إضافية على باقتك الشهرية",  "features": ["150 جيجابايت إضافية", "تُضاف فوراً", "للمشتركين الشهريين فقط"]},
    {"name": "إضافية 200 جيجا",  "type": "additional", "data_amount_gb": 200,  "price": 580,  "validity_days": 0, "description": "200 جيجا إضافية على باقتك الشهرية",  "features": ["200 جيجابايت إضافية", "تُضاف فوراً", "للمشتركين الشهريين فقط"]},
    {"name": "إضافية 250 جيجا",  "type": "additional", "data_amount_gb": 250,  "price": 700,  "validity_days": 0, "description": "250 جيجا إضافية على باقتك الشهرية",  "features": ["250 جيجابايت إضافية", "تُضاف فوراً", "للمشتركين الشهريين فقط"]},
    {"name": "إضافية 300 جيجا",  "type": "additional", "data_amount_gb": 300,  "price": 840,  "validity_days": 0, "description": "300 جيجا إضافية على باقتك الشهرية",  "features": ["300 جيجابايت إضافية", "تُضاف فوراً", "للمشتركين الشهريين فقط"]},
]


async def seed():
    await init_db()
    count = await Package.find_all().count()
    if count:
        print(f"Packages already exist ({count}). Deleting old and re-seeding...")
        await Package.delete_all()

    for p in PACKAGES:
        await Package(**p, is_active=True).insert()
        print(f"  + {p['name']} ({p['data_amount_gb']}GB / {p['price']} EGP)")

    print(f"\nDone! {len(PACKAGES)} packages seeded.")


if __name__ == "__main__":
    asyncio.run(seed())
