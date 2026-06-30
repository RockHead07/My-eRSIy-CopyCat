# Project Coding Standards

Standards for the My-eRSIy-CopyCat Unity project. Update this file as conventions emerge.

## Folder Layout

```
Assets/
├── Scripts/          # C# gameplay, UI, managers
├── Scenes/           # Unity scenes
├── Prefabs/          # Reusable GameObjects
├── Art/              # Sprites, models, materials
├── Audio/            # SFX and music
└── Settings/         # ScriptableObjects, config assets
```

Place new scripts under the folder that matches their domain (e.g. `Scripts/Player/`, `Scripts/UI/`).

## C# Conventions

| Item | Convention |
|------|------------|
| Classes / structs | `PascalCase` |
| Methods / properties | `PascalCase` |
| Private fields | `_camelCase` |
| Parameters / locals | `camelCase` |
| Constants | `PascalCase` or `UPPER_SNAKE` for static readonly |
| Interfaces | `I` prefix (`IInteractable`) |
| Script file name | Matches class name (`PlayerController.cs`) |

## Unity Patterns

**Component access**

```csharp
// Prefer cached references
[SerializeField] private Rigidbody _rigidbody;

private void Awake()
{
    _rigidbody ??= GetComponent<Rigidbody>();
}
```

**Lifecycle cleanup**

```csharp
private void OnEnable()  => InputManager.OnJump += HandleJump;
private void OnDisable() => InputManager.OnJump -= HandleJump;
```

**Avoid**

- `GameObject.Find` / `FindObjectOfType` in hot paths
- `SendMessage` / string-based dispatch
- Public fields for inspector exposure (use `[SerializeField] private`)
- Business logic in `MonoBehaviour.Update` when an event or state machine fits better

## Gameplay Guidelines (CopyCat)

- Player input and game rules should live in dedicated scripts, not scattered across UI components.
- Game state (score, round, win/lose) centralized in a manager; avoid duplicate state.
- Scene loads and transitions go through one loader/manager when possible.

## Commit Messages

Use conventional commits when practical:

```
feat(player): add jump cooldown
fix(ui): prevent HUD overlap on resize
refactor(audio): extract SFX manager from GameManager
```

Body: explain *why* the change was needed, not a line-by-line recap.

## Review Priorities

When time is limited, prioritize in this order:

1. Crashes, null refs, broken scene/prefab references
2. Gameplay correctness (rules, scoring, win/lose)
3. Performance in Update loops and allocations
4. Naming and file organization
5. Style nits
