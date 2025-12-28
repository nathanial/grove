#!/bin/bash
# Build and run Grove tests

set -e

cd "$(dirname "$0")"

./build.sh grove_tests

.lake/build/bin/grove_tests
