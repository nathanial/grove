/-
  Grove Application State
  Complete state for the file browser application.
-/
import Grove.Core.Types

namespace Grove

/-- Navigation history for back/forward. -/
structure NavigationHistory where
  backStack : List System.FilePath := []
  forwardStack : List System.FilePath := []
  currentPath : System.FilePath
deriving Repr

namespace NavigationHistory

def init (startPath : System.FilePath) : NavigationHistory :=
  { currentPath := startPath }

def canGoBack (h : NavigationHistory) : Bool :=
  !h.backStack.isEmpty

def canGoForward (h : NavigationHistory) : Bool :=
  !h.forwardStack.isEmpty

def canGoUp (h : NavigationHistory) : Bool :=
  h.currentPath.parent.isSome && h.currentPath.parent != some h.currentPath

def goBack (h : NavigationHistory) : NavigationHistory :=
  match h.backStack with
  | [] => h
  | prev :: rest =>
    { backStack := rest
      forwardStack := h.currentPath :: h.forwardStack
      currentPath := prev }

def goForward (h : NavigationHistory) : NavigationHistory :=
  match h.forwardStack with
  | [] => h
  | next :: rest =>
    { backStack := h.currentPath :: h.backStack
      forwardStack := rest
      currentPath := next }

def goUp (h : NavigationHistory) : NavigationHistory :=
  match h.currentPath.parent with
  | none => h
  | some parent =>
    if parent == h.currentPath then h
    else
      { backStack := h.currentPath :: h.backStack
        forwardStack := []
        currentPath := parent }

def navigateTo (h : NavigationHistory) (path : System.FilePath) : NavigationHistory :=
  if path == h.currentPath then h
  else
    { backStack := h.currentPath :: h.backStack
      forwardStack := []
      currentPath := path }

end NavigationHistory

/-- Complete application state. -/
structure AppState where
  -- Navigation
  nav : NavigationHistory

  -- Tree sidebar
  tree : TreeState

  -- File list (main content)
  listItems : Array FileItem := #[]
  listSelection : Selection := {}
  listSortOrder : SortOrder := .kindAsc
  listScrollOffset : Float := 0.0
  listFocusedIndex : Option Nat := none

  -- UI state
  focusPanel : FocusPanel := .list
  sidebarWidth : Float := 200.0

  -- Status
  statusMessage : Option String := none
  isLoading : Bool := false
  errorMessage : Option String := none
deriving Repr

namespace AppState

/-- Create initial state starting at the given directory. -/
def init (startPath : System.FilePath) : AppState :=
  { nav := NavigationHistory.init startPath
    tree := TreeState.init startPath }

/-- Get the current directory path. -/
def currentPath (state : AppState) : System.FilePath :=
  state.nav.currentPath

/-- Get the number of items in the current directory. -/
def itemCount (state : AppState) : Nat :=
  state.listItems.size

/-- Get the number of selected items. -/
def selectionCount (state : AppState) : Nat :=
  state.listSelection.count

/-- Check if an item at the given index is selected. -/
def isSelected (state : AppState) (index : Nat) : Bool :=
  if h : index < state.listItems.size then
    state.listSelection.contains state.listItems[index].path
  else
    false

/-- Check if an item at the given index is focused. -/
def isFocused (state : AppState) (index : Nat) : Bool :=
  state.listFocusedIndex == some index

/-- Get the focused item, if any. -/
def focusedItem (state : AppState) : Option FileItem :=
  state.listFocusedIndex.bind fun i =>
    if h : i < state.listItems.size then some state.listItems[i] else none

/-- Move focus up in the list. -/
def moveFocusUp (state : AppState) : AppState :=
  match state.listFocusedIndex with
  | none => { state with listFocusedIndex := if state.listItems.isEmpty then none else some 0 }
  | some i => { state with listFocusedIndex := some (if i > 0 then i - 1 else 0) }

/-- Move focus down in the list. -/
def moveFocusDown (state : AppState) : AppState :=
  let maxIdx := if state.listItems.isEmpty then 0 else state.listItems.size - 1
  match state.listFocusedIndex with
  | none => { state with listFocusedIndex := if state.listItems.isEmpty then none else some 0 }
  | some i => { state with listFocusedIndex := some (min (i + 1) maxIdx) }

/-- Select the focused item. -/
def selectFocused (state : AppState) : AppState :=
  match state.listFocusedIndex with
  | none => state
  | some i =>
    if h : i < state.listItems.size then
      let path := state.listItems[i].path
      { state with listSelection := Selection.selectSingle path i }
    else
      state

/-- Move focus to first item. -/
def moveFocusToFirst (state : AppState) : AppState :=
  if state.listItems.isEmpty then state
  else { state with listFocusedIndex := some 0 }

/-- Move focus to last item. -/
def moveFocusToLast (state : AppState) : AppState :=
  if state.listItems.isEmpty then state
  else { state with listFocusedIndex := some (state.listItems.size - 1) }

/-- Move focus up by a page (given visible item count). -/
def moveFocusPageUp (state : AppState) (visibleCount : Nat) : AppState :=
  match state.listFocusedIndex with
  | none => state.moveFocusToFirst
  | some i =>
    let newIdx := if i < visibleCount then 0 else i - visibleCount
    { state with listFocusedIndex := some newIdx }

/-- Move focus down by a page (given visible item count). -/
def moveFocusPageDown (state : AppState) (visibleCount : Nat) : AppState :=
  let maxIdx := if state.listItems.isEmpty then 0 else state.listItems.size - 1
  match state.listFocusedIndex with
  | none => state.moveFocusToFirst
  | some i =>
    let newIdx := min (i + visibleCount) maxIdx
    { state with listFocusedIndex := some newIdx }

/-- Ensure the focused item is visible by adjusting scroll offset.
    Returns updated state with scroll offset adjusted if needed. -/
def ensureFocusVisible (state : AppState) (rowHeight : Float) (viewportHeight : Float) : AppState :=
  match state.listFocusedIndex with
  | none => state
  | some idx =>
    let itemTop := idx.toFloat * rowHeight
    let itemBottom := itemTop + rowHeight
    let scrollTop := state.listScrollOffset
    let scrollBottom := scrollTop + viewportHeight

    -- If item is above viewport, scroll up
    if itemTop < scrollTop then
      { state with listScrollOffset := itemTop }
    -- If item is below viewport, scroll down
    else if itemBottom > scrollBottom then
      { state with listScrollOffset := itemBottom - viewportHeight }
    else
      state

/-- Compute how many items are visible given row height and viewport height. -/
def visibleItemCount (rowHeight : Float) (viewportHeight : Float) : Nat :=
  max 1 (viewportHeight / rowHeight).toUInt64.toNat

end AppState

end Grove
