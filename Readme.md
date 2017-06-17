elm-verify-examples [![Build Status](https://travis-ci.org/stoeffel/elm-verify-examples.svg?branch=master)](https://travis-ci.org/stoeffel/elm-verify-examples)
============

> Verify examples in your docs.

:information_source: This was formerly known as `elm-doc-test`.

:warning: This is not a replacement for tests, this tool should be used for improving your documentation.


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
```

:warning: **It's important that each example is separated by a newline.**

```elm
{-| This will break!

    add 1 2 --> 3
    add 1 3 --> 4
-}
```

```elm
{-| This works!

    add 1 2 --> 3

    add 1 3 --> 4
-}
```

### Multiline Examples

You can write examples on multiple lines.

```elm
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


### Imports

You can specify imports, if you want to use a module or a special test util.

```elm
{-|
    import Dict

    myWeirdFunc (Dict.fromList [(1, "a"), (2, "b")]) [2, 1]
    --> "ba"
-}
```

### Intermediate Definitions

You can use intermediate definitions in your example.
:information: Unused functions don't get added to the test. This is useful if you wanna add incomplete examples to your docs.
:warning: Intermediate definitions need a type signature!

```elm
{-|
    isEven : Int -> Bool
    isEven n =
        n % 2 == 0

    List.Extra.filterNot isEven [1,2,3,4] --> [1,3]
-}
filterNot : (a -> Bool) -> List a -> List a
```

Verify Examples
----------------

`elm-verify-examples` only converts your verify-examples into elm-tests.
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
