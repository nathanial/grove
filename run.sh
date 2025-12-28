#!/bin/bash
# Build and run Grove file browser

set -e

cd "$(dirname "$0")"

./build.sh grove

.lake/build/bin/grove "$@"
