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

/-- Custom app runner that handles IO-based messages. -/
def runGrove (canvas : Canvas) (fontReg : FontRegistry) (fontId : Arbor.FontId)
    (screenScale : Float) (initial : AppState) : IO Unit := do
  let mut c := canvas
  let mut model := initial
  let mut capture : Arbor.CaptureState := {}
  let mut prevLeftDown := false
  let mut needsLoad := true  -- Load initial directory

  while !(← c.shouldClose) do
    c.pollEvents

    -- Handle pending directory load
    if needsLoad || model.isLoading then
      let loadMsg ← loadDirectory model.currentPath
      model := update loadMsg model
      needsLoad := false

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
      let hasKey ← c.ctx.hasKeyPressed
      if hasKey then
        let keyCode ← c.ctx.getKeyCode
        c.ctx.clearKey
        -- Arrow keys: up=126, down=125, left=123, right=124, return=36
        match keyCode.toNat with
        | 126 => -- Up arrow
          model := update .moveFocusUp model
        | 125 => -- Down arrow
          model := update .moveFocusDown model
        | 36 => -- Return/Enter
          if let some idx := model.listFocusedIndex then
            if h : idx < model.listItems.size then
              let item := model.listItems[idx]
              if item.isDirectory then
                model := update (.navigateTo item.path) model
                needsLoad := true
        | _ => pure ()

      prevLeftDown := leftDown

      -- Process mouse events
      for ev in events do
        let (cap', msgs) := Arbor.dispatchEvent ev measureResult.widget layouts ui.handlers capture
        capture := cap'
        for _ in msgs do
          -- Handle click to select items
          match ev with
          | .mouseDown _ =>
            -- Simple row-based hit detection
            let rowH := uiSizes.rowHeight * screenScale
            let headerH := uiSizes.rowHeight * screenScale + uiSizes.padding * screenScale * 2
            if my > headerH then
              let relY := my - headerH
              let idx := (relY / rowH).toUInt64.toNat
              if idx < model.listItems.size then
                model := update (.selectItem idx) model
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
