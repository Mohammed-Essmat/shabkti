from fastapi import APIRouter, HTTPException, Depends
from app.schemas.beneficiary import AddBeneficiaryRequest, UpdateBeneficiaryRequest, BeneficiaryResponse
from app.models.user import User
from app.models.subscription import Subscription
from app.utils.dependencies import get_current_verified_user
from app.utils.security import hash_password
from datetime import datetime
from typing import List

router = APIRouter(prefix="/api/beneficiaries", tags=["Beneficiaries"])


def _beneficiary_response(user: User) -> BeneficiaryResponse:
    return BeneficiaryResponse(
        id=str(user.id),
        name=user.name,
        email=user.email,
        phone=user.phone,
        profile_picture_url=user.profile_picture_url,
        created_at=user.created_at
    )


async def _get_active_sub(current_user: User) -> Subscription:
    sub = await Subscription.find_one(
        Subscription.user_id == str(current_user.id),
        Subscription.status == "active"
    )
    if not sub:
        raise HTTPException(status_code=404, detail="No active subscription found")
    return sub


@router.post("", response_model=BeneficiaryResponse, status_code=201)
async def add_beneficiary(
    body: AddBeneficiaryRequest,
    current_user: User = Depends(get_current_verified_user)
):
    sub = await _get_active_sub(current_user)

    if await User.find_one(User.email == body.email):
        raise HTTPException(status_code=400, detail="Email already registered")
    if await User.find_one(User.phone == body.phone):
        raise HTTPException(status_code=400, detail="Phone already registered")

    beneficiary = User(
        name=body.name,
        email=body.email,
        phone=body.phone,
        password_hash=hash_password(body.password),
        role="beneficiary",
        parent_subscription_id=str(sub.id),
        is_verified=True
    )
    await beneficiary.insert()

    sub.beneficiary_ids.append(str(beneficiary.id))
    await sub.save()

    return _beneficiary_response(beneficiary)


@router.get("", response_model=List[BeneficiaryResponse])
async def get_beneficiaries(current_user: User = Depends(get_current_verified_user)):
    sub = await _get_active_sub(current_user)

    result = []
    for bid in sub.beneficiary_ids:
        user = await User.get(bid)
        if user:
            result.append(_beneficiary_response(user))
    return result


@router.put("/{beneficiary_id}", response_model=BeneficiaryResponse)
async def update_beneficiary(
    beneficiary_id: str,
    body: UpdateBeneficiaryRequest,
    current_user: User = Depends(get_current_verified_user)
):
    sub = await _get_active_sub(current_user)

    if beneficiary_id not in sub.beneficiary_ids:
        raise HTTPException(status_code=404, detail="Beneficiary not found in your subscription")

    beneficiary = await User.get(beneficiary_id)
    if not beneficiary:
        raise HTTPException(status_code=404, detail="Beneficiary not found")

    if body.name:
        beneficiary.name = body.name
    beneficiary.updated_at = datetime.utcnow()
    await beneficiary.save()

    return _beneficiary_response(beneficiary)


@router.delete("/{beneficiary_id}")
async def delete_beneficiary(
    beneficiary_id: str,
    current_user: User = Depends(get_current_verified_user)
):
    sub = await _get_active_sub(current_user)

    if beneficiary_id not in sub.beneficiary_ids:
        raise HTTPException(status_code=404, detail="Beneficiary not found in your subscription")

    sub.beneficiary_ids.remove(beneficiary_id)
    await sub.save()

    beneficiary = await User.get(beneficiary_id)
    if beneficiary:
        await beneficiary.delete()

    return {"message": "Beneficiary removed successfully"}
