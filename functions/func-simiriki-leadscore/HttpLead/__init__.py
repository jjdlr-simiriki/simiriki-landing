import json
import logging
import os
import uuid
from datetime import datetime, timezone

import azure.functions as func
from azure.storage.blob import BlobServiceClient


def _validate(payload: dict) -> tuple[bool, list[str]]:
    errors: list[str] = []
    # Minimal fields; adapt as needed
    name = payload.get("name")
    email = payload.get("email")
    if not name or not isinstance(name, str) or len(name.strip()) < 2:
        errors.append("Invalid 'name'")
    if not email or "@" not in email:
        errors.append("Invalid 'email'")
    # Optional fields: company, phone, message
    return (len(errors) == 0, errors)


def _blob_path() -> str:
    now = datetime.now(timezone.utc)
    return f"leads-raw/{now.year:04d}/{now.month:02d}/{now.day:02d}/{uuid.uuid4()}.json"


def main(req: func.HttpRequest) -> func.HttpResponse:
    try:
        payload = req.get_json()
    except ValueError:
        return func.HttpResponse(
            json.dumps({"error": "Invalid JSON"}), status_code=400, mimetype="application/json"
        )

    ok, errors = _validate(payload)
    if not ok:
        return func.HttpResponse(
            json.dumps({"error": "Validation failed", "details": errors}),
            status_code=422,
            mimetype="application/json",
        )

    conn = os.getenv("AZURE_STORAGE_CONNECTION_STRING") or os.getenv("AzureWebJobsStorage")
    if not conn:
        logging.error("Missing AZURE_STORAGE_CONNECTION_STRING/AzureWebJobsStorage")
        return func.HttpResponse(
            json.dumps({"error": "Server misconfiguration"}),
            status_code=500,
            mimetype="application/json",
        )

    bsc = BlobServiceClient.from_connection_string(conn)
    blob_name = _blob_path()
    container_name = os.getenv("BLOB_CONTAINER", "leads-raw")
    try:
        container = bsc.get_container_client(container_name)
        # Ensure container exists (idempotent)
        try:
            container.create_container()
        except Exception:
            pass
        data = json.dumps({
            "received_at": datetime.now(timezone.utc).isoformat(),
            "ip": req.headers.get("x-forwarded-for") or req.headers.get("x-client-ip"),
            "ua": req.headers.get("user-agent"),
            "lead": payload,
        }, ensure_ascii=False)
        container.upload_blob(name=blob_name, data=data, overwrite=False, content_type="application/json")
    except Exception as ex:
        logging.exception("Failed to write blob: %s", ex)
        return func.HttpResponse(
            json.dumps({"error": "Persist failed"}), status_code=500, mimetype="application/json"
        )

    return func.HttpResponse(
        json.dumps({"status": "ok", "blob": blob_name}),
        status_code=200,
        mimetype="application/json",
    )

