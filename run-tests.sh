#! /bin/bash -ex
TEST_COUNT=15

elm-make src/DocTest.elm --output bin/elm.js
cd example
../bin/cli.js

{
  elm-test > ../result.json
  cd ..
  cat result.json | grep "Passed:   ${TEST_COUNT}"
  cat result.json | grep "Failed:   0"
} || {
  echo "Expected $TEST_COUNT passing specs!"
  exit -1
}
