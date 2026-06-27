import html
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import APIRouter, HTTPException, Depends, Form, Response
from fastapi.responses import HTMLResponse, RedirectResponse
from app.utils.dependencies import verify_admin, ADMIN_SESSION_TOKEN
from app.models.payment import Payment
from app.models.subscription import Subscription
from app.models.package import Package
from app.models.user import User
from app.services.mikrotik_service import MikroTikService
from app.config import settings
from datetime import datetime, timedelta

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/login", response_class=HTMLResponse)
async def admin_login_page():
    return """
    <!DOCTYPE html>
    <html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Shabkti Admin — Login</title>
        <style>
            * { margin:0; padding:0; box-sizing:border-box; }
            body { font-family:'Segoe UI',sans-serif; background:#f0f2f5; display:flex; justify-content:center; align-items:center; min-height:100vh; }
            .card { background:white; border-radius:16px; padding:40px; width:380px; box-shadow:0 4px 24px rgba(0,0,0,0.08); }
            h1 { color:#004AC6; font-size:22px; text-align:center; margin-bottom:8px; }
            p { color:#666; font-size:13px; text-align:center; margin-bottom:24px; }
            label { display:block; font-size:13px; color:#333; margin-bottom:6px; font-weight:600; }
            input { width:100%; padding:12px 16px; border:1px solid #ddd; border-radius:10px; font-size:14px; margin-bottom:16px; }
            input:focus { outline:none; border-color:#004AC6; }
            button { width:100%; padding:14px; background:#004AC6; color:white; border:none; border-radius:10px; font-size:15px; font-weight:600; cursor:pointer; }
            button:hover { background:#003AA0; }
            .error { background:#FEE2E2; color:#DC2626; padding:10px; border-radius:8px; font-size:13px; margin-bottom:16px; text-align:center; }
        </style>
    </head><body>
        <div class="card">
            <h1>Shabkti Admin</h1>
            <p>Sign in to manage payments and users</p>
            <form method="POST" action="/admin/login">
                <label>Username</label>
                <input type="text" name="username" required autofocus>
                <label>Password</label>
                <input type="password" name="password" required>
                <button type="submit">Sign In</button>
            </form>
        </div>
    </body></html>
    """


@router.post("/login")
async def admin_login(username: str = Form(...), password: str = Form(...)):
    if username != settings.ADMIN_USERNAME or password != settings.ADMIN_PASSWORD:
        return HTMLResponse("""
        <!DOCTYPE html>
        <html lang="en"><head>
            <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Shabkti Admin — Login</title>
            <style>
                * { margin:0; padding:0; box-sizing:border-box; }
                body { font-family:'Segoe UI',sans-serif; background:#f0f2f5; display:flex; justify-content:center; align-items:center; min-height:100vh; }
                .card { background:white; border-radius:16px; padding:40px; width:380px; box-shadow:0 4px 24px rgba(0,0,0,0.08); }
                h1 { color:#004AC6; font-size:22px; text-align:center; margin-bottom:8px; }
                p { color:#666; font-size:13px; text-align:center; margin-bottom:24px; }
                label { display:block; font-size:13px; color:#333; margin-bottom:6px; font-weight:600; }
                input { width:100%; padding:12px 16px; border:1px solid #ddd; border-radius:10px; font-size:14px; margin-bottom:16px; }
                input:focus { outline:none; border-color:#004AC6; }
                button { width:100%; padding:14px; background:#004AC6; color:white; border:none; border-radius:10px; font-size:15px; font-weight:600; cursor:pointer; }
                .error { background:#FEE2E2; color:#DC2626; padding:10px; border-radius:8px; font-size:13px; margin-bottom:16px; text-align:center; }
            </style>
        </head><body>
            <div class="card">
                <h1>Shabkti Admin</h1>
                <p>Sign in to manage payments and users</p>
                <div class="error">Invalid username or password</div>
                <form method="POST" action="/admin/login">
                    <label>Username</label>
                    <input type="text" name="username" required autofocus>
                    <label>Password</label>
                    <input type="password" name="password" required>
                    <button type="submit">Sign In</button>
                </form>
            </div>
        </body></html>
        """, status_code=401)

    response = RedirectResponse(url="/admin", status_code=303)
    response.set_cookie(key="admin_session", value=ADMIN_SESSION_TOKEN, httponly=True, max_age=86400)
    return response


