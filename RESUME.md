# Resume guide (new session)

If you are reading this in a new session: this file describes the jhrm project state so you can continue work without re-deriving everything.

## Git state
- main branch at ac8915d
- 19 commits, 58/58 tests pass
- remote: git@github.com:bilbilmyc/jhrm.git

## Project structure
- lib/state/ — GameState + Player + World + IfState + ProceduralSeed + enums
- lib/engine/ — CultivationEngine, TribulationEngine, GoldFinger
- lib/content/ — ContentLoader (parses .md), IfScreen, if_template (minimal Mustache-lite)
- lib/save/ — SaveService (1-slot JSON, path_provider)
- lib/world/ — WorldView, MiniMap, Node, NodeRegistry (10 nodes)
- lib/ui/ — StatusBar, CharacterCreation, GoldFingerOverlay, ClosureTimer, BreakthroughView, theme
- content/mortal/ — 12 IF .md files (with broken goto chain, falls back to map)
- docs/decisions.md — 16 design decisions
- docs/adr/0001-0008.md — 8 ADRs
- docs/design/ — 13 system design docs (some DEFERRED to future)

## When starting a new session
1. Read AGENTS.md "Output discipline" guard
2. Read ~/.claude/memory/output-degeneration-repetition-loop.md for context
3. Do NOT reproduce, quote, or enumerate the offending 3-word pattern. If you need to refer to it, use "the phrase" or describe the attractor behavior abstractly
4. Run `git log --oneline | head -5` to see current state
5. Run `flutter test` — 58/58 should pass

## Remaining work (no new tests requested yet, so unblocked for polish)
1. Write tests for slice 12-15 UI widgets (StatusBar, BreakthroughView, ClosureTimer, GoldFingerOverlay) — none exist yet
2. Fix 49 flutter analyze warnings (notifyListeners protected, unused imports)
3. Add stub IF segments for the 28 broken gotos so chains resolve
4. Implement gold finger reset-save action (currently a noop stub)
5. Make GameState.forceSuccess auto-clear after one consumption
6. flutter build apk + flutter build ios verification
7. App icon + splash screen

## Do NOT do
- Do not write the offending 3-word pattern as a unit. Use only "the phrase" or its description.
- Do not recap a "no bug streak" in a loop. Say it once if at all.
- If the phrase accidentally appears in your output, stop, apologize, and edit the file to remove it.
