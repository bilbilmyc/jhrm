## Agent skills

### Issue tracker

GitHub Issues via the `gh` CLI. External PRs are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Five roles use these strings: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

---

## Output discipline (HARD GUARD)

**Do not use repeated short phrases in any output — not as placeholder, not as scaffolding, not as "self-deprecating joke", not as "ironic example".** The pattern itself triggers a generation attractor that self-reinforces into multi-thousand-token loops regardless of authorial intent. This has been observed 5+ times in this project (2026-06-25) and the "ironic" variant triggered exactly the same loop — model can't distinguish sincere from joking repetition.

Forbidden patterns:

- "X X X X X..." as a "fill in later" marker
- Doubled/tripled identical tokens in a row
- Any 2+ adjacent identical short phrases, even when discussing the bug itself

If you need a placeholder, write an explicit bracketed marker like `[TODO: ladder-table]` or `<<placeholder>>`. Never use repeated tokens to mean "and so on".

When discussing this bug, refer to it as "the repetition loop bug" or "the token attractor" — never reproduce the offending phrase even in quotes.

Self-check before sending any reply over 10 lines: scan for "X X" patterns (where X is any short phrase 1-3 characters), repeated short phrases, or sentences that don't make sense. If found, rewrite before sending. Also: scan for the specific words "ladder" "修真" appearing back-to-back, which is the canonical incident token.

See `~/.claude/memory/output-degeneration-repetition-loop.md` for the full incident history.
