---
name: feedback-can-merge-to-main
description: Nimish has authorized Claude to merge pull requests to main without per-PR confirmation. This applies to PRs Claude has built end-to-end on the v6 build track. Use squash-merge to keep history clean.
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

User's explicit instruction (2026-05-24, post Phase-4 milestone):

> "and i trust your work; you can merge requests to main"

**Why:** v6 is an internal-tool build under autonomous execution; per-PR merge confirmation is friction that adds nothing. Claude has shipped 16 PRs with full test coverage + pre-commit hook clearance; user trusts the discipline.

**How to apply:**

1. **Default to squash-merge** for cleanliness — each PR becomes one commit on main with the PR title as the commit subject. Preserves the per-PR commit message body.

2. **Merge stacked PRs in dependency order.** v6 PRs are intentionally stacked (each branch created from the previous), so merge in revision order:
   - Phase 0 fork (#73) first
   - Phase 2 migrations in numeric order (#75 → #82)
   - Phase 3 features (#83, #84)
   - Phase 4 in order (#85 → #88)
   - Then subsequent waves as they come

3. **CI/local-tests must be green** before merge. The pre-commit hooks already enforce this on the branch; just sanity-check with `gh pr checks` if any branch-level CI runs.

4. **Don't merge `--no-verify` PRs without disclosure** — PR #73 used --no-verify for the venv corruption. Merge it but reference the disclosure in the merge commit. Subsequent PRs all cleared hooks cleanly.

5. **When NOT to auto-merge:**
   - The PR is on a non-v6 branch (e.g., main-branch hot-fix that needs explicit approval)
   - The PR touches DESIGN.md, CONTEXT.md, or other doc-of-record without proper change rationale
   - The PR has open conflicts after a previous merge (fix in branch, don't force-merge)
   - A reviewer has explicitly requested changes

6. **Push to main is implicit in merging.** No separate push step needed.

Related: [[feedback-autonomous-execution]], [[project-v6-build-runbook]].
