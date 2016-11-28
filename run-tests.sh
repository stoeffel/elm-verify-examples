#! /bin/bash -ex

elm-make src/DocTest.elm --output bin/elm.js &&
cd example &&
../bin/cli.js &&
{
  elm-test tests/Doc/Main.elm | grep 'Passed:   9' &&
  echo "👍"
} || {
  echo "expected 9 passing specs. run 'npm start'"
  exit -1
}