@router.get("/logout")
async def admin_logout():
    response = RedirectResponse(url="/admin/login", status_code=303)
    response.delete_cookie("admin_session")
    return response


def _send_credentials_email(to_email: str, user_name: str, package_name: str, hotspot_username: str, hotspot_password: str):
    try:
        if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
            print(f"[DEV] Credentials for {to_email}: user={hotspot_username} pass={hotspot_password}")
            return

        msg = MIMEMultipart()
        msg['From'] = settings.SMTP_USER
        msg['To'] = to_email
        msg['Subject'] = f"Shabkti - تم تفعيل باقتك!"

        body = f"""
        <div style="font-family:Arial,sans-serif;max-width:500px;margin:0 auto;direction:rtl;text-align:right;">
            <div style="background:linear-gradient(135deg,#004AC6,#2563EB);padding:24px;border-radius:16px 16px 0 0;">
                <h1 style="color:white;margin:0;font-size:22px;">شبكتي — Shabkti</h1>
            </div>
            <div style="background:white;padding:24px;border:1px solid #e5e7eb;border-radius:0 0 16px 16px;">
                <h2 style="color:#004AC6;margin-top:0;">مرحباً {user_name}!</h2>
                <p>تم تفعيل باقتك <strong>{package_name}</strong> بنجاح.</p>
                <p>استخدم البيانات التالية للاتصال بالإنترنت:</p>
                <div style="background:#f0f4ff;padding:16px;border-radius:12px;margin:16px 0;">
                    <p style="margin:4px 0;"><strong>اسم المستخدم:</strong> {hotspot_username}</p>
                    <p style="margin:4px 0;"><strong>كلمة السر:</strong> {hotspot_password}</p>
                </div>
                <p style="color:#666;font-size:13px;">اتصل بشبكة WiFi الخاصة بـ Shabkti ← ستظهر صفحة تسجيل الدخول ← أدخل البيانات أعلاه.</p>
            </div>
        </div>
        """
        msg.attach(MIMEText(body, 'html'))

        server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT)
        server.starttls()
        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
        server.send_message(msg)
        server.quit()
        print(f"Credentials email sent to {to_email}")
    except Exception as e:
        print(f"Email error: {e}")


