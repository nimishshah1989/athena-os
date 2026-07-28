---
name: Prefer free open-source LLMs with multi-provider fallback
description: When rate-limited or facing paid-API friction, user's default is to switch to free OSS models via Groq/OpenRouter — not to pay. Design LLM code as provider fallback chains.
type: feedback
originSessionId: 2f310c99-51f6-4ae3-91ae-f37729895270
---
When an LLM path hits rate limits, expired keys, or paid-tier friction,
the user's instinct is "use free open-source models" — not "add a paid
key". Design every LLM call site as a provider fallback chain across
multiple free providers, not a single-provider hard dependency.

**Concrete example from 2026-04-13:** After the existing `GOOGLE_API_KEY`
turned out to have `free_tier_requests limit: 0` for Gemini, I proposed
three options including "enable billing on the Google project". The
user's response was verbatim: *"use openrouter api: ... - and let's use
free open source models like gemma4 and qwen and best open sourced LLMs
to do the needful"*. Later, when OpenRouter's shared free pool also
throttled, they provided a Groq key specifically to chain through Groq
first — still free tier, just a better free tier.

**Preferred free providers (in order of generosity / reliability):**
1. **Groq** — 1,000–14,400 req/day per model free, ~10x faster inference
   than most providers. Offers `openai/gpt-oss-120b`,
   `llama-3.3-70b-versatile`, `qwen/qwen3-32b`,
   `moonshotai/kimi-k2-instruct-0905`, `llama-3.1-8b-instant`. Whisper
   `whisper-large-v3` too.
2. **OpenRouter** — unified gateway to many free `:free` variants,
   smaller shared daily cap (~50 req/day) but good as secondary fallback.
3. **Gemini (Google AI Studio)** — only if a fresh key from
   aistudio.google.com (NOT google cloud console), `gemini-2.5-flash-lite`
   has 1000 RPD free, `gemini-2.5-flash` has 250 RPD.

**Pattern to use for any LLM code site:**
- Primary chain: Groq models (in descending capability order)
- Secondary: OpenRouter `:free` chain
- Tertiary: Gemini (only if user has a fresh AI Studio key)
- Never Ollama unless `GOLDILOCKS_USE_OLLAMA=1` is explicitly set (it's
  a stub endpoint that falls through to the real providers)
- Each provider handles 429/5xx/empty-content by falling through to the
  next, not retrying in place — the point is different upstreams, not
  the same upstream harder.
- On total chain exhaustion, raise a transient error so the caller keeps
  the work item as 'pending' instead of marking 'failed' — the next cron
  run picks it up when quotas reset.

**How to apply:** Any new script that talks to an LLM should import the
same cascading pattern used by
`scripts/ingest/run_goldilocks_extraction.py`. Never hardcode one
provider. Never write code that assumes OpenAI or Anthropic unless the
user has explicitly said they want to pay for it.
