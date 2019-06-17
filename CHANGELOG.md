# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Do not run tests by default, only generate [#65](https://github.com/stoeffel/elm-verify-examples/issues/65)
- Add --run-tests (-r) option to run generated tests [#65](https://github.com/stoeffel/elm-verify-examples/issues/65)


## 2.0.0

- We have a changelog now :tada:
- Directly depending on `elm-test`. This means you can run `elm-verify-examples` without running `elm-test` afterwards. [#52](https://github.com/stoeffel/elm-verify-examples/pull/52)
- Nicer test failures [#53](https://github.com/stoeffel/elm-verify-examples/pull/53)
- Possibility to use `type` and `type alias` in your examples. [#43](https://github.com/stoeffel/elm-verify-examples/pull/43) [#44](https://github.com/stoeffel/elm-verify-examples/pull/44)
- More reliable parsing. [#47](https://github.com/stoeffel/elm-verify-examples/pull/47)
- We cleanup the the generated tests before and after generation. The generated tests are now in `tests/VerifyExamples`. [#50](https://github.com/stoeffel/elm-verify-examples/pull/50)
- Allow `\r\n` linebreaks. [#42](https://github.com/stoeffel/elm-verify-examples/pull/42)
