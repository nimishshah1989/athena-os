---
name: Feedback implementation decisions (2026-03-31)
description: Nimish's decisions on Analytics tab, Claude API budget, fund360.html mockup, and ops scoring
type: project
---

Decisions made on 2026-03-31 during V1 feedback review:

1. **Analytics tab**: Keep and enrich (weekly intelligence, risk efficiency map, valuation pulse). Make them genuinely actionable.
2. **Claude API budget**: $5/month approved. Identify highest-impact areas for AI-generated content. Cache aggressively.
3. **fund360.html mockup**: Mostly binding design target for Fund 360 detail page, but must follow unified design language across all pages.
4. **Ops scoring**: User wants to simultaneously improve quality score, architecture score, and security score per ops.jslwealth.in engine.

**Why:** These are binding decisions for the V2 implementation sprint.
**How to apply:** Use these as constraints when building. Don't exceed $5/month Claude API. Always reference fund360.html for Fund 360 layout. Analytics tab stays but must be enriched with real utility.
