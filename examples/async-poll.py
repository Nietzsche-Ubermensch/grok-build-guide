#!/usr/bin/env python3
"""
async-poll.py — Poll the Grok Imagine API for an async image generation job.

Usage:
    export XAI_API_KEY="xai-..."
    python3 async-poll.py
"""

import os
import time
import httpx

API_KEY = os.environ["XAI_API_KEY"]
HEADERS = {"Authorization": f"******", "Content-Type": "application/json"}
BASE_URL = "https://api.x.ai/v1"


def submit_job(prompt: str, n: int = 1) -> str:
    """Submit an async image generation job and return the job ID."""
    response = httpx.post(
        f"{BASE_URL}/images/generations",
        headers=HEADERS,
        json={
            "model": "grok-2-image",
            "prompt": prompt,
            "n": n,
            "async": True,
        },
    )
    response.raise_for_status()
    job_id = response.json()["id"]
    print(f"Job submitted: {job_id}")
    return job_id


def poll_job(job_id: str, max_attempts: int = 20) -> list[dict]:
    """Poll until the job completes and return the result data list."""
    delay = 5.0
    for attempt in range(1, max_attempts + 1):
        response = httpx.get(f"{BASE_URL}/images/jobs/{job_id}", headers=HEADERS)
        response.raise_for_status()
        result = response.json()
        status = result["status"]

        print(f"Attempt {attempt}/{max_attempts} — status: {status}")

        if status == "completed":
            return result["data"]
        elif status == "failed":
            raise RuntimeError(f"Job failed: {result.get('error', 'unknown error')}")

        time.sleep(delay)
        delay = min(delay * 1.5, 60)  # exponential backoff, cap at 60 s

    raise TimeoutError(f"Job {job_id} did not complete after {max_attempts} attempts")


def main() -> None:
    prompt = "A serene mountain lake at dawn, photorealistic, wide angle"

    job_id = submit_job(prompt, n=2)
    data = poll_job(job_id)

    for i, item in enumerate(data):
        print(f"Image {i}: {item.get('url', '(b64 data, not shown)')}")

    print(f"Done — {len(data)} image(s) generated.")


if __name__ == "__main__":
    main()
