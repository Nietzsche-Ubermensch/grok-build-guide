#!/usr/bin/env bash
# multi-image-edit.sh
# Submit a batch of images to the Grok Imagine API for editing.
#
# Usage:
#   export XAI_API_KEY="xai-..."
#   bash multi-image-edit.sh "Add a sunset glow" photo1.jpg photo2.jpg photo3.jpg

set -euo pipefail

PROMPT="${1:?Usage: $0 '<prompt>' image1.jpg [image2.jpg ...]}"
shift
IMAGES=("$@")

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "Error: at least one image file required." >&2
  exit 1
fi

if [[ -z "${XAI_API_KEY:-}" ]]; then
  echo "Error: XAI_API_KEY environment variable is not set." >&2
  exit 1
fi

# Build the JSON payload with base64-encoded images
build_payload() {
  local prompt="$1"
  shift
  local images_json="["
  local first=true

  for img in "$@"; do
    if [[ ! -f "$img" ]]; then
      echo "Error: file not found: $img" >&2
      exit 1
    fi
    local b64
    b64=$(base64 < "$img" | tr -d '\n')
    if [[ "$first" == true ]]; then
      first=false
    else
      images_json+=","
    fi
    images_json+="{\"b64_json\":\"${b64}\"}"
  done
  images_json+="]"

  printf '{"model":"grok-2-image","prompt":%s,"images":%s,"n":1,"response_format":"b64_json"}' \
    "$(printf '%s' "$prompt" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
    "$images_json"
}

echo "Submitting ${#IMAGES[@]} image(s) for editing…"
PAYLOAD=$(build_payload "$PROMPT" "${IMAGES[@]}")

RESPONSE=$(curl -sS \
  -X POST "https://api.x.ai/v1/images/edits" \
  -H "Authorization: Bearer ${XAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Save each result
COUNT=$(echo "$RESPONSE" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(len(d["data"]))')

for i in $(seq 0 $((COUNT - 1))); do
  OUT="output_${i}.jpg"
  echo "$RESPONSE" | python3 -c "
import json, sys, base64
d = json.load(sys.stdin)
data = d['data'][$i]['b64_json']
with open('${OUT}', 'wb') as f:
    f.write(base64.b64decode(data))
"
  echo "Saved ${OUT}"
done

echo "Done."
