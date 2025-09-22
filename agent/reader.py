import os
import time
import uuid
from datetime import datetime, timezone
from azure.storage.blob import BlobServiceClient


def main():
    conn = os.environ.get("AZURE_STORAGE_CONNECTION_STRING")
    if not conn:
        raise SystemExit("AZURE_STORAGE_CONNECTION_STRING is required")
    container = os.environ.get("BLOB_CONTAINER", "leads-raw")
    interval = int(os.environ.get("CADENCE_SECONDS", "30"))
    seen_path = "/state/seen.txt"
    os.makedirs("/state", exist_ok=True)
    seen = set()
    if os.path.exists(seen_path):
        with open(seen_path) as f:
            seen = set(l.strip() for l in f)
    bsc = BlobServiceClient.from_connection_string(conn)
    cc = bsc.get_container_client(container)
    print(f"[agent] Watching container {container}...")
    while True:
        for blob in cc.list_blobs(name_starts_with="leads-raw/"):
            if blob.name in seen:
                continue
            seen.add(blob.name)
            try:
                data = cc.download_blob(blob.name).content_as_text()
            except Exception:
                data = "(failed to read)"
            print(f"[{datetime.now(timezone.utc).isoformat()}] New lead: {blob.name}\n{data[:500]}\n")
        with open(seen_path, "w") as f:
            for name in sorted(seen):
                f.write(name + "\n")
        time.sleep(interval)


if __name__ == "__main__":
    main()

