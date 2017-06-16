#! /bin/bash -ex
TEST_COUNT=15

elm-make src/DocTest.elm --output bin/elm.js
pushd example
../bin/cli.js
elm-test 2>&1 | tee ../result.json
popd
cat result.json | grep "Passed:   ${TEST_COUNT}"
cat result.json | grep "Failed:   0"
