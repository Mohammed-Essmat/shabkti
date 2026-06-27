from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from app.schemas.subscription import (
    CreateSubscriptionRequest, SubscriptionResponse,
    UsageStatsResponse, PaymentInfoResponse
)
from app.models.subscription import Subscription
from app.models.package import Package
from app.models.payment import Payment
from app.models.user import User
from app.utils.dependencies import get_current_verified_user
from app.services.mikrotik_service import MikroTikService
from app.services.storage_service import StorageService
from app.services.usage_service import UsageService
from datetime import datetime, timedelta
from typing import List

router = APIRouter(prefix="/api/subscriptions", tags=["Subscriptions"])


def _sub_response(sub: Subscription, package_name: str = None) -> SubscriptionResponse:
    return SubscriptionResponse(
        id=str(sub.id),
        user_id=sub.user_id,
        package_id=sub.package_id,
        package_name=package_name,
        start_date=sub.start_date,
        end_date=sub.end_date,
        total_data_gb=sub.total_data_gb,
        used_data_gb=sub.used_data_gb,
        remaining_data_gb=sub.remaining_data_gb,
        status=sub.status,
        hotspot_username=sub.hotspot_username,
        hotspot_password=sub.hotspot_password,
        beneficiary_ids=sub.beneficiary_ids,
        created_at=sub.created_at
    )


@router.post("", response_model=PaymentInfoResponse, status_code=201)
async def create_subscription(
    body: CreateSubscriptionRequest,
    current_user: User = Depends(get_current_verified_user)
):
    package = await Package.get(body.package_id)
    if not package or not package.is_active:
        raise HTTPException(status_code=404, detail="Package not found")

    active = await Subscription.find_one(
        Subscription.user_id == str(current_user.id),
        Subscription.status == "active"
    )
    if active and package.type != "additional":
        if not body.replace_existing:
            raise HTTPException(status_code=409, detail="You already have an active subscription. Set replace_existing=true to cancel it.")
        active.status = "cancelled"
        await active.save()
        MikroTikService.remove_hotspot_user(current_user.email)

    # additional packages only for monthly subscribers
    if package.type == "additional":
        if not active:
            raise HTTPException(status_code=400, detail="Additional packages require an active subscription")
        active_pkg = await Package.get(active.package_id)
        if not active_pkg or active_pkg.type != "monthly":
            raise HTTPException(status_code=400, detail="Additional packages are only available for monthly subscribers")

    sub = Subscription(
        user_id=str(current_user.id),
        package_id=str(package.id),
        total_data_gb=package.data_amount_gb,
        remaining_data_gb=package.data_amount_gb,
        status="pending"
    )
    await sub.insert()

    payment = Payment(
        subscription_id=str(sub.id),
        user_id=str(current_user.id),
        amount=package.price,
        status="pending"
    )
    await payment.insert()

    return PaymentInfoResponse(
        payment_id=str(payment.id),
        subscription_id=str(sub.id),
        amount=package.price,
        status="pending"
    )


@router.get("/active", response_model=SubscriptionResponse)
async def get_active_subscription(current_user: User = Depends(get_current_verified_user)):
    sub = await Subscription.find_one(
        Subscription.user_id == str(current_user.id),
        Subscription.status == "active"
    )
    if not sub:
        raise HTTPException(status_code=404, detail="No active subscription")
    package = await Package.get(sub.package_id)
    return _sub_response(sub, package.name if package else None)


@router.get("/history", response_model=List[SubscriptionResponse])
async def get_subscription_history(current_user: User = Depends(get_current_verified_user)):
    subs = await Subscription.find(
        Subscription.user_id == str(current_user.id)
    ).sort("-created_at").limit(50).to_list()

    pkg_ids = list({sub.package_id for sub in subs})
    packages = await Package.find({"_id": {"$in": pkg_ids}}).to_list() if pkg_ids else []
    pkg_map = {str(p.id): p.name for p in packages}

    return [_sub_response(sub, pkg_map.get(sub.package_id)) for sub in subs]


@router.get("/{subscription_id}/usage", response_model=UsageStatsResponse)
async def get_usage(
    subscription_id: str,
    current_user: User = Depends(get_current_verified_user)
):
    sub = await Subscription.get(subscription_id)
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")
    if sub.user_id != str(current_user.id) and str(current_user.id) not in sub.beneficiary_ids:
        raise HTTPException(status_code=403, detail="Access denied")

    stats = await UsageService.get_stats(sub)
    return UsageStatsResponse(**stats)


@router.post("/{subscription_id}/upload-payment")
async def upload_payment_proof(
    subscription_id: str,
    payment_method: str = "vodafone_cash",
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_verified_user)
):
    sub = await Subscription.get(subscription_id)
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")
    if sub.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    if sub.status != "pending":
        raise HTTPException(status_code=400, detail="Subscription is not pending payment")

    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    file_bytes = await file.read()
    if len(file_bytes) > 5 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="File too large. Max 5MB")
    url = await StorageService.upload(file_bytes, folder="payment_proofs")

    payment = await Payment.find_one(
        Payment.subscription_id == subscription_id,
        Payment.status == "pending"
    )
    if payment:
        payment.payment_proof_url = url
        payment.payment_method = payment_method
        await payment.save()

    return {
        "message": "Payment proof uploaded. Waiting for admin approval.",
        "subscription_id": subscription_id,
        "status": "pending_review",
        "proof_url": url,
    }


@router.post("/{subscription_id}/add-data")
async def add_data_package(
    subscription_id: str,
    body: CreateSubscriptionRequest,
    current_user: User = Depends(get_current_verified_user)
):
    sub = await Subscription.get(subscription_id)
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")
    if sub.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    if sub.status != "active":
        raise HTTPException(status_code=400, detail="Subscription is not active")

    package = await Package.get(body.package_id)
    if not package or not package.is_active:
        raise HTTPException(status_code=404, detail="Package not found")
    if package.type != "additional":
        raise HTTPException(status_code=400, detail="Only additional packages can be added")

    # check monthly subscription
    active_pkg = await Package.get(sub.package_id)
    if not active_pkg or active_pkg.type != "monthly":
        raise HTTPException(status_code=400, detail="Additional packages are only available for monthly subscribers")

    sub.total_data_gb += package.data_amount_gb
    sub.remaining_data_gb += package.data_amount_gb
    await sub.save()

    # update MikroTik user data limit
    MikroTikService.remove_hotspot_user(current_user.email)
    MikroTikService.create_hotspot_user(
        username=current_user.email,
        password=str(current_user.id)[-8:],
        data_limit_gb=sub.total_data_gb,
        validity_days=max(0, (sub.end_date - datetime.utcnow()).days) if sub.end_date else 0,
    )

    return {
        "message": f"Added {package.data_amount_gb} GB to your subscription",
        "new_total_gb": sub.total_data_gb,
        "new_remaining_gb": sub.remaining_data_gb
    }
