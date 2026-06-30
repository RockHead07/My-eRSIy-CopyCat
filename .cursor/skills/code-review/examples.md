# Example Reviews

## Example 1: Null reference risk

**Change:** Player picks up items via trigger collision.

```markdown
## Summary
Pickup logic works for the happy path but can null-ref when the item is destroyed mid-frame. Request changes before merge.

## Findings

| Severity | Location | Finding |
|----------|----------|---------|
| Critical | `Scripts/Player/PlayerInventory.cs:31` | `_heldItem` used after `Destroy(collision.gameObject)` — cache reference or reorder |
| Suggestion | `Scripts/Player/PlayerInventory.cs:24` | Use tag/layer check instead of `GetComponent` on every trigger enter |

## Test plan
- [ ] Pick up item, destroy item externally, verify no console errors
- [ ] Rapidly enter/exit trigger collider
```

## Example 2: Scope creep

**Change:** Bug fix in movement plus unrelated UI refactor.

```markdown
## Summary
Movement fix looks correct. UI refactor is unrelated — please split into a separate PR for easier review and rollback.

## Findings

| Severity | Location | Finding |
|----------|----------|---------|
| Suggestion | `Scripts/UI/ScoreDisplay.cs` (entire file) | Unrelated to movement fix; move to follow-up PR |
| Nice to have | `Scripts/Player/PlayerMovement.cs:58` | Extract `maxSpeed` to serialized field instead of literal `7.5f` |

## Test plan
- [ ] Verify player movement fix on slopes and while airborne
```

## Example 3: Clean approval

**Change:** Add ScriptableObject for level config.

```markdown
## Summary
Clean addition. Config is data-driven, follows folder layout, no issues found. Approve.

## Findings

| Severity | Location | Finding |
|----------|----------|---------|
| Nice to have | `Scripts/Settings/LevelConfig.cs:12` | Consider `[CreateAssetMenu]` with a project-specific menu path |

## Test plan
- [ ] Assign LevelConfig asset in inspector and play one full round
```
