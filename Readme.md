elm-verify-examples [![Build Status](https://travis-ci.org/stoeffel/elm-verify-examples.svg?branch=master)](https://travis-ci.org/stoeffel/elm-verify-examples)
============

> Verify examples in your docs.


Install
-------

```bash
$ npm i elm-test -g
$ npm i elm-verify-examples -g
$ elm-test init
```

Setup
-----

```bash
$ touch tests/elm-verify-examples.json
```

`elm-verify-examples.json` contains information on which files contain verified examples and where to find them.

```json
{
  "root": "../src",
  "tests": [
    "Mock",
    "Mock.Foo.Bar.Moo"
  ]
}
```

It's recommended to add `./tests/Doc` to your `.gitignore`.

Writing Verified Examples
----------------

Verified examples look like normal code examples in doc-comments. \
Code needs to be indented by 4 spaces.
You can specify the expected result of an expression, by adding a comment `-->` (the `>` is important) and an expected expression.

```elm
{-| returns the sum of two int.

    -- You can write the expected result on the next line,

    add 41 1
    --> 42

    -- or on the same line.

    add 3 3 --> 6

-}
add : Int -> Int -> Int
add =
    (+)

You can write examples on multiple lines.

{-| reverses the list

    rev
        [ 41
        , 1
        ]
    --> [ 1
    --> , 41
    --> ]

    rev [1, 2, 3]
        |> List.map toString
        |> String.join ""
    --> "321"
-}
rev : List a -> List a
rev =
    List.reverse
```

You can specify imports, if you want to use a module or a special test util.

```elm
{-|
    import Dict

    myWeirdFunc (Dict.fromList [(1, "a"), (2, "b")]) [2, 1]
    --> "ba"
-}
```

Running VerifyExampless
----------------

`elm-verify-examples` only converts your verify-exampless into elm-tests.
You have to use elm-test in order to run them.

```bash
$ elm-verify-examples && elm-test
```

By default the first command creates the tests at `tests/Doc/`. If you want to have them at a custom location use the `--output` argument (e.g. `elm-verify-examples --output my/custom/path/` will create the tests at `my/custom/path/Doc/`).

Also by default the first command looks for the config file at `tests/elm-verify-examples.json`. If you want it to load a specific config file use the `--config` argument (e.g. `elm-verify-examples --config my/custom/path/elm-verify-examples.json` will read the config from `my/custom/path/elm-verify-examples.json`).

Examples
--------

You can run the examples using:

`npm start`
