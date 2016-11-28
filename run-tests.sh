#! /bin/bash -ex

elm-make src/DocTest.elm --output bin/elm.js &&
cd example &&
../bin/cli.js &&
{
  elm-test tests/Doc/Main.elm | grep 'Passed:   9' &&
  echo "👍"
} || {
  echo "Expected 9 passing specs!"
  npm start
  exit -1
}
