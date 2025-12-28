/-
  Grove FileSystem Utilities
  IO operations for reading directories and file metadata.
-/
import Grove.Core.Types

namespace Grove

/-- Read the contents of a directory, returning FileItems for each entry. -/
def readDirectory (path : System.FilePath) : IO (Array FileItem) := do
  let entries ← System.FilePath.readDir path
  let mut items : Array FileItem := #[]
  for entry in entries do
    let entryPath := entry.path
    let isDir ← entryPath.isDir
    -- Get file size via metadata
    let size ← if isDir then
        pure none
      else
        try
          let fileMeta ← entryPath.metadata
          pure (some fileMeta.byteSize.toNat)
        catch _ =>
          pure none
    let item := FileItem.fromPath entryPath isDir size
    items := items.push item
  return items

/-- Read directory and sort by the given order. -/
def readDirectorySorted (path : System.FilePath) (order : SortOrder) : IO (Array FileItem) := do
  let items ← readDirectory path
  return order.sortItems items

/-- Get the current working directory. -/
def getCurrentDirectory : IO System.FilePath := do
  IO.currentDir

/-- Check if a path exists and is a directory. -/
def isValidDirectory (path : System.FilePath) : IO Bool := do
  try
    path.isDir
  catch _ =>
    return false

/-- Get the parent directory of a path. -/
def getParentDirectory (path : System.FilePath) : System.FilePath :=
  path.parent.getD path

/-- Normalize a path (resolve . and ..). -/
def normalizePath (path : System.FilePath) : IO System.FilePath := do
  -- For now, just return the path as-is
  -- A full implementation would resolve symlinks and normalize
  pure path

/-- Get the home directory. -/
def getHomeDirectory : IO System.FilePath := do
  match ← IO.getEnv "HOME" with
  | some home => pure ⟨home⟩
  | none => getCurrentDirectory

/-- List of root paths (for tree view root). -/
def getRootPaths : IO (Array System.FilePath) := do
  -- On macOS/Unix, the root is /
  -- Could also include home directory as a quick access
  let home ← getHomeDirectory
  return #[⟨"/"⟩, home]

end Grove
