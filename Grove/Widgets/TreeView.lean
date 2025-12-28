/-
  Grove TreeView Widget
  Renders the directory tree sidebar.
-/
import Arbor
import Grove.Core.Types
import Tincture
import Trellis

open Arbor
open Grove
open Tincture
open Trellis (EdgeInsets)

namespace Grove.Widgets

/-- Colors for the tree view. -/
structure TreeViewColors where
  background : Color
  foreground : Color
  subtle : Color
  focus : Color
  folderColor : Color
deriving Repr

/-- Render expansion indicator (▶ or ▼). -/
def expansionIndicator (fontId : FontId) (isExpanded : Bool) (hasChildren : Bool)
    (color : Color) : WidgetBuilder := do
  if hasChildren then
    let indicator := if isExpanded then "▼" else "▶"
    text' indicator fontId color .left
  else
    -- Empty space for alignment
    text' " " fontId color .left

/-- Render a single tree node row. -/
def treeNodeRow (fontId : FontId) (node : TreeNode) (isFocused : Bool)
    (screenScale : Float) (colors : TreeViewColors) : WidgetBuilder := do
  let rowH := 24.0 * screenScale
  let padding := 8.0 * screenScale
  let indentSize := 16.0 * screenScale
  let iconGap := 6.0 * screenScale

  let bgColor := if isFocused then some colors.focus else none
  let textColor := colors.foreground
  let indentPadding := node.depth.toFloat * indentSize

  row (gap := iconGap)
      (style := { backgroundColor := bgColor
                  padding := EdgeInsets.mk padding 0 padding indentPadding
                  minHeight := some rowH }) #[
    -- Expansion indicator
    expansionIndicator fontId node.isExpanded node.hasChildren colors.subtle,
    -- Folder icon (simple colored square)
    box { backgroundColor := some colors.folderColor
          minWidth := some (14.0 * screenScale)
          minHeight := some (14.0 * screenScale) },
    -- Directory name
    text' node.name fontId textColor .left
  ]

/-- Render the complete tree view. -/
def treeView (fontId : FontId) (tree : TreeState) (screenScale : Float)
    (colors : TreeViewColors) (width : Float) : WidgetBuilder := do
  if tree.nodes.isEmpty then
    column (gap := 0) (style := { backgroundColor := some colors.background
                                  minWidth := some width }) #[
      text' "No directories" fontId colors.subtle .center
    ]
  else
    let rowBuilders := tree.nodes.mapIdx fun i node =>
      let focused := tree.isFocused i
      treeNodeRow fontId node focused screenScale colors
    column (gap := 0) (style := { backgroundColor := some colors.background
                                  minWidth := some width }) rowBuilders

end Grove.Widgets
