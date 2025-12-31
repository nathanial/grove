# Grove Roadmap

Desktop file browser for Lean 4 using the afferent/arbor/canopy/trellis graphics stack.

---

## Feature Proposals

### [Priority: High] Double-Click to Open Files/Directories
**Description:** Implement double-click detection to open directories and launch files with their default applications.
**Rationale:** Double-click is the standard interaction pattern for file browsers. Currently only Enter key opens directories.
**Affected Files:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean`
**Estimated Effort:** Medium
**Dependencies:** May require tracking click timing in the event loop

### [Priority: High] Show/Hide Hidden Files Toggle
**Description:** Add a keyboard shortcut (Cmd+Shift+Period) or menu option to toggle visibility of hidden files (dotfiles).
**Rationale:** The `FileItem.isHidden` function already exists but is not used. Users frequently need to access hidden files.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/State/AppState.lean` - Add `showHidden : Bool` field
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add `toggleShowHidden` message and filter logic
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean` - Add keyboard shortcut handler
**Estimated Effort:** Small
**Dependencies:** None

### [Priority: High] File Size Display in List View
**Description:** Display file sizes in a column next to filenames, with human-readable formatting (KB, MB, GB).
**Rationale:** File size is already captured in `FileItem.size` but not displayed. Essential for a usable file browser.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/Types.lean` - Add size formatting utilities
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Update `fileRow` to show size column
**Estimated Effort:** Small
**Dependencies:** None

### [Priority: High] Modified Time Display
**Description:** Show file modification dates in the list view. Add sorting by date.
**Rationale:** The `modifiedTime` field exists in `FileItem` but is never populated or displayed.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/FileSystem.lean` - Populate `modifiedTime` from file metadata
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/Types.lean` - Add date formatting utilities
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add date column to display
**Estimated Effort:** Medium
**Dependencies:** May need to add time formatting utilities or use chronos library

### [Priority: High] Scroll Support for File List
**Description:** Implement mouse wheel scrolling and scrollbar for the file list.
**Rationale:** `listScrollOffset` exists in AppState but scroll events are not handled. Lists with many files are unusable without scrolling.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean` - Handle scroll wheel events from window
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Apply scroll offset in rendering
**Estimated Effort:** Medium
**Dependencies:** Check if afferent/arbor expose scroll wheel events

### [Priority: Medium] Sort Order Selection UI
**Description:** Add column headers that can be clicked to change sort order, or a dropdown menu.
**Rationale:** `SortOrder` enum has 8 options but no UI to change sorting. Only `kindAsc` is ever used.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add clickable headers or sort menu
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/State/AppState.lean` - Already has `listSortOrder` field
**Estimated Effort:** Medium
**Dependencies:** None

### [Priority: Medium] Multi-Select with Shift and Cmd
**Description:** Support range selection (Shift+Click) and additive selection (Cmd+Click).
**Rationale:** `Selection.toggle` and `Selection.extendTo` methods exist but are not wired to keyboard modifiers.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean` - Check modifier keys on click and call appropriate Selection method
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add messages for multi-select operations
**Estimated Effort:** Medium
**Dependencies:** None (modifiers already available via `getModifiers`)

### [Priority: Medium] Address Bar Editing
**Description:** Make the path header editable. Allow typing a path and pressing Enter to navigate.
**Rationale:** `FocusPanel.addressBar` exists but is never used. Direct path entry is a common workflow.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/State/AppState.lean` - Add `addressBarText : String` field
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add text input handling, `submitAddressBar` message
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean` - Handle text input events for address bar
**Estimated Effort:** Large
**Dependencies:** Text input widget support from arbor/canopy

### [Priority: Medium] File Type Icons
**Description:** Display appropriate icons for different file types instead of generic colored squares.
**Rationale:** Icons improve scannability. Currently folders show a yellow square and files show a gray square.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Replace box with icon rendering
- Add icon assets or SVG rendering
**Estimated Effort:** Large
**Dependencies:** Icon asset loading or SVG rendering in afferent

### [Priority: Medium] Keyboard Shortcut for Refresh
**Description:** Add Cmd+R or F5 to refresh the current directory.
**Rationale:** `refreshDirectory` message exists but has no keyboard binding.
**Affected Files:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean`
**Estimated Effort:** Small
**Dependencies:** None

