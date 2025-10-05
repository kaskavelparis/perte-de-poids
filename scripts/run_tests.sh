#!/bin/bash

# Simple script to run unit tests locally.
# This script assumes you have opened the Xcode project and created
# a scheme named "MarIAWillyRPG". It invokes xcodebuild to run
# the tests on the default iOS simulator.

set -euo pipefail

SCHEME="MarIAWillyRPG"
DESTINATION="platform=iOS Simulator,name=iPhone 15"

echo "Running tests for scheme $SCHEME on $DESTINATION"

xcodebuild \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  clean test | xcpretty || exit 1

echo "Tests completed."