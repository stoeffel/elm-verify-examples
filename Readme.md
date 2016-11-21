elm-doc-test
============

> Create doc test and run them with elm-test

![](./elm-doc-test.gif)

Install
-------

```bash
$ npm i elm-test -g
$ npm i elm-doc-test -g
$ elm-test init
```

Setup
-----

```bash
$ touch tests/elm-doc-test.json
```

`elm-doc-test.json` contains information on which files contain doc tests and where to find them.

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

Writing DocTests
----------------

Tests start with for spaces!

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

Running DocTests
----------------

`elm-doc-test` only converts your doc-tests into elm-tests.
You have to use elm-test in order to run them.

```bash
$ elm-doc-test && elm-test tests/Doc/Main.elm
```

Examples
--------

You can run the examples using:

`npm start`
