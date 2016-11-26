module Mock exposing (..)

import String exposing (join)
import Dict exposing (Dict, fromList)


{-| returns the sum of two int.

    >>> add 41 1
    42

    >>> add 3 3
    6

-}
add : Int -> Int -> Int
add =
    (+)


{-| returns the sum of a list of int

    >>> sum
    ...     [ 41
    ...     , 1
    ...     ]
    42
-}
sum : List Int -> Int
sum =
    List.foldl (+) 0


{-|
    >>> bar 1 "foo"
    fromList [(1, "foo")]
-}
bar : Int -> String -> Dict Int String
bar a b =
    fromList [ ( a, b ) ]


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
    ... |> join ""
    "321"
-}
rev : List a -> List a
rev =
    List.reverse
