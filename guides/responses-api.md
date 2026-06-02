# Responses API — Enterprise Setup

The Responses API is the recommended way to interact with Grok models via the xAI API. This guide covers enterprise configuration: authentication, data residency, CI/CD integration, compliance controls, error handling, and lifecycle management.

---

## API Capabilities at a Glance

| Capability | Detail |
|---|---|
| **Stateful conversations** | Messages, reasoning traces, and responses stored on xAI servers for 30 days |
| **Conversation chaining** | Reference a previous `response_id` to continue without resending full history |
| **Encrypted reasoning** | Retrieve and forward a reasoning model's thinking state across turns |
| **Storage opt-out** | Set `store: false` to keep all data client-side only |

---

## Authentication

### API Key Management

Never hardcode API keys. Supply them via environment variables.

```bash
# Shell profile or secrets manager export
export XAI_API_KEY="xai-..."
```

For team environments, inject the key through your secrets manager (e.g. AWS Secrets Manager, HashiCorp Vault, GitHub Actions secrets) rather than storing it in any config file committed to version control.

### SDK Initialisation

**xAI SDK:**

```python
from xai_sdk import Client
import os

client = Client(api_key=os.getenv("XAI_API_KEY"))
```

**OpenAI-compatible SDK:**

```python
from openai import OpenAI
import os

client = OpenAI(
    api_key=os.getenv("XAI_API_KEY"),
    base_url="https://api.x.ai/v1",
    timeout=3600,        # Required for long-running reasoning model requests
    max_retries=3,
)
```

---

## Data Residency & Compliance

### Disable Server-Side Storage

For any workload subject to data protection requirements (GDPR, HIPAA, SOC 2, internal data classification policies), set `store: false` on every request. This ensures no conversation data is written to xAI infrastructure.

```python
response = client.responses.create(
    model="grok-4.3",
    input=[...],
    store=False,
)
```

Apply this by default in your enterprise wrapper/service layer so individual callers cannot accidentally omit it.

### Response Lifecycle Management

When `store` is not disabled, responses are retained for 30 days. For compliance-driven retention controls:

- **Retrieve** a stored response to log or archive it internally before deletion.
- **Delete** responses immediately after use when your policy requires shorter retention.

```python
# Archive internally, then delete from xAI servers
response = client.responses.retrieve("resp_...")
internal_audit_log.write(response)
client.responses.delete("resp_...")
```

---

## Model & Timeout Configuration

Pin the model version in all production and CI workloads to prevent uncontrolled upgrades:

```python
MODEL = "grok-4.3"   # Pin; review change log before updating
TIMEOUT = 3600       # Reasoning models can take significant time
```

Set timeouts at the SDK level (as shown in initialisation above), not per-request, so they apply uniformly across your service.

---

## Stateful Conversation Chaining

Use `previous_response_id` for multi-turn workflows. This sends only the new message — the API retrieves prior context from the stored response — significantly reducing token usage in long sessions.

```python
first_response = client.responses.create(
    model=MODEL,
    input=[{"role": "user", "content": "..."}],
)

follow_up = client.responses.create(
    model=MODEL,
    previous_response_id=first_response.id,
    input=[{"role": "user", "content": "..."}],
)
```

Store `response_id` values in your session state (database, cache) so they survive process restarts and can be resumed across service instances.

---

## Encrypted Reasoning Content

When using reasoning models in multi-turn pipelines, request encrypted reasoning content and forward it on subsequent turns to preserve the model's reasoning chain without re-running it.

```python
first = client.responses.create(
    model=MODEL,
    input=[...],
    include=["reasoning.encrypted_content"],
)

# Pass encrypted content forward to continue the reasoning chain
second = client.responses.create(
    model=MODEL,
    previous_response_id=first.id,
    input=[...],
    include=["reasoning.encrypted_content"],
)
```

The encrypted content is opaque to your application — only the xAI API can interpret it. Do not log or store it beyond what is needed to forward it.

---

## CI/CD Integration

For automated pipelines, use a stateless pattern: `store: false`, no `previous_response_id`, explicit timeout, and structured error handling.

```python
import os
from openai import OpenAI, APIError, APITimeoutError

client = OpenAI(
    api_key=os.getenv("XAI_API_KEY"),
    base_url="https://api.x.ai/v1",
    timeout=3600,
    max_retries=3,
)

def call_grok(prompt: str) -> str:
    try:
        response = client.responses.create(
            model="grok-4.3",
            input=[{"role": "user", "content": prompt}],
            store=False,
        )
        return response.output_text
    except APITimeoutError:
        raise RuntimeError("xAI API timed out — consider increasing TIMEOUT or splitting the request")
    except APIError as e:
        raise RuntimeError(f"xAI API error {e.status_code}: {e.message}")
```

Set `XAI_API_KEY` as a CI secret (GitHub Actions, GitLab CI, etc.) and never pass it as a CLI argument or log it.

---

## Enterprise Configuration Checklist

| Control | Setting | Notes |
|---|---|---|
| API key source | Environment variable / secrets manager | Never in code or config files |
| Storage | `store=False` for regulated data | Apply in service wrapper layer |
| Model version | Pinned (e.g. `grok-4.3`) | Review changelog before upgrading |
| Timeout | `3600s` at SDK level | Reasoning models require long timeouts |
| Retries | `max_retries=3` | Built-in exponential backoff |
| Response deletion | Delete after internal archival | For sub-30-day retention requirements |
| Reasoning content | Do not persist encrypted blobs | Forward only; treat as ephemeral |
| CI secrets | Injected via secrets manager | Never logged or printed |

---

## Next Steps

- [Cost Optimization & Enterprise Tips](cost-optimization.md) — token budgets, audit logging, centralized config
- [MCP List Best Practices](mcp-list-best-practices.md) — manage MCP server overhead
