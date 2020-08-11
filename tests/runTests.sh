#!/bin/sh
cd "$(dirname "$0")/.."

rm -rf tests/results
mkdir -p tests/results/tests/

find ./tests -name Test\*.lua -exec lua -lluacov {} $@ -n tests/results/{}.xml \;