### [Priority: Medium] Quick Look / Preview Panel
**Description:** Add a preview panel (like Finder's Quick Look) for selected files.
**Rationale:** Previewing files without opening them is a key productivity feature.
**Affected Files:**
- New file: `Grove/Widgets/PreviewPanel.lean`
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add preview panel to layout
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/State/AppState.lean` - Add `showPreview : Bool` field
**Estimated Effort:** Large
**Dependencies:** Image rendering for image previews, text rendering for text files

### [Priority: Low] Breadcrumb Navigation
**Description:** Replace or supplement the address bar with clickable breadcrumbs.
**Rationale:** Breadcrumbs allow quick navigation to parent directories.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add breadcrumb view in header
**Estimated Effort:** Medium
**Dependencies:** None

### [Priority: Low] Favorites/Bookmarks Sidebar
**Description:** Add a favorites section in the tree sidebar for quick access to common directories.
**Rationale:** Common pattern in file browsers (Desktop, Documents, Downloads, etc.)
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/Types.lean` - Add Favorite type
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/State/AppState.lean` - Add favorites list
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Widgets/TreeView.lean` - Render favorites section
**Estimated Effort:** Medium
**Dependencies:** None

### [Priority: Low] Drag and Drop
**Description:** Support drag and drop for moving/copying files.
**Rationale:** Standard interaction pattern for file management.
**Affected Files:** Multiple files; requires drag state management
**Estimated Effort:** Large
**Dependencies:** Drag-drop event support in afferent

### [Priority: Low] Context Menu (Right-Click)
**Description:** Show context menu with file operations on right-click.
**Rationale:** Standard way to access file operations.
**Affected Files:**
- New widget for context menu
- Right-click event handling in Main.lean
**Estimated Effort:** Large
**Dependencies:** Menu widget in arbor/canopy

### [Priority: Low] Search/Filter
**Description:** Add a search box to filter files in the current directory.
**Rationale:** Useful for directories with many files.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/State/AppState.lean` - Add `searchQuery : String` field
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add search box and filter logic
**Estimated Effort:** Medium
**Dependencies:** Text input widget

### [Priority: Low] File Operations
**Description:** Implement create, rename, and delete file operations.
**Rationale:** Core file management functionality missing.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/FileSystem.lean` - Add file operation functions
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - Add confirmation dialogs
**Estimated Effort:** Large
**Dependencies:** Dialog widgets, confirmation prompts

### [Priority: Low] Command-Line Arguments
**Description:** Accept a starting directory as command-line argument.
**Rationale:** Common pattern; allows opening grove in specific directory.
**Affected Files:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean`
**Estimated Effort:** Small
**Dependencies:** None

---

## Code Improvements

### [Priority: High] Extract Event Handling from Main Loop
**Current State:** The `runGrove` function in `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean` is ~220 lines long with inline keyboard and mouse handling.
**Proposed Change:** Extract keyboard handling into a separate function `handleKeyEvent` and mouse handling into `handleMouseEvent`. Consider using a more structured event dispatch pattern.
**Benefits:** Improved readability, easier to add new key bindings, reduced cognitive load.
**Affected Files:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean`
**Estimated Effort:** Medium

### [Priority: High] Implement Proper Path Normalization
**Current State:** `normalizePath` in `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/FileSystem.lean` (line 50-53) just returns the path unchanged with a TODO comment.
**Proposed Change:** Implement proper path normalization to resolve `.` and `..` components and potentially symlinks.
**Benefits:** Correct behavior when navigating using relative paths.
**Affected Files:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/FileSystem.lean`
**Estimated Effort:** Small

### [Priority: Medium] Make Theme Configurable
**Current State:** Theme colors are defined as constants in `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` (lines 199-212).
**Proposed Change:** Move theme definition to a configuration file (TOML using totem library) or allow runtime theme switching.
**Benefits:** User customization, easier testing of different color schemes.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean`
- New file: `Grove/Theme.lean`
**Estimated Effort:** Medium
**Dependencies:** Could use totem library for TOML config

### [Priority: Medium] Use Collimator Optics for Nested State Updates
**Current State:** State updates in `update` function use verbose record update syntax with nested `{ state with tree := { state.tree with ... } }` patterns.
**Proposed Change:** Define lenses using collimator library for common nested paths (e.g., `tree.focusedIndex`, `nav.currentPath`).
**Benefits:** Cleaner state manipulation, less boilerplate, follows workspace patterns (cairn uses collimator).
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean`
- New file: `Grove/Optics.lean`
- Update `lakefile.lean` to require collimator
**Estimated Effort:** Medium

### [Priority: Medium] Use Array Instead of List for Navigation Stacks
**Current State:** `NavigationHistory` uses `List System.FilePath` for `backStack` and `forwardStack`.
**Proposed Change:** Use `Array System.FilePath` for better random access and performance characteristics.
**Benefits:** Consistent with rest of codebase, better performance for stack operations.
**Affected Files:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/State/AppState.lean`
**Estimated Effort:** Small

### [Priority: Medium] Add Error Recovery to Directory Loading
**Current State:** Directory loading errors are displayed but the user has no way to retry or navigate away.
**Proposed Change:** Add retry logic, allow navigation to parent on error, preserve previous listing on refresh failure.
**Benefits:** Better user experience when encountering permission errors or disconnected drives.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean`
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean`
**Estimated Effort:** Small

### [Priority: Low] Lazy Loading for Tree View
**Current State:** Tree children are loaded synchronously when expanding a node.
**Proposed Change:** Load children asynchronously to avoid UI blocking on slow filesystems.
**Benefits:** Responsive UI when expanding directories on network drives or slow media.
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean`
- May need async IO patterns
**Estimated Effort:** Medium
**Dependencies:** Async IO support

### [Priority: Low] Use Efficient Data Structure for Selection
**Current State:** `Selection.items` is an `Array System.FilePath`, and `contains` checks use linear scan.
**Proposed Change:** Use `HashSet` or `RBMap` for O(1) or O(log n) contains checks.
**Benefits:** Better performance with large selections.
**Affected Files:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/Types.lean`
**Estimated Effort:** Small
**Dependencies:** batteries or std library HashSet

### [Priority: Low] Virtualized List Rendering
**Current State:** All items are rendered even if off-screen.
**Proposed Change:** Only render visible items based on scroll offset and viewport height.
**Benefits:** Better performance with large directories (thousands of files).
**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - `fileListView` function
**Estimated Effort:** Medium

---

## Code Cleanup

### [Priority: High] Remove Unused `activateItem` Message
**Issue:** The `Msg.activateItem` case in the update function (line 122-124) just returns state unchanged with a comment saying "Activation handled in main loop."
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean`, lines 35, 122-124
**Action Required:** Either implement the message properly or remove it and handle activation purely in Main.lean.
**Estimated Effort:** Small

### [Priority: Medium] Add Missing Tests for AppState Functions
**Issue:** Several `AppState` functions lack test coverage: `moveFocusPageUp`, `moveFocusPageDown`, `ensureFocusVisible`, `visibleItemCount`.
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/GroveTests/Main.lean`
**Action Required:** Add unit tests for pagination and scroll management functions.
**Estimated Effort:** Small

### [Priority: Medium] Add Tests for TreeState Operations
**Issue:** `TreeState` has complex operations (`toggleExpand`, `insertChildren`) with no test coverage.
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/GroveTests/Main.lean`
**Action Required:** Add tests for tree expansion, collapse, and child insertion.
**Estimated Effort:** Medium

### [Priority: Medium] Document TreeState Flat Array Design
**Issue:** The `TreeState` uses a flat array with depth tracking, which is non-obvious. The brief comment doesn't explain the design rationale.
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Core/Types.lean`, lines 147-182
**Action Required:** Add detailed doc comment explaining the flat representation design, trade-offs, and invariants.
**Estimated Effort:** Small

### [Priority: Medium] Remove Hardcoded Screen Scale Calculations
**Issue:** Several places compute scaled values inline with `* screenScale` scattered throughout the code.
**Location:**
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean` - lines 236-239, 264-265, 290-302, 320-321
- `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Widgets/TreeView.lean` - lines 39-42
**Action Required:** Add helper functions like `UISizes.scaled(screenScale)` that returns pre-computed scaled values.
**Estimated Effort:** Small

### [Priority: Low] Consolidate Widget ID Management
**Issue:** `WidgetIds` structure exists but actual widget rendering doesn't use these IDs consistently.
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/App.lean`, lines 216-226
**Action Required:** Either use the IDs properly or remove the unused structure.
**Estimated Effort:** Small

### [Priority: Low] Fix Potential Index Bounds Issue in Tree Navigation
**Issue:** In `runGrove`, when finding parent node (lines 148-157), the loop doesn't handle the case where no valid parent is found gracefully.
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/Grove/Main.lean`, lines 148-157
**Action Required:** Add explicit handling for root node case, add comments clarifying invariants.
**Estimated Effort:** Small

### [Priority: Low] Remove Unused Canopy Dependency
**Issue:** `canopy` is listed as a dependency in `lakefile.lean` but is not imported anywhere in the codebase.
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/lakefile.lean`, line 12
**Action Required:** Either remove the dependency or start using canopy widgets.
**Estimated Effort:** Small

### [Priority: Low] Add Build Status Badges to README
**Issue:** README lacks build status, test status, or other metadata badges.
**Location:** `/Users/Shared/Projects/lean-workspace/graphics/grove/README.md`
**Action Required:** Add appropriate badges if CI is configured.
**Estimated Effort:** Small

---

## Architecture Considerations

### Separation of Concerns
The current structure is reasonable but could benefit from further separation:
- **Move event handling** out of Main.lean into a dedicated Events module
- **Separate view functions** into widget-specific files (HeaderView, StatusBarView, etc.)
- **Create a Commands module** for file operations

### Dependency Management
Current dependencies are appropriate. Consider:
- Adding **chronos** for proper time formatting of modification dates
- Using **collimator** for state lenses (as suggested above)
- Eventually using more of **canopy** for higher-level widgets

### Integration Opportunities
- **raster**: Could be used for image thumbnails/previews
- **totem**: Could load user preferences/theme configuration
- **chronos**: For proper date/time formatting of file metadata

---

## Development Phase Alignment

The existing README outlines development phases. Current implementation status:

| Phase | Description | Status | Notes |
|-------|-------------|--------|-------|
| 1 | Basic file list display | Complete | Keyboard navigation works |
| 2 | Enhanced keyboard navigation | Partial | Page up/down, Home/End implemented |
| 3 | Tree view sidebar | Complete | Expansion and navigation working |
| 4 | Panel focus (Tab) | Complete | Tab switches between tree/list |
| 5 | Multi-select | Partial | Logic exists, not wired to modifiers |
| 6 | Navigation bar with history | Partial | History works, editing not implemented |
| 7 | File type icons | Not started | - |
| 8 | Text input | Not started | Needed for address bar editing |
| 9 | File operations | Not started | - |

Recommended next priorities based on this analysis:
1. Wire multi-select to Shift/Cmd modifiers (complete Phase 5)
2. Add scroll support (blocking issue for large directories)
3. Display file sizes and dates (quick wins, high value)
4. Show/hide hidden files toggle

