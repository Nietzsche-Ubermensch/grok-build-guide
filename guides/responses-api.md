# Responses API Guide

The Responses API is the recommended way to interact with Grok models via the xAI API. It offers stateful conversations, better support for reasoning models, and easier chaining compared to the legacy Chat Completions API.

---

## Why Use the Responses API?

| Feature | Detail |
|---|---|
| **Stateful by default** | Previous messages, reasoning traces, and responses are stored on xAI's servers for 30 days |
| **Efficient chaining** | Continue conversations by sending only new messages + the previous `response_id` |
| **Reasoning model support** | Excellent support for encrypted thinking content |
| **Simpler multi-turn** | Cleaner handling of long-running or multi-turn interactions |

> If you prefer full local control, set `store: false`.

---

## 1. Creating a Response (Basic Example)

### Python (xAI SDK — Recommended)

```python
from xai_sdk import Client
from xai_sdk.chat import system, user
import os

client = Client(api_key=os.getenv("XAI_API_KEY"))

chat = client.chat.create(model="grok-4.3")
chat.append(system("You are a helpful AI assistant."))
chat.append(user("How big is the universe?"))

response = chat.sample()
print(response)
print("Response ID:", response.id)   # Use this to continue later
```

### Python (OpenAI SDK compatible)

```python
from openai import OpenAI
import os

client = OpenAI(
    api_key=os.getenv("XAI_API_KEY"),
    base_url="https://api.x.ai/v1"
)

response = client.responses.create(
    model="grok-4.3",
    input=[
        {"role": "system", "content": "You are a helpful AI assistant."},
        {"role": "user", "content": "How big is the universe?"}
    ]
)
print(response)
print("Response ID:", response.id)
```

---

## 2. Disable Server-Side Storage (`store: false`)

If you don't want xAI to store your conversation:

```python
response = client.responses.create(
    model="grok-4.3",
    input=[...],
    store=False          # ← Conversation is not stored on server
)
```

Use this for:

- Privacy-sensitive applications
- Compliance requirements
- Short-lived or one-off requests

---

## 3. Encrypted Reasoning Content (Reasoning Models)

For reasoning models (grok-4.3, etc.), you can retrieve the model's internal thinking process in encrypted form.

```python
response = client.responses.create(
    model="grok-4.3",
    input=[...],
    include=["reasoning.encrypted_content"]
)
```

You can then pass this encrypted content in future requests to continue the reasoning chain without losing context.

---

## 4. Chaining Conversations (Stateful)

This is one of the biggest advantages of the Responses API — you only send new messages and the API handles the rest.

```python
# First response
first = client.responses.create(
    model="grok-4.3",
    input=[{"role": "user", "content": "How big is the universe?"}]
)

# Continue the conversation
second = client.responses.create(
    model="grok-4.3",
    previous_response_id=first.id,
    input=[{"role": "user", "content": "How do stars form?"}]
)
```

---

## 5. Retrieving & Deleting Responses

```python
# Retrieve a previous response
response = client.responses.retrieve("resp_abc123")

# Delete a stored response
client.responses.delete("resp_abc123")
```

---

## Best Practices

| Use Case | Recommendation | Why |
|---|---|---|
| Long multi-turn conversations | Use Responses API + `previous_response_id` | Much more efficient |
| Reasoning models | Always include `reasoning.encrypted_content` when needed | Better performance & continuity |
| Privacy / Compliance | Set `store: false` | Data not stored on xAI servers |
| CI/CD / Automation | Use API key + `store: false` | Stateless and clean |
| Maximum context control | Manage history locally + `store: false` | Full control |
| Long-running requests | Increase timeout (e.g. 3600s) | Reasoning models can take time |

---

## Quick Recommendation Based on Your Setup

For headless scripting and enterprise environments:

- Use Responses API with `store: false` for most automation.
- Use `previous_response_id` when you need multi-turn state without sending full history.
- For high-security environments, combine with `XAI_API_KEY` + strict sandboxing.

---

## Next Steps

- [Cost Optimization & Enterprise Tips](cost-optimization.md) — keep token usage and costs under control
- [MCP List Best Practices](mcp-list-best-practices.md) — manage MCP server overhead
