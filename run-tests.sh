#! /bin/bash -ex
TEST_COUNT=15

elm-make src/VerifyExamples.elm --output bin/elm.js &&
cd example &&
../bin/cli.js &&
{
  elm-test | grep "Passed" | grep $TEST_COUNT &&
  echo "👍"
} || {
  echo "Expected $TEST_COUNT passing specs!"
  npm start
  exit -1
}
