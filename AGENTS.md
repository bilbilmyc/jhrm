## Agent skills

### Issue tracker

GitHub Issues via the `gh` CLI. External PRs are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Five roles use these strings: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

---

## Output discipline (HARD GUARD)

**Do not use repeated short phrases as placeholder or scaffolding in any output.**

Examples of forbidden patterns (any of these has caused real damage in this repo):

- "X X X X X..." as a "fill in later" marker
- Doubled/tripled identical tokens in a row

If you need a placeholder, write an explicit bracketed marker like `[TODO: 修真 ladder 表]` or `<<placeholder>>`. Never use repeated tokens to mean "and so on".

Self-check before sending any reply over 10 lines: scan for "X X X" patterns, repeated short phrases, or sentences that don't make sense. If found, rewrite before sending.

See `~/.claude/memory/output-degeneration-repetition-loop.md` for the incident history.