@router.get("", response_class=HTMLResponse)
async def admin_dashboard(_=Depends(verify_admin)):
    payments = await Payment.find(Payment.status == "pending").sort("-created_at").to_list()
    verified = await Payment.find(Payment.status == "completed").sort("-created_at").to_list()

    pending_html = ""
    for p in payments:
        user_obj = await User.get(p.user_id)
        sub = await Subscription.get(p.subscription_id)
        pkg = await Package.get(sub.package_id) if sub else None

        user_name = html.escape(user_obj.name) if user_obj else "Unknown"
        user_email = html.escape(user_obj.email) if user_obj else "Unknown"
        pkg_name = html.escape(pkg.name) if pkg else "Unknown"
        pkg_data = f"{pkg.data_amount_gb}GB" if pkg else ""
        proof_img = f'<a href="{p.payment_proof_url}" target="_blank"><img src="{p.payment_proof_url}" style="max-width:200px;border-radius:8px;"></a>' if p.payment_proof_url else '<span style="color:#999">No proof uploaded</span>'

        pending_html += f"""
        <div class="card pending">
            <div class="card-header">
                <div>
                    <strong>{user_name}</strong><br>
                    <small>{user_email}</small>
                </div>
                <span class="badge pending-badge">Pending</span>
            </div>
            <div class="card-body">
                <div class="info-row"><span>Package:</span> <strong>{pkg_name} ({pkg_data})</strong></div>
                <div class="info-row"><span>Amount:</span> <strong>{p.amount} EGP</strong></div>
                <div class="info-row"><span>Method:</span> {p.payment_method}</div>
                <div class="info-row"><span>Date:</span> {p.created_at.strftime('%Y-%m-%d %H:%M')}</div>
                <div class="proof">{proof_img}</div>
            </div>
            <div class="card-actions">
                <button class="btn approve" onclick="action('{str(p.id)}', 'approve')">Approve</button>
                <button class="btn reject" onclick="action('{str(p.id)}', 'reject')">Reject</button>
            </div>
        </div>
        """

    recent_html = ""
    for p in verified[:10]:
        user_obj = await User.get(p.user_id)
        recent_html += f"""
        <div class="card done">
            <div class="card-header">
                <span>{user_obj.name if user_obj else 'Unknown'} — {p.amount} EGP</span>
                <span class="badge done-badge">{p.status}</span>
            </div>
            <small>{p.verified_at.strftime('%Y-%m-%d %H:%M') if p.verified_at else ''}</small>
        </div>
        """

    pending_count = len(payments)
    completed_count = len(verified)

    return f"""
    <!DOCTYPE html>
    <html lang="en" dir="ltr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Shabkti Admin</title>
        <style>
            * {{ margin:0; padding:0; box-sizing:border-box; }}
            body {{ font-family: 'Segoe UI', sans-serif; background:#f0f2f5; color:#1a1a2e; }}
            .header {{ background:linear-gradient(135deg,#004AC6,#2563EB); color:white; padding:20px 32px; }}
            .header h1 {{ font-size:24px; }}
            .header p {{ opacity:0.8; font-size:14px; margin-top:4px; }}
            .container {{ max-width:900px; margin:0 auto; padding:20px; }}
            .stats {{ display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:24px; }}
            .stat {{ background:white; padding:16px; border-radius:12px; text-align:center; }}
            .stat .num {{ font-size:28px; font-weight:700; color:#004AC6; }}
            .stat .label {{ font-size:13px; color:#666; margin-top:4px; }}
            h2 {{ margin:20px 0 12px; font-size:18px; }}
            .card {{ background:white; border-radius:12px; margin-bottom:12px; overflow:hidden; }}
            .card-header {{ display:flex; justify-content:space-between; align-items:center; padding:14px 16px; }}
            .card-body {{ padding:0 16px 14px; }}
            .card-actions {{ display:flex; gap:8px; padding:0 16px 14px; }}
            .info-row {{ display:flex; justify-content:space-between; padding:4px 0; font-size:14px; }}
            .info-row span {{ color:#666; }}
            .proof {{ margin-top:10px; }}
            .badge {{ padding:4px 10px; border-radius:20px; font-size:12px; font-weight:600; }}
            .pending-badge {{ background:#FEF3C7; color:#D97706; }}
            .done-badge {{ background:#DCFCE7; color:#16A34A; }}
            .reject-badge {{ background:#FEE2E2; color:#DC2626; }}
            .btn {{ padding:10px 20px; border:none; border-radius:8px; cursor:pointer; font-weight:600; font-size:14px; }}
            .btn.approve {{ background:#22C55E; color:white; }}
            .btn.approve:hover {{ background:#16A34A; }}
            .btn.reject {{ background:#EF4444; color:white; }}
            .btn.reject:hover {{ background:#DC2626; }}
            .empty {{ text-align:center; padding:40px; color:#999; }}
            .nav {{ margin-top:12px; display:flex; gap:16px; align-items:center; }}
            .nav a {{ color:white; text-decoration:none; padding:6px 16px; border-radius:8px; background:rgba(255,255,255,0.15); font-size:14px; }}
            .nav a:hover {{ background:rgba(255,255,255,0.25); }}
            .header-top {{ display:flex; align-items:center; gap:14px; }}
            .header-top img {{ width:40px; height:40px; border-radius:10px; background:rgba(255,255,255,0.15); padding:4px; }}
            table {{ width:100%; border-collapse:collapse; background:white; border-radius:12px; overflow:hidden; }}
            th {{ background:#f8f9ff; padding:12px 16px; text-align:left; font-size:13px; color:#666; }}
            td {{ padding:12px 16px; border-top:1px solid #f0f0f0; font-size:14px; }}
            tr:hover td {{ background:#f8faff; }}
        </style>
    </head>
    <body>
        <div class="header">
            <div class="header-top"><img src="/uploads/static/logo.png" alt="Logo"><h1>Shabkti Admin</h1></div>
            <p>Payment Management & MikroTik Control</p>
            <div class="nav"><a href="/admin">Payments</a> <a href="/admin/users">Users</a> <a href="/admin/logout" style="margin-left:auto;background:rgba(255,255,255,0.25);">Logout</a></div>
        </div>
        <div class="container">
            <div class="stats">
                <div class="stat">
                    <div class="num">{pending_count}</div>
                    <div class="label">Pending Payments</div>
                </div>
                <div class="stat">
                    <div class="num">{completed_count}</div>
                    <div class="label">Completed Payments</div>
                </div>
                <div class="stat">
                    <div class="num" id="mk-status">...</div>
                    <div class="label">MikroTik Router</div>
                </div>
            </div>

            <h2>Pending Payments</h2>
            {pending_html if pending_html else '<div class="card"><div class="empty">No pending payments</div></div>'}

            <h2>Recent Verified</h2>
            {recent_html if recent_html else '<div class="card"><div class="empty">No recent payments</div></div>'}
        </div>

        <script>
            async function action(paymentId, type) {{
                if (!confirm(type === 'approve' ? 'Approve this payment?' : 'Reject this payment?')) return;
                const res = await fetch('/admin/payments/' + paymentId + '/' + type, {{ method: 'POST', credentials: 'same-origin' }});
                const data = await res.json();
                alert(data.message || data.error);
                location.reload();
            }}
            // Check MikroTik status async
            fetch('/mikrotik/test').then(r => r.json()).then(d => {{
                document.getElementById('mk-status').innerHTML = d.connected
                    ? '<span class="badge done-badge">Connected</span>'
                    : '<span class="badge pending-badge">Offline</span>';
            }}).catch(() => {{
                document.getElementById('mk-status').innerHTML = '<span class="badge pending-badge">Error</span>';
            }});
        </script>
    </body>
    </html>
    """


