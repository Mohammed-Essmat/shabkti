from datetime import datetime
from app.models.subscription import Subscription
from app.models.user import User
from app.services.mikrotik_service import MikroTikService


class UsageService:
    @staticmethod
    async def sync_usage_from_mikrotik(subscription: Subscription) -> bool:
        user = await User.get(subscription.user_id)
        if not user:
            return False

        usage = MikroTikService.get_user_usage(user.email)
        if not usage:
            return False

        subscription.used_data_gb = min(usage["total_gb"], subscription.total_data_gb)
        subscription.remaining_data_gb = max(subscription.total_data_gb - subscription.used_data_gb, 0)
        await subscription.save()

        if subscription.remaining_data_gb <= 0:
            subscription.status = "expired"
            await subscription.save()
            MikroTikService.remove_hotspot_user(user.email)

        return True

    @staticmethod
    async def get_stats(sub: Subscription) -> dict:
        await UsageService.sync_usage_from_mikrotik(sub)

        pct = (sub.used_data_gb / sub.total_data_gb * 100) if sub.total_data_gb else 0
        days = None
        if sub.end_date:
            days = max(0, (sub.end_date - datetime.utcnow()).days)
            if days <= 0 and sub.status == "active":
                sub.status = "expired"
                await sub.save()
                user = await User.get(sub.user_id)
                if user:
                    MikroTikService.remove_hotspot_user(user.email)

        return {
            "total_gb": sub.total_data_gb,
            "used_gb": round(sub.used_data_gb, 2),
            "remaining_gb": round(sub.remaining_data_gb, 2),
            "percentage_used": round(pct, 2),
            "days_remaining": days,
            "status": sub.status
        }
