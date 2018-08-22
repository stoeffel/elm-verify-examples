#! /bin/bash -ex
PASSED_COUNT=33
FAILED_COUNT=1
TODO_COUNT=1

elm make src/VerifyExamples.elm --output bin/elm.js
pushd example
../bin/cli.js 2>&1 | tee ../output.txt
popd
cat output.txt | grep "Passed:   ${PASSED_COUNT}"
cat output.txt | grep "Failed:   ${FAILED_COUNT}"
cat output.txt | grep "Todo:     ${TODO_COUNT}"
