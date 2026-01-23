import Lake
open Lake DSL

package grove where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

require afferent from git "https://github.com/nathanial/afferent" @ "v0.0.2"
require arbor from git "https://github.com/nathanial/arbor" @ "v0.0.1"
require canopy from git "https://github.com/nathanial/canopy" @ "v0.0.1"
require trellis from git "https://github.com/nathanial/trellis" @ "v0.0.1"
require tincture from git "https://github.com/nathanial/tincture" @ "v0.0.1"
require staple from git "https://github.com/nathanial/staple" @ "v0.0.2"

-- Test dependencies
require crucible from git "https://github.com/nathanial/crucible" @ "v0.0.9"

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