@router.post("/payments/{payment_id}/approve")
async def approve_payment(payment_id: str, _=Depends(verify_admin)):
    payment = await Payment.get(payment_id)
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    if payment.status != "pending":
        raise HTTPException(status_code=400, detail="Payment is not pending")

    sub = await Subscription.get(payment.subscription_id)
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")

    package = await Package.get(sub.package_id)
    user = await User.get(payment.user_id)

    # Update payment
    payment.status = "completed"
    payment.verified_at = datetime.utcnow()
    await payment.save()

    # Generate hotspot credentials
    hotspot_username = user.email if user else ""
    hotspot_password = str(user.id)[-8:] if user else ""

    # Activate subscription + save credentials
    now = datetime.utcnow()
    sub.status = "active"
    sub.start_date = now
    sub.hotspot_username = hotspot_username
    sub.hotspot_password = hotspot_password
    if package and package.validity_days > 0:
        sub.end_date = now + timedelta(days=package.validity_days)
    await sub.save()

    # Create MikroTik hotspot user (remove old one first if exists)
    mk_success = False
    if user and package:
        MikroTikService.remove_hotspot_user(hotspot_username)
        mk_success = MikroTikService.create_hotspot_user(
            username=hotspot_username,
            password=hotspot_password,
            data_limit_gb=package.data_amount_gb,
            validity_days=package.validity_days,
        )

    # Send credentials email
    if user and package:
        _send_credentials_email(
            to_email=user.email,
            user_name=user.name,
            package_name=package.name,
            hotspot_username=hotspot_username,
            hotspot_password=hotspot_password,
        )

    mk_msg = "MikroTik user created." if mk_success else "WARNING: MikroTik user NOT created - check router connection."
    return {
        "message": f"Payment approved. {mk_msg}",
        "hotspot_username": hotspot_username,
        "hotspot_password": hotspot_password,
    }


@router.post("/payments/{payment_id}/reject")
async def reject_payment(payment_id: str, _=Depends(verify_admin)):
    payment = await Payment.get(payment_id)
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    payment.status = "rejected"
    await payment.save()

    sub = await Subscription.get(payment.subscription_id)
    if sub:
        sub.status = "cancelled"
        await sub.save()

    return {"message": "Payment rejected and subscription cancelled."}


