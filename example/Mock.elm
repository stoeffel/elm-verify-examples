module Mock exposing (..)

{-| imports for examples

@docs add, sum, bar, rev

    --> import Dict exposing (Dict, fromList)
    --> import String exposing (join)

-}

import Dict exposing (Dict, fromList)


{-| returns the sum of two int.
3 - 1
--> 2

    add 41 1
    --> 42

    add 3 3 --> 6

-}
add : Int -> Int -> Int
add =
    (+)


{-| returns the sum of a list of int

    sum aList -- no expectation, this is not a test

    sum
        [ 41
        , 1
        ]
    --> 42

-}
sum : List Int -> Int
sum =
    List.foldl (+) 0


{-|

    bar 1 "foo"
    --> fromList [(1, "foo")]

-}
bar : Int -> String -> Dict Int String
bar a b =
    fromList [ ( a, b ) ]


{-| reverses the list

    rev
        [ 41
        , 1
        ]
    --> [ 1
    --. , 41
    --. ]

    rev [1, 2, 3]
        |> List.map toString
        |> join ""
    --> "321"

-}
rev : List a -> List a
rev =
    List.reverse


{-| some inline comments

    >>> -- comment
    >>> quux 10 32 -- another
    42 --result

-}
quux : Int -> Int -> Int
quux n m =
    n + m
