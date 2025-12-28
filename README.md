# Grove

A desktop file browser built with Lean 4, using the afferent/arbor/canopy/trellis graphics stack.

## Overview

Grove is a native macOS file browser application that serves as a testbed for developing the Lean 4 graphics libraries. It exercises:

- **afferent** - Metal-based graphics rendering
- **arbor** - Renderer-agnostic widget library
- **canopy** - Desktop widget framework (being developed)
- **trellis** - CSS Flexbox/Grid layout engine
- **tincture** - Color utilities

## Building

Requires:
- Lean 4.26.0
- macOS with Metal support
- Homebrew dependencies: `freetype`, `gmp`

```bash
./build.sh           # Build the project
./run.sh             # Build and run
./test.sh            # Run tests
```

## Usage

```bash
./run.sh             # Opens file browser in current directory
```

### Keyboard Controls

| Key | Action |
|-----|--------|
| Up/Down Arrow | Navigate file list |
| Enter | Open selected directory |

More controls coming in future phases.

## Project Structure

```
grove/
├── Grove/
│   ├── Core/
│   │   ├── Types.lean       # FileItem, Selection, SortOrder
│   │   └── FileSystem.lean  # Directory reading utilities
│   ├── State/
│   │   └── AppState.lean    # Application state management
│   ├── App.lean             # UI rendering and message handling
│   └── Main.lean            # Entry point
└── GroveTests/
    └── Main.lean            # Test suite
```

## Development Phases

- [x] **Phase 1**: Basic file list display with keyboard navigation
- [ ] **Phase 2**: Enhanced keyboard navigation
- [ ] **Phase 3**: Tree view sidebar
- [ ] **Phase 4**: Panel focus (Tab between tree/list)
- [ ] **Phase 5**: Multi-select (Shift/Cmd-click)
- [ ] **Phase 6**: Navigation bar with history
- [ ] **Phase 7**: File type icons
- [ ] **Phase 8**: Text input (address bar editing)
- [ ] **Phase 9**: File operations (create, rename, delete)

## License

MIT License - see [LICENSE](LICENSE)
