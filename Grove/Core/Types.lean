/-
  Grove Core Types
  Fundamental data structures for the file browser.
-/

namespace Grove

/-- Metadata about a file or directory entry. -/
structure FileItem where
  name : String
  path : System.FilePath
  isDirectory : Bool
  size : Option Nat := none
  modifiedTime : Option Nat := none
  extension : Option String := none
deriving Repr, BEq, Inhabited

namespace FileItem

/-- Create a FileItem from a path with basic info. -/
def fromPath (path : System.FilePath) (isDir : Bool) (size : Option Nat := none) : FileItem :=
  let name := path.fileName.getD (path.toString)
  let ext := if isDir then none else path.extension
  { name, path, isDirectory := isDir, size, extension := ext }

/-- Check if this is a hidden file (starts with dot). -/
def isHidden (item : FileItem) : Bool :=
  item.name.startsWith "."

/-- Get display name (just the filename). -/
def displayName (item : FileItem) : String :=
  item.name

end FileItem

/-- How items are sorted in the file list. -/
inductive SortOrder where
  | nameAsc
  | nameDesc
  | sizeAsc
  | sizeDesc
  | dateAsc
  | dateDesc
  | kindAsc   -- directories first, then files
  | kindDesc  -- files first, then directories
deriving Repr, BEq

namespace SortOrder

/-- Compare two FileItems according to the sort order. -/
def compare (order : SortOrder) (a b : FileItem) : Ordering :=
  match order with
  | .nameAsc => Ord.compare a.name.toLower b.name.toLower
  | .nameDesc => Ord.compare b.name.toLower a.name.toLower
  | .sizeAsc =>
      let sa := a.size.getD 0
      let sb := b.size.getD 0
      Ord.compare sa sb
  | .sizeDesc =>
      let sa := a.size.getD 0
      let sb := b.size.getD 0
      Ord.compare sb sa
  | .dateAsc =>
      let da := a.modifiedTime.getD 0
      let db := b.modifiedTime.getD 0
      Ord.compare da db
  | .dateDesc =>
      let da := a.modifiedTime.getD 0
      let db := b.modifiedTime.getD 0
      Ord.compare db da
  | .kindAsc =>
      -- Directories first, then by name
      match a.isDirectory, b.isDirectory with
      | true, false => .lt
      | false, true => .gt
      | _, _ => Ord.compare a.name.toLower b.name.toLower
  | .kindDesc =>
      -- Files first, then by name
      match a.isDirectory, b.isDirectory with
      | false, true => .lt
      | true, false => .gt
      | _, _ => Ord.compare a.name.toLower b.name.toLower

/-- Sort an array of FileItems. -/
def sortItems (order : SortOrder) (items : Array FileItem) : Array FileItem :=
  items.qsort (fun a b => order.compare a b == .lt)

end SortOrder

/-- Selection state for files. -/
structure Selection where
  items : Array System.FilePath := #[]
  anchorIndex : Option Nat := none  -- For shift-click range selection
deriving Repr, BEq

namespace Selection

def empty : Selection := {}

def isEmpty (s : Selection) : Bool := s.items.isEmpty

def count (s : Selection) : Nat := s.items.size

def contains (s : Selection) (path : System.FilePath) : Bool :=
  s.items.contains path

/-- Select a single item, clearing previous selection. -/
def selectSingle (path : System.FilePath) (index : Nat) : Selection :=
  { items := #[path], anchorIndex := some index }

/-- Toggle selection of an item (for Cmd-click). -/
def toggle (s : Selection) (path : System.FilePath) (index : Nat) : Selection :=
  if s.contains path then
    { items := s.items.filter (· != path), anchorIndex := s.anchorIndex }
  else
    { items := s.items.push path, anchorIndex := some index }

/-- Extend selection to include range from anchor to index (for Shift-click). -/
def extendTo (s : Selection) (allItems : Array FileItem) (index : Nat) : Selection :=
  let anchor := s.anchorIndex.getD index
  let lo := min anchor index
  let hi := max anchor index
  let paths := Id.run do
    let mut result : Array System.FilePath := #[]
    for i in [lo:hi+1] do
      if h : i < allItems.size then
        result := result.push allItems[i].path
    return result
  { items := paths, anchorIndex := s.anchorIndex }

/-- Select all items. -/
def selectAll (allItems : Array FileItem) : Selection :=
  { items := allItems.map (·.path), anchorIndex := if allItems.isEmpty then none else some 0 }

/-- Clear selection. -/
def clear : Selection := empty

end Selection

/-- Which panel currently has keyboard focus. -/
inductive FocusPanel where
  | tree
  | list
  | addressBar
deriving Repr, BEq

end Grove
