import secrets
import string
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.models.otp import OTP
from app.config import settings

class OTPService:
    @staticmethod
    def generate_code(length: int = 6) -> str:
        return ''.join(secrets.choice(string.digits) for _ in range(length))

    @staticmethod
    async def create_and_send(identifier: str, otp_type: str, purpose: str = "register", temp_user_data: dict = None) -> OTP:
        old = await OTP.find(OTP.identifier == identifier, OTP.verified == False).to_list()
        for o in old:
            await o.delete()
        code = OTPService.generate_code()
        otp = OTP.create_new(identifier, code, otp_type, purpose, temp_user_data=temp_user_data)
        await otp.insert()
        if otp_type == "email":
            await OTPService.send_email(identifier, code)
        elif otp_type == "sms":
            await OTPService.send_sms(identifier, code)
        elif otp_type == "both":
            await OTPService.send_email(identifier, code)
            if temp_user_data and temp_user_data.get("phone"):
                await OTPService.send_sms(temp_user_data["phone"], code)
        return otp

    @staticmethod
    async def send_email(email: str, code: str):
        try:
            if settings.SMTP_USER and settings.SMTP_PASSWORD:
                msg = MIMEMultipart()
                msg['From'] = settings.SMTP_USER
                msg['To'] = email
                msg['Subject'] = f"{settings.APP_NAME} - كود التحقق"
                body = f"<h2>كود التحقق الخاص بك: <strong>{code}</strong></h2><p>صالح لمدة 10 دقائق</p>"
                msg.attach(MIMEText(body, 'html'))
                server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT)
                server.starttls()
                server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                server.send_message(msg)
                server.quit()
            else:
                print(f"📧 [DEV] Email OTP for {email}: {code}")
        except Exception as e:
            print(f"❌ Email error: {e}")

    @staticmethod
    async def send_sms(phone: str, code: str):
        try:
            if settings.TWILIO_ACCOUNT_SID:
                from twilio.rest import Client
                client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
                client.messages.create(
                    body=f"كود التحقق الخاص بك: {code}",
                    from_=settings.TWILIO_PHONE_NUMBER,
                    to=phone
                )
            else:
                print(f"📱 [DEV] SMS OTP for {phone}: {code}")
        except Exception as e:
            print(f"❌ SMS error: {e}")

    @staticmethod
    async def verify(identifier: str, code: str) -> bool:
        otp = await OTP.find_one(
            OTP.identifier == identifier,
            OTP.code == code,
            OTP.verified == False
        )
        if not otp or otp.is_expired():
            return False
        otp.verified = True
        await otp.save()
        return True
