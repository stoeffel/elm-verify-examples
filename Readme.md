# elm-verify-examples [![Build Status](https://travis-ci.org/stoeffel/elm-verify-examples.svg?branch=master)](https://travis-ci.org/stoeffel/elm-verify-examples)

> Verify examples in your docs.

:information_source: This was formerly known as `elm-doc-test`.

:warning: This is not a replacement for tests, this tool should be used for improving your documentation.

## Install

```bash
$ npm i elm-test -g
$ npm i elm-verify-examples -g
$ elm-test init
```

## Setup

```bash
$ touch tests/elm-verify-examples.json
```

`elm-verify-examples.json` contains information on which files contain verified examples and where to find them.

```json
{
  "root": "../src",
  "tests": ["Mock", "Mock.Foo.Bar.Moo", "./README.md"]
}
```

It's recommended to add `./tests/VerifyExamples` to your `.gitignore`.

## Writing Verified Examples

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
        |> String.concat
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
        remainderBy 2 n == 0

    List.Extra.filterNot isEven [1,2,3,4] --> [1,3]

-}


filterNot : (a -> Bool) -> List a -> List a
```

### Types in Examples

You can define union types and type aliases in your examples.

```elm
{-| With a union type in the example.
type Animal
= Dog
| Cat

    double Dog
    --> (Dog, Dog)

-}


double : a -> ( a, a )
double a =
    ( a, a )
```

```elm
{-| With a type alias in the example.

    customTypeAlias defaultUser "?"
    --> "?Luke"

    type alias User =
        { id: Int -- ID
        , name: String
        }

    defaultUser : User
    defaultUser =
        { id = 1
        , name = "Luke"
        }

    customTypeAlias defaultUser "_"
    --> "_Luke"

-}


customTypeAlias : { a | name : String } -> String -> String
customTypeAlias { name } prefix =
    prefix ++ name
```

### Examples in markdown files

You can also verify code example in markdown files (such as your README). To do so, add the file's path to your `elm-verify-examples.json` file and write your example using the sames rules as above (no need for 4-space indentation here).

````
This is my README!
It explains how the `Documented` module works:

```elm
import Documented

Documented.two --> 2
```
````

## Verify Examples

`elm-verify-examples` converts your verify-examples into elm-tests, and optionally runs them using `elm-test`. To only generate the test files in `tests/VerifyExamples/`:

```bash
$ elm-verify-examples
```

This is useful if you want to run your tests using different runner than `elm-test`, e.g. `elm-coverage`. If you also want to run the generated tests:

```bash
$ elm-verify-examples --run-tests
```

Note that this way the test files will be removed after they are ran.

By default, this command looks for the config file at `tests/elm-verify-examples.json`. If you want it to load a specific config file use the `--config` argument (e.g. `elm-verify-examples --config my/custom/path/elm-verify-examples.json` will read the config from `my/custom/path/elm-verify-examples.json`).

You can run elm-verify-examples for one or more modules explicitly. They don't have to be specified in `tests/elm-verify-examples.json`.

```bash
$ elm-verify-examples ./src/Foo.elm ./src/Foo/Bar.elm
```

You can pass a custom path to elm-test if necessary.

```bash
$ elm-verify-examples --elm-test=./node_modules/.bin/elm-test
$ # or add it to your elm-verify-examples.json `elmTest: "../node....`
$ # you can also pass arguments to elm-test with --elm-test-args
```

It will use the elm-test installed with this package.

## Examples

You can run the examples using:

`npm start`
