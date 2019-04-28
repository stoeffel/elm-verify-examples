#! /bin/bash -ex
PASSED_COUNT=33
FAILED_COUNT=2
TODO_COUNT=1

npx elm make src/VerifyExamples.elm --output bin/elm.js --optimize
pushd example
../bin/cli.js --run 2>&1 | tee ../output.txt
popd
cat output.txt | grep "Passed:   ${PASSED_COUNT}"
cat output.txt | grep "Failed:   ${FAILED_COUNT}"
cat output.txt | grep "Todo:     ${TODO_COUNT}"
