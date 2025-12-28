/-
  Grove Application Logic
  Message types, update function, and view rendering.
-/
import Afferent
import Afferent.App.UIRunner
import Arbor
import Grove.Core.Types
import Grove.Core.FileSystem
import Grove.State.AppState
import Grove.Widgets.TreeView
import Trellis
import Tincture

open Afferent
open Arbor
open Grove
open Tincture
open Trellis (EdgeInsets)

namespace Grove

/-- Application messages. -/
inductive Msg where
  -- Navigation
  | navigateTo (path : System.FilePath)
  | goBack
  | goForward
  | goUp
  | refreshDirectory
  | directoryLoaded (items : Array FileItem)
  | loadError (message : String)
  -- List interactions
  | selectItem (index : Nat)
  | activateItem (index : Nat)  -- Enter or double-click
  | moveFocusUp
  | moveFocusDown
  | moveFocusToFirst
  | moveFocusToLast
  | moveFocusPageUp (visibleCount : Nat)
  | moveFocusPageDown (visibleCount : Nat)
  | clearSelection
  -- Scroll
  | ensureFocusVisible (rowHeight : Float) (viewportHeight : Float)
  -- Tree sidebar
  | treeMoveFocusUp
  | treeMoveFocusDown
  | treeToggleExpand (index : Nat)
  | treeChildrenLoaded (parentIndex : Nat) (children : Array TreeNode)
  | treeSelectNode (index : Nat)
  -- Panel focus
  | focusNextPanel
  | focusPrevPanel
deriving Repr

