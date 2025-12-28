#!/bin/bash
# Build script for Grove
# Uses system clang for proper macOS framework linking

set -e

cd "$(dirname "$0")"

# Must use system clang for framework linking
export LEAN_CC=/usr/bin/clang

# Ensure Homebrew libraries are found (needed for mathlib cache)
export LIBRARY_PATH=/opt/homebrew/lib:${LIBRARY_PATH:-}

lake build "$@"
