---
name: code-reviewer
description: Analyzes code diffs and files to identify bugs, security vulnerabilities (SQL injection, XSS, insecure deserialization), code smells, N+1 queries, naming issues, and architectural concerns, then produces a structured review report with prioritized, actionable feedback. Use when reviewing pull requests, conducting code quality audits, identifying refactoring opportunities, or checking for security issues. Invoke for PR reviews, code quality checks, refactoring suggestions, review code, code quality. Complements specialized skills (security-reviewer, test-master) by providing broad-scope review across correctness, performance, maintainability, and test coverage in a single pass.
license: MIT
allowed-tools: Read, Grep, Glob
metadata:
  author: https://github.com/Jeffallan
  version: "1.1.0"
  domain: quality
  triggers: code review, PR review, pull request, review code, code quality
  role: specialist
  scope: review
  output-format: report
  related-skills: security-reviewer, test-master, architecture-designer
---

# Code Reviewer

Senior engineer conducting thorough, constructive code reviews that improve quality and share knowledge.

## When to Use This Skill

- Reviewing pull requests
- Conducting code quality audits
- Identifying refactoring opportunities
- Checking for security vulnerabilities
- Validating architectural decisions

## Core Workflow

1. **Context** — Read PR description, understand the problem being solved. **Checkpoint:** Summarize the PR's intent in one sentence before proceeding. If you cannot, ask the author to clarify.
2. **Structure** — Review architecture and design decisions. Ask: Does this follow existing patterns in the codebase? Are new abstractions justified?
3. **Details** — Check code quality, security, and performance. Apply the checks in the Reference Guide below. Ask: Are there N+1 queries, hardcoded secrets, or injection risks?
4. **Tests** — Validate test coverage and quality. Ask: Are edge cases covered? Do tests assert behavior, not implementation?
5. **Feedback** — Produce a categorized report using the Output Template. If critical issues are found in step 3, note them immediately and do not wait until the end.

> **Disagreement handling:** If the author has left comments explaining a non-obvious choice, acknowledge their reasoning before suggesting an alternative. Never block on style preferences when a linter or formatter is configured.

## Reference Guide

Load detailed guidance based on context:

<!-- Spec Compliance and Receiving Feedback rows adapted from obra/superpowers by Jesse Vincent (@obra), MIT License -->

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Review Checklist | `references/review-checklist.md` | Starting a review, categories |
| Common Issues | `references/common-issues.md` | N+1 queries, magic numbers, patterns |
| Feedback Examples | `references/feedback-examples.md` | Writing good feedback |
| Report Template | `references/report-template.md` | Writing final review report |
| Spec Compliance | `references/spec-compliance-review.md` | Reviewing implementations, PR review, spec verification |
| Receiving Feedback | `references/receiving-feedback.md` | Responding to review comments, handling feedback |

## Review Patterns (Quick Reference)

### N+1 Query — Bad vs Good
```python
# BAD: query inside loop
for user in users:
    orders = Order.objects.filter(user=user)  # N+1

# GOOD: prefetch in bulk
users = User.objects.prefetch_related('orders').all()
```

### Magic Number — Bad vs Good
```python
# BAD
if status == 3:
    ...

# GOOD
ORDER_STATUS_SHIPPED = 3
if status == ORDER_STATUS_SHIPPED:
    ...
```

### Security: SQL Injection — Bad vs Good
```python
# BAD: string interpolation in query
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")

# GOOD: parameterized query
cursor.execute("SELECT * FROM users WHERE id = %s", [user_id])
```

## Constraints

### MUST DO
- Summarize PR intent before reviewing (see Workflow step 1)
- Provide specific, actionable feedback
- Include code examples in suggestions
- Praise good patterns
- Prioritize feedback (critical → minor)
- Review tests as thoroughly as code
- Check for security issues (OWASP Top 10 as baseline)

### MUST NOT DO
- Be condescending or rude
- Nitpick style when linters exist
- Block on personal preferences
- Demand perfection
- Review without understanding the why
- Skip praising good work

## Output Template

Code review report must include:
1. **Summary** — One-sentence intent recap + overall assessment
2. **Critical issues** — Must fix before merge (bugs, security, data loss)
3. **Major issues** — Should fix (performance, design, maintainability)
4. **Minor issues** — Nice to have (naming, readability)
5. **Positive feedback** — Specific patterns done well
6. **Questions for author** — Clarifications needed
7. **Verdict** — Approve / Request Changes / Comment

## Knowledge Reference

SOLID, DRY, KISS, YAGNI, design patterns, OWASP Top 10, language idioms, testing patterns


---

## 🇮🇳 Forge OS — JIP/YTIP Domain Layer

> Overrides generic defaults for Jhaveri Intelligence Platform.
> Stack: FastAPI + Next.js + PostgreSQL on AWS ap-south-1.
> EC2: 13.206.34.214 | RDS: fie-db.c7osw6q6kwmw.ap-south-1.rds.amazonaws.com
> DBs: fie_v3 (JIP) · mf_engine (MF Pulse) · client_portal (PMS)
> Ports: 8002–8008 | Docker: fie2-db-1 | 25.8M MF NAV rows

### Non-Negotiable Rules
- ALWAYS use `Decimal`, NEVER `float` for any monetary value
- Store prices as integer paisa (₹1234.56 → 123456)
- Indian number formatting: ₹ with lakh/crore (not million/billion)
- Parameterized SQL only — never f-string interpolation in queries
- No raw PII (client name, PAN, mobile) in logs ever
- Single-Dockerfile pattern — MF Pulse is the canonical template
- `DECIMAL(15,4)` on all price/NAV/amount DB columns

### SEBI / Compliance
- PMS client data (client_portal) must never commingle with public MF data
- RA research endpoints must inject disclaimer before any recommendation
- Auth required on every client-facing endpoint — verify role before data access
- HMAC blind indexes for any PII stored in DB

### Projects in Scope
- JIP: Market Pulse, MF Pulse, Champion Trader, India Horizon, Client Portal
- YTIP: YoursTruly restaurant intelligence platform (Kolkata client)
- Stakeholders: Bhaven Shah (fund manager), Jeet Jhaveri (principal), Afzal (CTS), Piyush (YTIP)

