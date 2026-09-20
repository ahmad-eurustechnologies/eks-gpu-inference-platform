import os
import uuid

import boto3
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import FastAPI, File, HTTPException, UploadFile

app = FastAPI()

S3_IMAGE_BUCKET = os.getenv("S3_IMAGE_BUCKET")

if not S3_IMAGE_BUCKET:
    raise RuntimeError("S3_IMAGE_BUCKET environment variable is not set")

s3 = boto3.client("s3")


@app.on_event("startup")
def check_s3_access():
    try:
        s3.head_bucket(Bucket=S3_IMAGE_BUCKET)
        print(f"S3 bucket access verified: {S3_IMAGE_BUCKET}")

    except (ClientError, BotoCoreError) as exc:
        print(f"Unable to access S3 bucket '{S3_IMAGE_BUCKET}': {exc}")
        raise RuntimeError("S3 bucket access check failed") from exc


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    if file.content_type not in ("image/jpeg", "image/jpg"):
        raise HTTPException(
            status_code=400,
            detail="Only JPEG images are supported",
        )

    # S3 -> SQS event notifications are filtered to the ".jpg" suffix,
    # so the key must always end in ".jpg" regardless of the client's
    # original filename.
    object_key = f"images/{uuid.uuid4()}.jpg"

    try:
        s3.upload_fileobj(
            file.file,
            S3_IMAGE_BUCKET,
            object_key,
            ExtraArgs={
                "ContentType": file.content_type,
            },
        )

    except (ClientError, BotoCoreError) as exc:
        raise HTTPException(
            status_code=500,
            detail="Failed to upload image to S3",
        ) from exc

    return {
        "status": "uploaded",
        "bucket": S3_IMAGE_BUCKET,
        "key": object_key,
    }
