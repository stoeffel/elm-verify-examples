#! /bin/bash -ex
TEST_COUNT=15

elm-make src/DocTest.elm --output bin/elm.js
cd example
../bin/cli.js

{
  ./node_modules/.bin/elm-test | grep "Passed" | grep $TEST_COUNT
  echo "👍"
} || {
  echo "Expected $TEST_COUNT passing specs!"
  npm start
  exit -1
}
