#!/bin/sh

# set return code for final result
exitCode=0

# code coverage display on jenkins expects files to be referenced from project root
cd "$(dirname "$0")/.."

# clear out old results
rm -rf test/results
mkdir -p test/results/

find . -name Test*.lua | while read test
do
    testName=`basename $test`
    lua -lluacov ${test} $@ -n test/results/${testName}.xml

    retVal=$?
    if [ $retVal -ne 0 ]; then
        exitCode=$retVal
    fi
done

exit $exitCode
