#!/bin/sh
cd "$(dirname "$0")"

rm -rf results
mkdir results

find . -name Test\*.lua -exec ./{} -o junit -n results/{}.xml \;

