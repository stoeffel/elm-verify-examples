#! /bin/bash -ex

elm-make src/DocTest.elm --output bin/elm.js &&
cd example &&
../bin/cli.js &&
{
  elm-test | grep 'Passed:   10' &&
  echo "👍"
} || {
  echo "Expected 10 passing specs!"
  npm start
  exit -1
}
