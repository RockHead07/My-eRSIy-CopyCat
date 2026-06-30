---
name: code-review
description: Reviews code for correctness, Unity/C# best practices, and maintainability following project standards. Use when reviewing pull requests, examining diffs, giving feedback on changes, or when the user asks for a code review.
---

# Code Review

## Quick Start

1. Understand the change goal (feature, fix, refactor) before judging implementation.
2. Read the diff in context — open surrounding code when intent is unclear.
3. Apply the checklist below; add Unity-specific checks for `.cs`, scenes, and prefabs.
4. Report findings using the feedback format. Do not fix issues unless asked.

## Review Workflow

```
Task Progress:
- [ ] Step 1: Identify change scope (files, feature area, risk level)
- [ ] Step 2: Verify correctness and edge cases
- [ ] Step 3: Check project conventions (see STANDARDS.md)
- [ ] Step 4: Assess maintainability and scope creep
- [ ] Step 5: Write structured feedback
```

**Step 1 — Scope**

- What behavior changed? What could break?
- Are unrelated files modified? Flag scope creep.

**Step 2 — Correctness**

- Logic handles nulls, empty collections, and disabled/inactive objects.
- State changes are consistent (game state, scene transitions, player input).
- No race conditions between `Update`, coroutines, and async callbacks.

**Step 3 — Conventions**

- Match existing naming, folder layout, and patterns in the repo.
- Prefer minimal diffs; flag drive-by refactors mixed into feature work.
- For Unity specifics, read [STANDARDS.md](STANDARDS.md).

**Step 4 — Maintainability**

- Single responsibility per class/method.
- Serialized fields use `[SerializeField]` over public fields unless justified.
- Magic numbers/strings extracted to constants or ScriptableObjects.

**Step 5 — Feedback**

Use severity labels and cite locations as `file:line`.

## Checklist

### All changes

- [ ] Logic is correct; edge cases handled
- [ ] No dead code, commented-out blocks, or debug logs left behind
- [ ] Error paths are handled (not silently swallowed)
- [ ] Change scope matches the stated goal
- [ ] Names are clear and consistent with the codebase

### Unity / C# (when applicable)

- [ ] No heavy work in `Update`/`FixedUpdate` without justification
- [ ] `GetComponent`/`Find` not called every frame; results cached
- [ ] Coroutines stopped on disable/destroy; event subscriptions unsubscribed
- [ ] `[SerializeField]` used; public fields only when required by Unity API
- [ ] Prefab/scene references assigned or documented; no broken links
- [ ] New scripts compile; no missing `using` or namespace conflicts

### PR hygiene

- [ ] Commit messages describe *why*, not just *what*
- [ ] No secrets, API keys, or `.env` files committed
- [ ] Large assets (textures, audio) are intentional and reasonably sized

## Feedback Format

```markdown
## Summary
[1–2 sentences: overall assessment and merge recommendation]

## Findings

| Severity | Location | Finding |
|----------|----------|---------|
| Critical | `Scripts/Player.cs:42` | [Must fix before merge] |
| Suggestion | `Scripts/GameManager.cs:18` | [Consider improving] |
| Nice to have | `Scripts/UI/HUD.cs:7` | [Optional enhancement] |

## Test plan
- [ ] [Specific manual or automated test the author should run]
```

Severity definitions:

- **Critical** — Bug, crash, data loss, security issue, or broken build. Block merge.
- **Suggestion** — Correct but improvable (performance, clarity, convention).
- **Nice to have** — Optional polish; safe to defer.

## When to Use Bugbot

For automated bug-hunting on local diffs, use the `review-bugbot` skill instead of duplicating that workflow here. This skill focuses on project standards and human-style review quality.

## Additional Resources

- Unity/C# standards: [STANDARDS.md](STANDARDS.md)
- Example reviews: [examples.md](examples.md)
