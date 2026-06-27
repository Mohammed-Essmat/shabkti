import routeros_api
from app.config import settings
from typing import Optional

class MikroTikService:

    @staticmethod
    def _connect():
        if not settings.MIKROTIK_HOST or not settings.MIKROTIK_USER:
            print("[DEV] MikroTik not configured — skipping")
            return None
        try:
            connection = routeros_api.RouterOsApiPool(
                settings.MIKROTIK_HOST,
                username=settings.MIKROTIK_USER,
                password=settings.MIKROTIK_PASSWORD or '',
                port=settings.MIKROTIK_PORT,
                plaintext_login=True,
            )
            return connection.get_api()
        except Exception as e:
            print(f"MikroTik connection error: {e}")
            return None

    # ── Hotspot User Management ──

    @staticmethod
    def create_hotspot_user(
        username: str,
        password: str,
        data_limit_gb: float,
        validity_days: int = 0,
        profile: str = "shabkti",
        server: str = "hotspot1",
    ) -> bool:
        """Create a hotspot user when subscription is activated"""
        api = MikroTikService._connect()
        if not api:
            return False
        try:
            hotspot_user = api.get_resource('/ip/hotspot/user')
            params = {
                'name': username,
                'password': password,
                'profile': profile,
                'server': server,
            }
            # set data limit in bytes
            if data_limit_gb > 0:
                limit_bytes = int(data_limit_gb * 1024 * 1024 * 1024)
                params['limit-bytes-total'] = str(limit_bytes)
            # set time limit
            if validity_days > 0:
                params['limit-uptime'] = f"{validity_days}d 00:00:00"

            hotspot_user.add(**params)
            print(f"MikroTik: Created user '{username}' — {data_limit_gb}GB / {validity_days}d")
            return True
        except Exception as e:
            print(f"MikroTik create user error: {e}")
            return False

    @staticmethod
    def remove_hotspot_user(username: str) -> bool:
        """Remove a hotspot user when subscription expires or is cancelled"""
        api = MikroTikService._connect()
        if not api:
            return False
        try:
            hotspot_user = api.get_resource('/ip/hotspot/user')
            users = hotspot_user.get(name=username)
            for user in users:
                hotspot_user.remove(id=user['id'])
            print(f"MikroTik: Removed hotspot user '{username}'")
            return True
        except Exception as e:
            print(f"MikroTik remove user error: {e}")
            return False

    @staticmethod
    def disable_hotspot_user(username: str) -> bool:
        """Disable a hotspot user (keep but block)"""
        api = MikroTikService._connect()
        if not api:
            return False
        try:
            hotspot_user = api.get_resource('/ip/hotspot/user')
            users = hotspot_user.get(name=username)
            for user in users:
                hotspot_user.set(id=user['id'], disabled='yes')
            print(f"MikroTik: Disabled hotspot user '{username}'")
            return True
        except Exception as e:
            print(f"MikroTik disable user error: {e}")
            return False

    @staticmethod
    def enable_hotspot_user(username: str) -> bool:
        """Re-enable a hotspot user"""
        api = MikroTikService._connect()
        if not api:
            return False
        try:
            hotspot_user = api.get_resource('/ip/hotspot/user')
            users = hotspot_user.get(name=username)
            for user in users:
                hotspot_user.set(id=user['id'], disabled='no')
            return True
        except Exception as e:
            print(f"MikroTik enable user error: {e}")
            return False

    @staticmethod
    def update_user_profile(username: str, new_profile: str) -> bool:
        """Change user's profile (e.g. after adding data package)"""
        api = MikroTikService._connect()
        if not api:
            return False
        try:
            hotspot_user = api.get_resource('/ip/hotspot/user')
            users = hotspot_user.get(name=username)
            for user in users:
                hotspot_user.set(id=user['id'], profile=new_profile)
            return True
        except Exception as e:
            print(f"MikroTik update profile error: {e}")
            return False

    # ── Usage Tracking ──

    @staticmethod
    def get_user_usage(username: str) -> Optional[dict]:
        """Get real usage data from active hotspot session"""
        api = MikroTikService._connect()
        if not api:
            return None
        try:
            active = api.get_resource('/ip/hotspot/active')
            sessions = active.get(user=username)
            if not sessions:
                return None

            total_up = 0
            total_down = 0
            for session in sessions:
                total_up += int(session.get('bytes-out', 0))
                total_down += int(session.get('bytes-in', 0))

            total_bytes = total_up + total_down
            total_gb = total_bytes / (1024 ** 3)

            return {
                "bytes_up": total_up,
                "bytes_down": total_down,
                "total_bytes": total_bytes,
                "total_gb": round(total_gb, 3),
                "uptime": sessions[0].get('uptime', '0s') if sessions else '0s',
            }
        except Exception as e:
            print(f"MikroTik get usage error: {e}")
            return None

    # ── Profile Management ──

    @staticmethod
    def get_profiles() -> list:
        """List all hotspot profiles"""
        api = MikroTikService._connect()
        if not api:
            return []
        try:
            profiles = api.get_resource('/ip/hotspot/user/profile')
            return profiles.get()
        except Exception as e:
            print(f"MikroTik get profiles error: {e}")
            return []

    @staticmethod
    def get_active_users() -> list:
        """List all currently connected hotspot users"""
        api = MikroTikService._connect()
        if not api:
            return []
        try:
            active = api.get_resource('/ip/hotspot/active')
            return active.get()
        except Exception as e:
            print(f"MikroTik get active users error: {e}")
            return []

    # ── Connection Test ──

    @staticmethod
    def test_connection() -> dict:
        """Test if MikroTik is reachable"""
        api = MikroTikService._connect()
        if not api:
            return {"connected": False, "error": "Cannot connect"}
        try:
            identity = api.get_resource('/system/identity')
            name = identity.get()[0].get('name', 'unknown')
            return {"connected": True, "router_name": name}
        except Exception as e:
            return {"connected": False, "error": str(e)}
