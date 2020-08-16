#!/bin/sh

cd "$(dirname "$0")"

# clear out old files
rm -rf configExports
mkdir -p configExports

find . -name Test\*Unit.lua -exec ./bundleCharacterizationTest.lua {} configExports/{}.txt \;
