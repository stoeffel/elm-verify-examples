#! /bin/bash -ex
TEST_COUNT = cat example/tests/Doc/**/*.elm | grep 'Test.test' | wc -l

elm-make src/DocTest.elm --output bin/elm.js &&
cd example &&
../bin/cli.js &&
{
  elm-test | grep "Passed:   $TEST_COUNT" &&
  echo "👍"
} || {
  echo "Expected $TEST_COUNT passing specs!"
  npm start
  exit -1
}
