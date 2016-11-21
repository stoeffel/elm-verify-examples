module Mock exposing (..)

import String


{-| returns the sum of two int.

    > add 41 1
    42

    > add 3 3
    6

-}
add : Int -> Int -> Int
add =
    (+)


{-| returns the sum of a list of int

    > sum
    |     [ 41
    |     , 1
    |     ]
    42
-}
sum : List Int -> Int
sum =
    List.foldl (+) 0


{-| reverses the list

    > rev
    |     [ 41
    |     , 1
    |     ]
    [ 1
    , 41
    ]

    > rev [1, 2, 3]
    | |> List.map toString
    | |> String.join ""
    "321"
-}
rev : List a -> List a
rev =
    List.reverse