/-- Update the application state based on a message. -/
def update (msg : Msg) (state : AppState) : AppState :=
  match msg with
  | .navigateTo path =>
    { state with
      nav := state.nav.navigateTo path
      listItems := #[]
      listFocusedIndex := none
      listSelection := .empty
      isLoading := true
      errorMessage := none }
  | .goBack =>
    if state.nav.canGoBack then
      let nav' := state.nav.goBack
      { state with
        nav := nav'
        listItems := #[]
        listFocusedIndex := none
        listSelection := .empty
        isLoading := true
        errorMessage := none }
    else
      state
  | .goForward =>
    if state.nav.canGoForward then
      let nav' := state.nav.goForward
      { state with
        nav := nav'
        listItems := #[]
        listFocusedIndex := none
        listSelection := .empty
        isLoading := true
        errorMessage := none }
    else
      state
  | .goUp =>
    if state.nav.canGoUp then
      let nav' := state.nav.goUp
      { state with
        nav := nav'
        listItems := #[]
        listFocusedIndex := none
        listSelection := .empty
        isLoading := true
        errorMessage := none }
    else
      state
  | .refreshDirectory =>
    { state with isLoading := true, errorMessage := none }
  | .directoryLoaded items =>
    let sortedItems := state.listSortOrder.sortItems items
    { state with
      listItems := sortedItems
      listFocusedIndex := if sortedItems.isEmpty then none else some 0
      isLoading := false
      errorMessage := none }
  | .loadError message =>
    { state with isLoading := false, errorMessage := some message }
  | .selectItem index =>
    if h : index < state.listItems.size then
      let path := state.listItems[index].path
      { state with
        listSelection := Selection.selectSingle path index
        listFocusedIndex := some index }
    else
      state
  | .activateItem index =>
    -- Activation handled in main loop (needs IO for directory navigation)
    state
  | .moveFocusUp =>
    let state' := state.moveFocusUp
    state'.selectFocused
  | .moveFocusDown =>
    let state' := state.moveFocusDown
    state'.selectFocused
  | .moveFocusToFirst =>
    let state' := state.moveFocusToFirst
    state'.selectFocused
  | .moveFocusToLast =>
    let state' := state.moveFocusToLast
    state'.selectFocused
  | .moveFocusPageUp visibleCount =>
    let state' := state.moveFocusPageUp visibleCount
    state'.selectFocused
  | .moveFocusPageDown visibleCount =>
    let state' := state.moveFocusPageDown visibleCount
    state'.selectFocused
  | .clearSelection =>
    { state with listSelection := .empty }
  | .ensureFocusVisible rowHeight viewportHeight =>
    state.ensureFocusVisible rowHeight viewportHeight
  | .treeMoveFocusUp =>
    { state with tree := state.tree.moveFocusUp }
  | .treeMoveFocusDown =>
    { state with tree := state.tree.moveFocusDown }
  | .treeToggleExpand index =>
    let (tree', _needsLoad) := state.tree.toggleExpand index
    { state with tree := tree' }
  | .treeChildrenLoaded parentIndex children =>
    { state with tree := state.tree.insertChildren parentIndex children }
  | .treeSelectNode index =>
    if h : index < state.tree.nodes.size then
      let node := state.tree.nodes[index]
      let tree' := { state.tree with focusedIndex := some index }
      -- Navigate to the selected directory
      { state with
        tree := tree'
        nav := state.nav.navigateTo node.path
        listItems := #[]
        listFocusedIndex := none
        listSelection := .empty
        isLoading := true
        errorMessage := none }
    else
      state
  | .focusNextPanel =>
    let nextPanel := match state.focusPanel with
      | .tree => .list
      | .list => .tree
      | .addressBar => .tree
    { state with focusPanel := nextPanel }
  | .focusPrevPanel =>
    let prevPanel := match state.focusPanel with
      | .tree => .list
      | .list => .tree
      | .addressBar => .list
    { state with focusPanel := prevPanel }

/-- UI sizing constants. -/
structure UISizes where
  baseWidth : Float := 800.0
  baseHeight : Float := 600.0
  rowHeight : Float := 28.0
  fontSize : Float := 14.0
  padding : Float := 12.0
  iconSize : Float := 20.0
  iconGap : Float := 8.0
  sidebarWidth : Float := 200.0
  dividerWidth : Float := 1.0
deriving Repr

def uiSizes : UISizes := {}

/-- Colors for the UI. -/
structure Theme where
  background : Color := Color.fromHex "#1e1e2e" |>.getD (Color.rgb 0.12 0.12 0.18)
  foreground : Color := Color.fromHex "#cdd6f4" |>.getD (Color.gray 0.85)
  subtle : Color := Color.fromHex "#6c7086" |>.getD (Color.gray 0.45)
  accent : Color := Color.fromHex "#89b4fa" |>.getD (Color.rgb 0.54 0.71 0.98)
  selection : Color := Color.fromHex "#313244" |>.getD (Color.rgb 0.19 0.20 0.27)
  focus : Color := Color.fromHex "#45475a" |>.getD (Color.rgb 0.27 0.28 0.35)
  folderColor : Color := Color.fromHex "#f9e2af" |>.getD (Color.rgb 0.98 0.89 0.69)
  fileColor : Color := Color.fromHex "#a6adc8" |>.getD (Color.gray 0.7)
  errorColor : Color := Color.fromHex "#f38ba8" |>.getD (Color.rgb 0.95 0.55 0.66)
  sidebarBg : Color := Color.fromHex "#181825" |>.getD (Color.rgb 0.09 0.09 0.15)
  divider : Color := Color.fromHex "#313244" |>.getD (Color.rgb 0.19 0.20 0.27)
deriving Repr

def theme : Theme := {}

/-- Widget IDs. -/
structure WidgetIds where
  root : Nat := 0
  header : Nat := 1
  pathText : Nat := 2
  sidebar : Nat := 5
  fileList : Nat := 10
  statusBar : Nat := 100
deriving Repr

def widgetIds : WidgetIds := {}

/-- Default font path. -/
def defaultFontPath : String := "/System/Library/Fonts/Monaco.ttf"

/-- Render a single file row. -/
def fileRow (fontId : FontId) (item : FileItem) (isSelected : Bool) (isFocused : Bool)
    (screenScale : Float) : WidgetBuilder := do
  let sizes := uiSizes
  let colors := theme
  let rowH := sizes.rowHeight * screenScale
  let padding := sizes.padding * screenScale
  let iconSize := sizes.iconSize * screenScale
  let iconGap := sizes.iconGap * screenScale

  let bgColor := if isSelected then some colors.selection
                 else if isFocused then some colors.focus
                 else none
  let textColor := if item.isDirectory then colors.folderColor else colors.foreground

  -- Simple icon: colored square
  let iconColor := if item.isDirectory then colors.folderColor else colors.fileColor

  row (gap := iconGap)
      (style := { backgroundColor := bgColor
                  padding := EdgeInsets.symmetric padding 0
                  minHeight := some rowH }) #[
    -- Icon (simple colored rectangle)
    box { backgroundColor := some iconColor
          minWidth := some iconSize
          minHeight := some iconSize },
    -- Filename
    text' item.displayName fontId textColor .left
  ]

/-- Render the file list. -/
def fileListView (fontId : FontId) (state : AppState) (screenScale : Float) : WidgetBuilder := do
  let sizes := uiSizes
  let colors := theme
  let padding := sizes.padding * screenScale

  if state.isLoading then
    column (gap := 0) (style := { padding := EdgeInsets.uniform padding }) #[
      text' "Loading..." fontId colors.subtle .center
    ]
  else if let some err := state.errorMessage then
    column (gap := 0) (style := { padding := EdgeInsets.uniform padding }) #[
      text' s!"Error: {err}" fontId colors.errorColor .center
    ]
  else if state.listItems.isEmpty then
    column (gap := 0) (style := { padding := EdgeInsets.uniform padding }) #[
      text' "Empty directory" fontId colors.subtle .center
    ]
  else
    let rowBuilders := state.listItems.mapIdx fun i item =>
      let isSelected := state.isSelected i
      let isFocused := state.isFocused i
      fileRow fontId item isSelected isFocused screenScale
    column (gap := 0) (style := { backgroundColor := some colors.background }) rowBuilders

