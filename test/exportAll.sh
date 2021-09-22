#!/bin/sh

cd "$(dirname "$0")"

# clear out old files
rm -rf configExports
mkdir -p configExports/dumocks

find dumocks -name Test\*.lua -exec ./bundleCharacterizationTest.lua {} configExports/{}.txt \;
