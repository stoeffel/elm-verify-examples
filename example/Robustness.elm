module Robustness exposing (..)

{-| -}


{-|

    add 0 2 --> 2
    add 2 1 --> 3

    add 2 2 --> 4
    add 2 3
    --> 5
    add 2
    4 --> 6
    add 4
    3
    --> 7
    add 5 3 -> 8BROKEN

-}
add : Int -> Int -> Int
add =
    (+)


{-|

    list3 1 2 3 --> [ 1
    --> , 2, 3]
    list3 1 2 3 --> [ 1 --> , 2 --> , 3] -- WAT!
    list3 1 2 3
    --> [ 1
    --> , 2
    --> , 3]
    list3 1 2 3
    --> [ 1, 2, 3]
    list3
    1
    2
    3
    --> [ 1
    --> , 2
    --> , 3]

-}
list3 : Int -> Int -> Int -> List Int
list3 a b c =
    [ a, b, c ]


{-|

    list3With inc
    1
    2
    3
    --> [ 2
    --> , 3
    --> , 4]
    inc : Int -> Int
    inc = (+) 1

-}
list3With : (Int -> Int) -> Int -> Int -> Int -> List Int
list3With f a b c =
    [ a, b, c ]
        |> List.map f
