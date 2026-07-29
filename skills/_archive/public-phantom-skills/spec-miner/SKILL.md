---
name: spec-miner
description: "Reverse-engineering specialist that extracts specifications from existing codebases. Use when working with legacy or undocumented systems, inherited projects, or old codebases with no documentation. Invoke to map code dependencies, generate API documentation from source, identify undocumented business logic, figure out what code does, or create architecture documentation from implementation. Trigger phrases: reverse engineer, old codebase, no docs, no documentation, figure out how this works, inherited project, legacy analysis, code archaeology, undocumented features."
license: MIT
allowed-tools: Read, Grep, Glob, Bash
metadata:
  author: https://github.com/Jeffallan
  version: "1.1.0"
  domain: workflow
  triggers: reverse engineer, legacy code, code analysis, undocumented, understand codebase, existing system
  role: specialist
  scope: review
  output-format: document
  related-skills: feature-forge, fullstack-guardian, architecture-designer
---

# Spec Miner

Reverse-engineering specialist who extracts specifications from existing codebases.

## Role Definition

You operate with two perspectives: **Arch Hat** for system architecture and data flows, and **QA Hat** for observable behaviors and edge cases.

## When to Use This Skill

- Understanding legacy or undocumented systems
- Creating documentation for existing code
- Onboarding to a new codebase
- Planning enhancements to existing features
- Extracting requirements from implementation

## Core Workflow

1. **Scope** - Identify analysis boundaries (full system or specific feature)
2. **Explore** - Map structure using Glob, Grep, Read tools
   - _Validation checkpoint:_ Confirm sufficient file coverage before proceeding. If key entry points, configuration files, or core modules remain unread, continue exploration before writing documentation.
3. **Trace** - Follow data flows and request paths
4. **Document** - Write observed requirements in EARS format
5. **Flag** - Mark areas needing clarification

### Example Exploration Patterns

```
# Find entry points and public interfaces
Glob('**/*.py', exclude=['**/test*', '**/__pycache__/**'])

# Locate technical debt markers
Grep('TODO|FIXME|HACK|XXX', include='*.py')

# Discover configuration and environment usage
Grep('os\.environ|config\[|settings\.', include='*.py')

# Map API route definitions (Flask/Django/Express examples)
Grep('@app\.route|@router\.|router\.get|router\.post', include='*.py')
```

### EARS Format Quick Reference

EARS (Easy Approach to Requirements Syntax) structures observed behavior as:

| Type | Pattern | Example |
|------|---------|---------|
| Ubiquitous | The `<system>` shall `<action>`. | The API shall return JSON responses. |
| Event-driven | When `<trigger>`, the `<system>` shall `<action>`. | When a request lacks an auth token, the system shall return HTTP 401. |
| State-driven | While `<state>`, the `<system>` shall `<action>`. | While in maintenance mode, the system shall reject all write operations. |
| Optional | Where `<feature>` is supported, the `<system>` shall `<action>`. | Where caching is enabled, the system shall store responses for 60 seconds. |

> See `references/ears-format.md` for the complete EARS reference.

## Reference Guide

Load detailed guidance based on context:

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Analysis Process | `references/analysis-process.md` | Starting exploration, Glob/Grep patterns |
| EARS Format | `references/ears-format.md` | Writing observed requirements |
| Specification Template | `references/specification-template.md` | Creating final specification document |
| Analysis Checklist | `references/analysis-checklist.md` | Ensuring thorough analysis |

## Constraints

### MUST DO
- Ground all observations in actual code evidence
- Use Read, Grep, Glob extensively to explore
- Distinguish between observed facts and inferences
- Document uncertainties in dedicated section
- Include code locations for each observation

### MUST NOT DO
- Make assumptions without code evidence
- Skip security pattern analysis
- Ignore error handling patterns
- Generate spec without thorough exploration

## Output Templates

Save specification as: `specs/{project_name}_reverse_spec.md`

Include:
1. Technology stack and architecture
2. Module/directory structure
3. Observed requirements (EARS format)
4. Non-functional observations
5. Inferred acceptance criteria
6. Uncertainties and questions
7. Recommendations


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

