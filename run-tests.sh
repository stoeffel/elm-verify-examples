#! /bin/bash -ex
PASSED_COUNT=34
FAILED_COUNT=2
TODO_COUNT=1

npx elm make src/VerifyExamples.elm --output bin/elm.js --optimize
pushd example
# Push test output into a file, dropping all color codes in the process.
../bin/cli.js --run-tests 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | tee ../output.txt
popd
cat output.txt | grep "Passed:   ${PASSED_COUNT}"
cat output.txt | grep "Failed:   ${FAILED_COUNT}"
cat output.txt | grep "Todo:     ${TODO_COUNT}"
