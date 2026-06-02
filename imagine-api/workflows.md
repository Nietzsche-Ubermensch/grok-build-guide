# Grok Imagine API Workflows

The Grok Imagine API lets you generate images, edit existing images, and produce video — all programmatically. This guide covers the core workflow patterns, with a focus on multi-image editing, video generation, and async job handling.

---

## API Basics

All Imagine API requests go to:

```
https://api.x.ai/v1/images/
```

Authentication uses the same API key as the rest of the Grok API:

```bash
export XAI_API_KEY="xai-..."
```

---

## Pattern 1: Single Image Generation

The simplest workflow — generate one image from a text prompt:

```python
import httpx, os

response = httpx.post(
    "https://api.x.ai/v1/images/generations",
    headers={"Authorization": "Bearer " + os.environ["XAI_API_KEY"]},
    json={
        "model": "grok-2-image",
        "prompt": "A futuristic city skyline at sunset, photorealistic",
        "n": 1,
        "response_format": "url",
    },
)
response.raise_for_status()
print(response.json()["data"][0]["url"])
```

---

## Pattern 2: Multi-Image Editing

Edit multiple images in a single request by passing them as base64-encoded inputs. This is more efficient than separate API calls:

```python
import base64, httpx, os
from pathlib import Path

def encode(path: str) -> str:
    return base64.b64encode(Path(path).read_bytes()).decode()

response = httpx.post(
    "https://api.x.ai/v1/images/edits",
    headers={"Authorization": "Bearer " + os.environ["XAI_API_KEY"]},
    json={
        "model": "grok-2-image",
        "prompt": "Add a sunset glow to each image",
        "images": [
            {"b64_json": encode("photo1.jpg")},
            {"b64_json": encode("photo2.jpg")},
        ],
        "n": 1,
        "response_format": "b64_json",
    },
    timeout=120,
)
response.raise_for_status()

for i, item in enumerate(response.json()["data"]):
    Path(f"output_{i}.jpg").write_bytes(base64.b64decode(item["b64_json"]))
    print(f"Saved output_{i}.jpg")
```

### Multi-Image Tips

| Consideration | Recommendation |
|---|---|
| Max images per request | Check current API docs; typically 4–8 |
| Image format | JPEG or PNG; keep under 4 MB each |
| Prompt specificity | Include global edits in one prompt to keep style consistent |
| Response format | `b64_json` for local saving; `url` for quick previews |

---

## Pattern 3: Video Generation

Generate short video clips from a text prompt:

```python
import httpx, os

response = httpx.post(
    "https://api.x.ai/v1/video/generations",
    headers={"Authorization": "Bearer " + os.environ["XAI_API_KEY"]},
    json={
        "model": "grok-2-video",
        "prompt": "A time-lapse of clouds moving over a mountain range",
        "duration_seconds": 5,
        "resolution": "1280x720",
    },
    timeout=300,   # video generation takes longer
)
response.raise_for_status()
data = response.json()
print(data["data"][0]["url"])
```

> **Note:** Video generation is compute-intensive. Synchronous requests may time out for clips longer than ~10 seconds. Use the async pattern below for longer videos.

---

## Pattern 4: Async Job Polling

For long-running tasks (large batches, video, high-resolution images), use the async API to avoid blocking your process:

```python
import httpx, os, time

API_KEY = os.environ["XAI_API_KEY"]
HEADERS = {"Authorization": "Bearer " + API_KEY}

# 1. Submit the job
submit = httpx.post(
    "https://api.x.ai/v1/images/generations",
    headers=HEADERS,
    json={
        "model": "grok-2-image",
        "prompt": "Abstract geometric art, vibrant colors",
        "n": 4,
        "async": True,   # request async processing
    },
)
submit.raise_for_status()
job_id = submit.json()["id"]
print(f"Job submitted: {job_id}")

# 2. Poll until complete
while True:
    status = httpx.get(
        f"https://api.x.ai/v1/images/jobs/{job_id}",
        headers=HEADERS,
    )
    status.raise_for_status()
    result = status.json()

    if result["status"] == "completed":
        for i, item in enumerate(result["data"]):
            print(f"Image {i}: {item['url']}")
        break
    elif result["status"] == "failed":
        raise RuntimeError(f"Job failed: {result.get('error')}")
    else:
        print(f"Status: {result['status']} — waiting 5 s…")
        time.sleep(5)
```

A ready-to-use version of this script is at [examples/async-poll.py](../examples/async-poll.py).

---

## Async Pattern Best Practices

| Practice | Why |
|---|---|
| Poll with exponential backoff | Reduces unnecessary API calls during long jobs |
| Set a max-retry limit | Prevents infinite loops if a job stalls |
| Store `job_id` persistently | Allows you to resume polling after a restart |
| Handle `failed` status explicitly | Surface errors early rather than waiting for timeout |

Exponential backoff example:

```python
import time

delay = 5
for attempt in range(20):
    # ... poll status ...
    if done:
        break
    time.sleep(delay)
    delay = min(delay * 1.5, 60)   # cap at 60 s
```

---

## Batch Processing Multiple Prompts

For large batches (e.g., generating product images for an entire catalog), fan out async jobs and collect results:

```python
import httpx, os, time

PROMPTS = [
    "Red sneaker on white background, studio lighting",
    "Blue sneaker on white background, studio lighting",
    "Green sneaker on white background, studio lighting",
]

API_KEY = os.environ["XAI_API_KEY"]
HEADERS = {"Authorization": "Bearer " + API_KEY}

# Submit all jobs
job_ids = []
for prompt in PROMPTS:
    r = httpx.post(
        "https://api.x.ai/v1/images/generations",
        headers=HEADERS,
        json={"model": "grok-2-image", "prompt": prompt, "async": True},
    )
    r.raise_for_status()
    job_ids.append(r.json()["id"])

print(f"Submitted {len(job_ids)} jobs")

# Poll until all complete
pending = set(job_ids)
results = {}

while pending:
    for job_id in list(pending):
        r = httpx.get(f"https://api.x.ai/v1/images/jobs/{job_id}", headers=HEADERS)
        data = r.json()
        if data["status"] == "completed":
            results[job_id] = data["data"]
            pending.discard(job_id)
        elif data["status"] == "failed":
            print(f"Job {job_id} failed: {data.get('error')}")
            pending.discard(job_id)
    if pending:
        time.sleep(5)

print(f"Done — {len(results)} successful")
```

---

## Next Steps

- [examples/async-poll.py](../examples/async-poll.py) — standalone async polling script
- [examples/multi-image-edit.sh](../examples/multi-image-edit.sh) — shell script for batch edits
- [Cost Optimization & Enterprise Tips](../guides/cost-optimization.md) — reduce API costs for large batches
