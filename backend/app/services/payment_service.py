import httpx
from app.config import settings
from typing import Optional

VODAFONE_CASH_NUMBER = "01234567890"
INSTAPAY_ADDRESS = "internet.packages@instapay"

class PaymentService:
    @staticmethod
    async def get_manual_payment_info() -> dict:
        return {
            "vodafone_cash": VODAFONE_CASH_NUMBER,
            "instapay": INSTAPAY_ADDRESS,
            "instructions": "حوّل المبلغ على أحد الأرقام وارفع صورة إثبات الدفع"
        }

    @staticmethod
    async def create_paymob_payment(amount: float, subscription_id: str) -> Optional[str]:
        if not settings.PAYMOB_API_KEY:
            return None
        try:
            async with httpx.AsyncClient() as client:
                # Step 1: Authentication
                auth_res = await client.post(
                    "https://accept.paymob.com/api/auth/tokens",
                    json={"api_key": settings.PAYMOB_API_KEY}
                )
                auth_token = auth_res.json().get("token")

                # Step 2: Order Registration
                order_res = await client.post(
                    "https://accept.paymob.com/api/ecommerce/orders",
                    json={
                        "auth_token": auth_token,
                        "delivery_needed": False,
                        "amount_cents": int(amount * 100),
                        "currency": "EGP",
                        "merchant_order_id": subscription_id,
                        "items": []
                    }
                )
                order_id = order_res.json().get("id")

                # Step 3: Payment Key
                payment_key_res = await client.post(
                    "https://accept.paymob.com/api/acceptance/payment_keys",
                    json={
                        "auth_token": auth_token,
                        "amount_cents": int(amount * 100),
                        "expiration": 3600,
                        "order_id": order_id,
                        "currency": "EGP",
                        "integration_id": settings.PAYMOB_INTEGRATION_ID,
                        "billing_data": {
                            "first_name": "Customer",
                            "last_name": "User",
                            "email": "customer@example.com",
                            "phone_number": "01000000000",
                            "apartment": "NA", "floor": "NA", "street": "NA",
                            "building": "NA", "shipping_method": "NA",
                            "postal_code": "NA", "city": "NA",
                            "country": "EG", "state": "NA"
                        }
                    }
                )
                payment_token = payment_key_res.json().get("token")
                return f"https://accept.paymob.com/api/acceptance/iframes/{settings.PAYMOB_IFRAME_ID}?payment_token={payment_token}"
        except Exception as e:
            print(f"❌ Paymob error: {e}")
            return None
