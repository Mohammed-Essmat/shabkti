from fastapi import APIRouter, HTTPException, Depends
from app.schemas.package import PackageResponse
from app.models.package import Package
from app.utils.dependencies import get_current_verified_user
from app.models.user import User
from typing import List

router = APIRouter(prefix="/api/packages", tags=["Packages"])


def _package_response(p: Package) -> PackageResponse:
    return PackageResponse(
        id=str(p.id),
        name=p.name,
        type=p.type,
        data_amount_gb=p.data_amount_gb,
        price=p.price,
        validity_days=p.validity_days,
        description=p.description,
        features=p.features,
        is_active=p.is_active
    )


@router.get("", response_model=List[PackageResponse])
async def get_packages(current_user: User = Depends(get_current_verified_user)):
    packages = await Package.find(Package.is_active == True).to_list()
    return [_package_response(p) for p in packages]


@router.get("/{package_id}", response_model=PackageResponse)
async def get_package(package_id: str, current_user: User = Depends(get_current_verified_user)):
    package = await Package.get(package_id)
    if not package or not package.is_active:
        raise HTTPException(status_code=404, detail="Package not found")
    return _package_response(package)