/-- Render the header with current path. -/
def headerView (fontId : FontId) (state : AppState) (screenScale : Float) : WidgetBuilder := do
  let sizes := uiSizes
  let colors := theme
  let padding := sizes.padding * screenScale
  let pathStr := state.currentPath.toString

  row (gap := 0) (style := { backgroundColor := some (Color.gray 0.15)
                             padding := EdgeInsets.uniform padding }) #[
    text' pathStr fontId colors.foreground .left
  ]

/-- Render the status bar. -/
def statusBarView (fontId : FontId) (state : AppState) (screenScale : Float) : WidgetBuilder := do
  let sizes := uiSizes
  let colors := theme
  let padding := sizes.padding * screenScale

  let itemCount := state.itemCount
  let selCount := state.selectionCount
  let statusText := if selCount > 0 then
    s!"{selCount} of {itemCount} selected"
  else
    s!"{itemCount} items"

  row (gap := 0) (style := { backgroundColor := some (Color.gray 0.12)
                             padding := EdgeInsets.symmetric (padding / 2) (padding / 2) }) #[
    text' statusText fontId colors.subtle .left
  ]

/-- Render the sidebar with tree view. -/
def sidebarView (fontId : FontId) (state : AppState) (screenScale : Float) : WidgetBuilder := do
  let sizes := uiSizes
  let colors := theme
  let sidebarW := sizes.sidebarWidth * screenScale
  let dividerW := sizes.dividerWidth * screenScale

  let treeColors : Widgets.TreeViewColors :=
    { background := colors.sidebarBg
      foreground := colors.foreground
      subtle := colors.subtle
      focus := colors.focus
      folderColor := colors.folderColor }

  row (gap := 0) (style := {}) #[
    -- Tree view
    Widgets.treeView fontId state.tree screenScale treeColors sidebarW,
    -- Divider
    box { backgroundColor := some colors.divider
          minWidth := some dividerW }
  ]

/-- Render the main content area (header + file list + status bar). -/
def mainContentView (fontId : FontId) (state : AppState) (screenScale : Float) : WidgetBuilder := do
  let colors := theme
  column (gap := 0) (style := { backgroundColor := some colors.background }) #[
    headerView fontId state screenScale,
    fileListView fontId state screenScale,
    statusBarView fontId state screenScale
  ]

/-- Main view function. -/
def view (fontId : FontId) (screenScale : Float) (state : AppState) : UI Msg :=
  let colors := theme
  UIBuilder.buildFrom widgetIds.root do
    UIBuilder.lift do
      row (gap := 0) (style := { backgroundColor := some colors.background }) #[
        sidebarView fontId state screenScale,
        mainContentView fontId state screenScale
      ]

end Grove
