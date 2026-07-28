# Proven Code Patterns — JIP Platform
# Claude uses these. Does not reinvent them.
---

## Python — Decimal (use always for financial values)
```python
from decimal import Decimal, ROUND_HALF_UP
value = Decimal(str(raw))                                    # always via str()
rounded = value.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
```

## Python — mfapi.in null handling (ALWAYS do this)
```python
data = fetch_nav(fund_code)
if data is None or not data.get('data'):
    return None  # delisted funds return None — never skip this
nav = Decimal(str(data['data'][0]['nav']))
```

## Python — FastAPI response envelope
```python
{"success": True, "data": {...}, "meta": {"request_id": "uuid", "timestamp": "ISO8601"}}
{"success": False, "error": {"code": "VALIDATION_ERROR", "message": "...", "details": {}}}
```

## Python — Config that fails loudly on startup
```python
from pydantic_settings import BaseSettings
class Settings(BaseSettings):
    supabase_url: str
    supabase_service_role_key: str
    class Config: env_file = ".env"
settings = Settings()  # raises ValidationError immediately if any var missing
```

## TypeScript — Indian number formatting (use formatLakhs from utils/format.ts)
```typescript
export const formatINR = (v: number) =>
  new Intl.NumberFormat('en-IN',{style:'currency',currency:'INR',maximumFractionDigits:0}).format(v)
export const formatLakhs = (v: number) => {
  if (v >= 10000000) return `₹${(v/10000000).toFixed(2)}Cr`
  if (v >= 100000)   return `₹${(v/100000).toFixed(2)}L`
  return formatINR(v)
}
```

## TypeScript — API URL (Docker internal — never localhost in containers)
```typescript
// .env: API_BASE_URL=http://backend:8000  ← Docker service name, not localhost
const data = await fetch(`${process.env.API_BASE_URL}/api/endpoint`)
```

## JIP Design System (always apply)
```
bg-white | border border-gray-200 | rounded-lg | shadow-sm
text-gray-900 (primary) | text-gray-500 (secondary)
Accent: teal #0F6E56 → text-teal-700 / bg-teal-600
Error: text-red-600 | Success: text-green-600
```