@router.get("/users", response_class=HTMLResponse)
async def admin_users(_=Depends(verify_admin)):
    users = await User.find_all().sort("-created_at").to_list()
    subs = await Subscription.find_all().to_list()

    sub_map = {}
    for s in subs:
        if s.user_id not in sub_map or s.status == "active":
            sub_map[s.user_id] = s

    rows = ""
    for u in users:
        user_sub = sub_map.get(str(u.id))
        sub_status = user_sub.status if user_sub else "none"
        sub_pkg = ""
        if user_sub:
            pkg = await Package.get(user_sub.package_id)
            sub_pkg = pkg.name if pkg else ""

        status_class = "done-badge" if sub_status == "active" else "pending-badge" if sub_status == "pending" else ""
        status_label = {"active": "Active", "pending": "Pending", "expired": "Expired", "cancelled": "Cancelled", "none": "No sub"}.get(sub_status, sub_status)

        rows += f"""
        <tr>
            <td><strong>{html.escape(u.name)}</strong></td>
            <td>{html.escape(u.email)}</td>
            <td>{html.escape(u.phone)}</td>
            <td><span class="badge {status_class}">{status_label}</span></td>
            <td>{sub_pkg}</td>
            <td>{u.role}</td>
            <td>{u.created_at.strftime('%Y-%m-%d')}</td>
        </tr>
        """

    return f"""
    <!DOCTYPE html>
    <html lang="en" dir="ltr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Shabkti Admin — Users</title>
        <style>
            * {{ margin:0; padding:0; box-sizing:border-box; }}
            body {{ font-family: 'Segoe UI', sans-serif; background:#f0f2f5; color:#1a1a2e; }}
            .header {{ background:linear-gradient(135deg,#004AC6,#2563EB); color:white; padding:20px 32px; }}
            .header h1 {{ font-size:24px; }}
            .header p {{ opacity:0.8; font-size:14px; margin-top:4px; }}
            .nav {{ margin-top:12px; display:flex; gap:16px; align-items:center; }}
            .nav a {{ color:white; text-decoration:none; padding:6px 16px; border-radius:8px; background:rgba(255,255,255,0.15); font-size:14px; }}
            .nav a:hover {{ background:rgba(255,255,255,0.25); }}
            .header-top {{ display:flex; align-items:center; gap:14px; }}
            .header-top img {{ width:40px; height:40px; border-radius:10px; background:rgba(255,255,255,0.15); padding:4px; }}
            .container {{ max-width:1100px; margin:0 auto; padding:20px; }}
            .stats {{ display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:24px; }}
            .stat {{ background:white; padding:16px; border-radius:12px; text-align:center; }}
            .stat .num {{ font-size:28px; font-weight:700; color:#004AC6; }}
            .stat .label {{ font-size:13px; color:#666; margin-top:4px; }}
            table {{ width:100%; border-collapse:collapse; background:white; border-radius:12px; overflow:hidden; }}
            th {{ background:#f8f9ff; padding:12px 16px; text-align:left; font-size:13px; color:#666; }}
            td {{ padding:12px 16px; border-top:1px solid #f0f0f0; font-size:14px; }}
            tr:hover td {{ background:#f8faff; }}
            .badge {{ padding:4px 10px; border-radius:20px; font-size:12px; font-weight:600; }}
            .done-badge {{ background:#DCFCE7; color:#16A34A; }}
            .pending-badge {{ background:#FEF3C7; color:#D97706; }}
        </style>
    </head>
    <body>
        <div class="header">
            <div class="header-top"><img src="/uploads/static/logo.png" alt="Logo"><h1>Shabkti Admin</h1></div>
            <p>User Management</p>
            <div class="nav"><a href="/admin">Payments</a> <a href="/admin/users">Users</a> <a href="/admin/logout" style="margin-left:auto;background:rgba(255,255,255,0.25);">Logout</a></div>
        </div>
        <div class="container">
            <div class="stats">
                <div class="stat">
                    <div class="num">{len([u for u in users if u.role == 'user'])}</div>
                    <div class="label">Users</div>
                </div>
                <div class="stat">
                    <div class="num">{len([u for u in users if u.role == 'beneficiary'])}</div>
                    <div class="label">Beneficiaries</div>
                </div>
                <div class="stat">
                    <div class="num">{len([s for s in subs if s.status == 'active'])}</div>
                    <div class="label">Active Subscriptions</div>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Subscription</th>
                        <th>Package</th>
                        <th>Role</th>
                        <th>Joined</th>
                    </tr>
                </thead>
                <tbody>
                    {rows if rows else '<tr><td colspan="7" style="text-align:center;padding:40px;color:#999;">No users yet</td></tr>'}
                </tbody>
            </table>
        </div>
    </body>
    </html>
    """
