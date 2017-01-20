elm-doc-test [![Build Status](https://travis-ci.org/stoeffel/elm-doc-test.svg?branch=master)](https://travis-ci.org/stoeffel/elm-doc-test)
============

> Create doc test and run them with elm-test

Install
-------

```bash
$ npm i elm-test -g
$ npm i elm-doc-test -g
$ elm-test init
```

It's recommended to add `./tests/Doc` to your `.gitignore`.

Writing DocTests
----------------

Tests start with four spaces!

```elm
{-| returns the sum of two int.

    >>> add 41 1
    42

    >>> add 3 3
    6
-}
add : Int -> Int -> Int
add =
    (+)


{-| reverses the list

    >>> rev
    ...     [ 41
    ...     , 1
    ...     ]
    [ 1
    , 41
    ]

    >>> rev [1, 2, 3]
    ... |> List.map toString
    ... |> String.join ""
    "321"
-}
rev : List a -> List a
rev =
    List.reverse
```

You can specify imports for doc-test, if you want to use a module or a special test util.

```elm
{-| returns some html

    HtmlToString is only used for doc tests.
    >>> import HtmlToString exposing (htmlToString, nodeTypeToString)

    >>> header "World"
    ... |> htmlToString
    "<h1>Hello, World!</h1>"
-}
```

Running DocTests
----------------

`elm-doc-test` only converts your doc-tests into elm-tests.
You have to use elm-test in order to run them.

```bash
$ elm-doc-test && elm-test tests/Doc/Main.elm
```

By default the first command creates the tests at `tests/Doc/`. If you want to have them at a custom location use the `--output` argument (e.g. `elm-doc-test --output my/custom/path/` will create the tests at `my/custom/path/Doc/`).

Examples
--------

You can run the examples using:

`npm start`
