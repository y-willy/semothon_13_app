import os
from typing import Optional

import boto3
from botocore.client import Config
from app.config import settings


R2_ACCOUNT_ID = settings.R2_ACCOUNT_ID
R2_ACCESS_KEY_ID = settings.R2_ACCESS_KEY_ID
R2_SECRET_ACCESS_KEY = settings.R2_SECRET_ACCESS_KEY
R2_BUCKET_NAME = settings.R2_BUCKET_NAME

if not all([R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET_NAME]):
    raise RuntimeError("R2 environment variables are not fully configured.")

R2_ENDPOINT = f"https://{R2_ACCOUNT_ID}.r2.cloudflarestorage.com"


def get_r2_client():
    return boto3.client(
        service_name="s3",
        endpoint_url=R2_ENDPOINT,
        aws_access_key_id=R2_ACCESS_KEY_ID,
        aws_secret_access_key=R2_SECRET_ACCESS_KEY,
        region_name="auto",
        config=Config(signature_version="s3v4"),
    )


def upload_bytes(
    *,
    data: bytes,
    object_key: str,
    content_type: Optional[str] = None,
    original_filename: Optional[str] = None,
) -> None:
    s3 = get_r2_client()

    extra_args = {}
    if content_type:
        extra_args["ContentType"] = content_type

    if original_filename:
        # 다운로드 시 원본 파일명 유지에 도움
        extra_args["ContentDisposition"] = f'attachment; filename="{original_filename}"'

    s3.put_object(
        Bucket=R2_BUCKET_NAME,
        Key=object_key,
        Body=data,
        **extra_args,
    )


def generate_download_url(
    *,
    object_key: str,
    download_filename: Optional[str] = None,
    expires_in: int = 3600,
) -> str:
    s3 = get_r2_client()

    params = {
        "Bucket": R2_BUCKET_NAME,
        "Key": object_key,
    }

    if download_filename:
        params["ResponseContentDisposition"] = (
            f'attachment; filename="{download_filename}"'
        )

    return s3.generate_presigned_url(
        ClientMethod="get_object",
        Params=params,
        ExpiresIn=expires_in,
    )


def generate_view_url(
    *,
    object_key: str,
    inline_filename: Optional[str] = None,
    expires_in: int = 3600,
) -> str:
    s3 = get_r2_client()

    params = {
        "Bucket": R2_BUCKET_NAME,
        "Key": object_key,
    }

    if inline_filename:
        params["ResponseContentDisposition"] = (
            f'inline; filename="{inline_filename}"'
        )

    return s3.generate_presigned_url(
        ClientMethod="get_object",
        Params=params,
        ExpiresIn=expires_in,
    )