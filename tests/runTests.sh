#!/bin/sh
cd "$(dirname "$0")"

rm -rf results
mkdir results

./TestMockElement.lua -o junit -n results/TestMockElement.xml
./TestMockContainerUnit.lua -o junit -n results/TestMockContainerUnit.xml
./TestMockDatabankUnit.lua -o junit -n results/TestMockDatabankUnit.xml

