.PHONY: npm-install build test watch release-major release-minor release-patch run-examples verify-own-docs

npm-install:
	npm install

build: npm-install
	elm make src/VerifyExamples.elm --output bin/elm.js --optimize

verify-own-docs: build
	./bin/cli.js

test: verify-own-docs
	./run-tests.sh

run-examples: build
	cd example && ../bin/cli.js --run-tests

watch:
	watchexec \
  --clear \
  --restart \
  --watch src \
  --watch bin \
  --watch example/src \
  --watch elm.json \
  "make test"


release-major: test
    npx xyz --repo git@github.com:stoeffel/elm-verify-examples.git --increment major

release-minor: test
	npx xyz --repo git@github.com:stoeffel/elm-verify-examples.git --increment minor

release-patch: test
	npx xyz --repo git@github.com:stoeffel/elm-verify-examples.git --increment patch
