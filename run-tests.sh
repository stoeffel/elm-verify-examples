#!/usr/bin/env bash

PASSED_COUNT=35
FAILED_COUNT=5

pushd example
# Push test output into a file, dropping all color codes in the process.
../bin/cli.js --run-tests 2>&1 | tee ../output.txt
popd
set -euo pipefail
cat output.txt | grep "Passed" | grep "${PASSED_COUNT}"
cat output.txt | grep "Failed" | grep "${FAILED_COUNT}"
npx elm-test
