import Lake
open Lake DSL

package grove where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

-- Local workspace dependencies
require afferent from ".." / "afferent"
require arbor from ".." / "arbor"
require canopy from ".." / "canopy"
require trellis from ".." / "trellis"
require tincture from ".." / "tincture"
require staple from ".." / "staple"

-- Test dependencies
require crucible from ".." / "crucible"

@[default_target]
lean_lib Grove where
  roots := #[`Grove]

lean_lib GroveTests where
  roots := #[`GroveTests]
  globs := #[.submodules `GroveTests]

-- Link arguments for Metal/macOS (inherited pattern from afferent)
def commonLinkArgs : Array String := #[
  "-framework", "Metal",
  "-framework", "Cocoa",
  "-framework", "QuartzCore",
  "-framework", "Foundation",
  "-lobjc",
  "-L/opt/homebrew/lib",
  "-L/usr/local/lib",
  "-lfreetype",
  "-lassimp",
  "-lc++"
]

lean_exe grove where
  root := `Grove.Main
  moreLinkArgs := commonLinkArgs

lean_exe grove_tests where
  root := `GroveTests.Main
  moreLinkArgs := commonLinkArgs
