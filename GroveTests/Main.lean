/-
  Grove Tests
  Test suite for the file browser.
-/
import Crucible
import Grove

namespace GroveTests

open Crucible
open Grove

testSuite "Grove Core Types"

test "FileItem.fromPath creates correct item" := do
  let item := FileItem.fromPath ⟨"/home/user/test.txt"⟩ false (some 1024)
  item.name ≡ "test.txt"
  item.isDirectory ≡ false
  item.size ≡ some 1024
  item.extension ≡ some "txt"

test "FileItem.fromPath handles directories" := do
  let item := FileItem.fromPath ⟨"/home/user/docs"⟩ true none
  item.name ≡ "docs"
  item.isDirectory ≡ true
  item.extension ≡ none

test "FileItem.isHidden detects dotfiles" := do
  let hidden := FileItem.fromPath ⟨".gitignore"⟩ false none
  let visible := FileItem.fromPath ⟨"readme.md"⟩ false none
  hidden.isHidden ≡ true
  visible.isHidden ≡ false

testSuite "Selection"

test "Selection.selectSingle creates single selection" := do
  let sel := Selection.selectSingle ⟨"/test"⟩ 0
  sel.count ≡ 1
  sel.contains ⟨"/test"⟩ ≡ true

test "Selection.toggle adds and removes items" := do
  let sel := Selection.selectSingle ⟨"/a"⟩ 0
  let sel2 := sel.toggle ⟨"/b"⟩ 1
  sel2.count ≡ 2
  let sel3 := sel2.toggle ⟨"/a"⟩ 0
  sel3.count ≡ 1
  sel3.contains ⟨"/a"⟩ ≡ false
  sel3.contains ⟨"/b"⟩ ≡ true

testSuite "NavigationHistory"

test "NavigationHistory.navigateTo adds to back stack" := do
  let nav := NavigationHistory.init ⟨"/home"⟩
  let nav2 := nav.navigateTo ⟨"/home/docs"⟩
  nav2.currentPath.toString ≡ "/home/docs"
  nav2.canGoBack ≡ true
  nav2.canGoForward ≡ false

test "NavigationHistory.goBack restores previous path" := do
  let nav := NavigationHistory.init ⟨"/home"⟩
  let nav2 := nav.navigateTo ⟨"/home/docs"⟩
  let nav3 := nav2.goBack
  nav3.currentPath.toString ≡ "/home"
  nav3.canGoBack ≡ false
  nav3.canGoForward ≡ true

test "NavigationHistory.goForward after goBack" := do
  let nav := NavigationHistory.init ⟨"/home"⟩
  let nav2 := nav.navigateTo ⟨"/docs"⟩
  let nav3 := nav2.goBack
  let nav4 := nav3.goForward
  nav4.currentPath.toString ≡ "/docs"

testSuite "SortOrder"

test "SortOrder.kindAsc sorts directories first" := do
  let items := #[
    FileItem.fromPath ⟨"file.txt"⟩ false none,
    FileItem.fromPath ⟨"docs"⟩ true none,
    FileItem.fromPath ⟨"readme.md"⟩ false none
  ]
  let sorted := SortOrder.kindAsc.sortItems items
  sorted[0]!.name ≡ "docs"
  sorted[0]!.isDirectory ≡ true



end GroveTests

open Crucible in
def main : IO UInt32 := do
  runAllSuites
