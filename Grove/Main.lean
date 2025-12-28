/-
  Grove - Desktop File Browser
  Main entry point.
-/
import Afferent
import Afferent.App.UIRunner
import Afferent.FFI
import Arbor
import Grove.App

open Afferent
open Arbor
open Grove

/-- Load directory contents and return as a message. -/
def loadDirectory (path : System.FilePath) : IO Msg := do
  try
    let items ← readDirectorySorted path .kindAsc
    return .directoryLoaded items
  catch e =>
    return .loadError e.toString

/-- Load subdirectories for tree expansion. -/
def loadTreeChildren (path : System.FilePath) (parentDepth : Nat) : IO (Array TreeNode) := do
  try
    let entries ← System.FilePath.readDir path
    let mut dirs : Array TreeNode := #[]
    for entry in entries do
      let isDir ← entry.path.isDir
      if isDir then
        let name := entry.path.fileName.getD entry.path.toString
        dirs := dirs.push {
          path := entry.path
          name := name
          depth := parentDepth + 1
          isExpanded := false
          isLoaded := false
          hasChildren := true  -- Assume subdirs exist
        }
    -- Sort directories alphabetically
    return dirs.qsort fun a b => a.name.toLower < b.name.toLower
  catch _ =>
    return #[]

/-- Custom app runner that handles IO-based messages. -/
def runGrove (canvas : Canvas) (fontReg : FontRegistry) (fontId : Arbor.FontId)
    (screenScale : Float) (initial : AppState) : IO Unit := do
  let mut c := canvas
  let mut model := initial
  let mut capture : Arbor.CaptureState := {}
  let mut prevLeftDown := false
  let mut needsLoad := true  -- Load initial directory
  let mut needsTreeLoad : Option Nat := none  -- Index of tree node needing children loaded

  while !(← c.shouldClose) do
    c.pollEvents

    -- Handle pending directory load
    if needsLoad || model.isLoading then
      let loadMsg ← loadDirectory model.currentPath
      model := update loadMsg model
      needsLoad := false

    -- Handle pending tree children load
    if let some parentIdx := needsTreeLoad then
      if h : parentIdx < model.tree.nodes.size then
        let parent := model.tree.nodes[parentIdx]
        let children ← loadTreeChildren parent.path parent.depth
        model := update (.treeChildrenLoaded parentIdx children) model
      needsTreeLoad := none

    let ok ← c.beginFrame theme.background
    if ok then
      let ui := view fontId screenScale model
      let (screenW, screenH) ← c.ctx.getCurrentSize

      -- Layout the UI
      let measureResult ← Afferent.runWithFonts fontReg (Arbor.measureWidget ui.widget screenW screenH)
      let layouts := Trellis.layout measureResult.node screenW screenH

      -- Handle mouse events
      let (mx, my) ← c.ctx.window.getMousePos
      let buttons ← c.ctx.window.getMouseButtons
      let modsBits ← c.ctx.window.getModifiers
      let leftDown := (buttons &&& (1 : UInt8)) != (0 : UInt8)
      let mods := Arbor.Modifiers.fromBitmask modsBits

      let mut events : Array Arbor.Event := #[]
      if leftDown && !prevLeftDown then
        events := events.push (.mouseDown (Arbor.MouseEvent.mk' mx my .left mods))
      if leftDown then
        events := events.push (.mouseMove (Arbor.MouseEvent.mk' mx my .left mods))
      if !leftDown && prevLeftDown then
        events := events.push (.mouseUp (Arbor.MouseEvent.mk' mx my .left mods))

      -- Handle keyboard events
      -- Compute viewport info for scroll and page navigation
      let rowH := uiSizes.rowHeight * screenScale
      let sidebarW := uiSizes.sidebarWidth * screenScale
      let headerH := uiSizes.rowHeight * screenScale + uiSizes.padding * screenScale * 2
      let statusH := uiSizes.rowHeight * screenScale
      let viewportH := screenH - headerH - statusH
      let visibleCount := AppState.visibleItemCount rowH viewportH

      let hasKey ← c.ctx.hasKeyPressed
      if hasKey then
        let keyCode ← c.ctx.getKeyCode
        c.ctx.clearKey
        -- macOS key codes:
        -- Arrow: up=126, down=125, left=123, right=124
        -- Return=36, Escape=53, Backspace=51, Tab=48
        -- Page Up=116, Page Down=121, Home=115, End=119
        match keyCode.toNat with
        | 48 => -- Tab - switch panels
          model := update .focusNextPanel model
        | _ =>
          -- Handle keys based on focused panel
          match model.focusPanel with
          | .tree =>
            match keyCode.toNat with
            | 126 => -- Up arrow
              model := update .treeMoveFocusUp model
            | 125 => -- Down arrow
              model := update .treeMoveFocusDown model
            | 36 | 124 => -- Return/Enter or Right arrow - expand/navigate
              if let some idx := model.tree.focusedIndex then
                if h : idx < model.tree.nodes.size then
                  let node := model.tree.nodes[idx]
                  if !node.isExpanded then
                    -- Expand the node
                    let (tree', needsChildLoad) := model.tree.toggleExpand idx
                    model := { model with tree := tree' }
                    if needsChildLoad then
                      needsTreeLoad := some idx
                  -- Navigate to this directory
                  model := update (.treeSelectNode idx) model
                  needsLoad := true
            | 123 => -- Left arrow - collapse or go to parent
              if let some idx := model.tree.focusedIndex then
                if h : idx < model.tree.nodes.size then
                  let node := model.tree.nodes[idx]
                  if node.isExpanded then
                    let (tree', _) := model.tree.toggleExpand idx
                    model := { model with tree := tree' }
                  else if node.depth > 0 then
                    -- Move to parent node
                    -- Find parent by looking backwards for a node with depth - 1
                    let mut parentIdx := idx
                    for i in [:idx] do
                      let revI := idx - 1 - i
                      if revI < model.tree.nodes.size then
                        let n := model.tree.nodes[revI]!
                        if n.depth < node.depth then
                          parentIdx := revI
                          break
                    if parentIdx != idx then
                      model := { model with tree := { model.tree with focusedIndex := some parentIdx } }
            | _ => pure ()
          | .list =>
            match keyCode.toNat with
            | 126 => -- Up arrow
              model := update .moveFocusUp model
              model := update (.ensureFocusVisible rowH viewportH) model
            | 125 => -- Down arrow
              model := update .moveFocusDown model
              model := update (.ensureFocusVisible rowH viewportH) model
            | 116 => -- Page Up
              model := update (.moveFocusPageUp visibleCount) model
              model := update (.ensureFocusVisible rowH viewportH) model
            | 121 => -- Page Down
              model := update (.moveFocusPageDown visibleCount) model
              model := update (.ensureFocusVisible rowH viewportH) model
            | 115 => -- Home
              model := update .moveFocusToFirst model
              model := update (.ensureFocusVisible rowH viewportH) model
            | 119 => -- End
              model := update .moveFocusToLast model
              model := update (.ensureFocusVisible rowH viewportH) model
            | 36 => -- Return/Enter - open directory
              if let some idx := model.listFocusedIndex then
                if h : idx < model.listItems.size then
                  let item := model.listItems[idx]
                  if item.isDirectory then
                    model := update (.navigateTo item.path) model
                    needsLoad := true
            | 53 => -- Escape - go up a directory
              if model.nav.canGoUp then
                model := update .goUp model
                needsLoad := true
            | 51 => -- Backspace - go back in history
              if model.nav.canGoBack then
                model := update .goBack model
                needsLoad := true
            | 123 => -- Left arrow - go up a directory
              if model.nav.canGoUp then
                model := update .goUp model
                needsLoad := true
            | 124 => -- Right arrow - open directory (same as Enter)
              if let some idx := model.listFocusedIndex then
                if h : idx < model.listItems.size then
                  let item := model.listItems[idx]
                  if item.isDirectory then
                    model := update (.navigateTo item.path) model
                    needsLoad := true
            | _ => pure ()
          | .addressBar => pure ()

      prevLeftDown := leftDown

      -- Process mouse events
      for ev in events do
        let (cap', msgs) := Arbor.dispatchEvent ev measureResult.widget layouts ui.handlers capture
        capture := cap'
        for _ in msgs do
          -- Handle click to select items
          match ev with
          | .mouseDown _ =>
            let treeRowH := 24.0 * screenScale
            if mx < sidebarW then
              -- Click in sidebar (tree view)
              let idx := (my / treeRowH).toUInt64.toNat
              if idx < model.tree.nodes.size then
                -- Focus tree panel and select node
                model := { model with focusPanel := .tree }
                let tree' := { model.tree with focusedIndex := some idx }
                model := { model with tree := tree' }
                -- Navigate to this directory
                model := update (.treeSelectNode idx) model
                needsLoad := true
            else if my > headerH && my < (screenH - statusH) then
              -- Click in file list
              model := { model with focusPanel := .list }
              let relY := my - headerH + model.listScrollOffset
              let idx := (relY / rowH).toUInt64.toNat
              if idx < model.listItems.size then
                model := update (.selectItem idx) model
                model := update (.ensureFocusVisible rowH viewportH) model
          | _ => pure ()

      -- Render
      c ← CanvasM.run' c do
        Afferent.Widget.renderArborWidget fontReg ui.widget screenW screenH
      c ← c.endFrame

def main : IO Unit := do
  IO.println "Grove - File Browser"

  -- Get starting directory (current working directory)
  let startPath ← getCurrentDirectory
  IO.println s!"Starting at: {startPath}"

  let screenScale ← Afferent.FFI.getScreenScale
  let sizes := uiSizes
  let physWidth := (sizes.baseWidth * screenScale).toUInt32
  let physHeight := (sizes.baseHeight * screenScale).toUInt32

  let canvas ← Canvas.create physWidth physHeight "Grove - File Browser"

  let fontSize := (sizes.fontSize * screenScale).toUInt32
  let font ← Font.load defaultFontPath fontSize
  let (fontReg, fontId) := FontRegistry.empty.register font "main"

  let initial := AppState.init startPath

  runGrove canvas fontReg fontId screenScale initial

  IO.println "Done!"
