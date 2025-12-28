# CLAUDE.md - Grove File Browser

Desktop file browser application built with the Lean 4 graphics stack.

## Build & Run

```bash
./build.sh           # Build (sets LEAN_CC for Metal linking)
./run.sh             # Build and run
./test.sh            # Run tests
```

## Architecture

### Core Files
| File | Purpose |
|------|---------|
| `Grove/Core/Types.lean` | FileItem, Selection, SortOrder, FocusPanel |
| `Grove/Core/FileSystem.lean` | IO operations for reading directories |
| `Grove/State/AppState.lean` | NavigationHistory, complete AppState |
| `Grove/App.lean` | Msg type, update function, view rendering |
| `Grove/Main.lean` | Entry point, app loop |

### Dependencies
- **afferent**: Metal-based graphics and windowing
- **arbor**: Widget primitives and event handling
- **canopy**: High-level widget framework (being developed)
- **trellis**: CSS Flexbox/Grid layout
- **tincture**: Color utilities
- **crucible**: Test framework

## Key Types

```lean
structure FileItem where
  name : String
  path : System.FilePath
  isDirectory : Bool
  size : Option Nat
  extension : Option String

inductive Msg where
  | navigateTo (path : FilePath)
  | goBack | goForward | goUp
  | selectItem (index : Nat)
  | moveFocusUp | moveFocusDown
  ...

structure AppState where
  nav : NavigationHistory
  listItems : Array FileItem
  listSelection : Selection
  listFocusedIndex : Option Nat
  focusPanel : FocusPanel
```

## Keyboard Controls
- Arrow Up/Down: Navigate file list
- Enter: Open selected directory
- (More coming in Phase 2+)

## Development Phases

1. **Phase 1** (Current): Basic file list display
2. **Phase 2**: Keyboard navigation
3. **Phase 3**: Tree view sidebar
4. **Phase 4**: Panel focus and tab navigation
5. **Phase 5**: Multi-select
6. **Phase 6**: Navigation bar with history
7. **Phase 7**: Icons and visual polish
